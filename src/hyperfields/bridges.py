"""Cross-field integration bridges, as typed records.

Hyperstratum's ``integration-registry.json`` declares three bridges between
fields. Each one is a *declaration of intent*, not a proven correspondence,
and each carries an explicit ``OPEN`` status.

This module reads those declarations from ``bridges.json``, which the Lean
``Hyperfields.Bridges`` module emits. The Lean record is the source of
truth, and the Python record reads it rather than restating it, so the two
halves cannot disagree about a status or a mapping.

The refusal semantics that ``hyperstratum.integration`` enforces are
preserved here too:

* A bridge whose target is classified ``FORM`` cannot be certified by a
  declaration checker. Attaching it requires independent derivation
  elsewhere.
* A bridge cannot self-certify. Its status is ``OPEN`` or ``UNKNOWN`` and
  nothing here promotes it.

The point of encoding this is that a bridge which silently became ``FORM``
would be a false claim about a correspondence between two fields. A bridge
that quietly became closed would be a false claim of proof. Both are worse
than a bridge that stays open, so the type keeps them apart and the loader
refuses to invent either.
"""

from __future__ import annotations

import enum
import json
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Final

#: The Lean-rendered bridge record, relative to the package directory.
BRIDGES_RELPATH: Final[str] = "bridges.json"

#: The repository root when the package is used from a source checkout.
_REPO_ROOT: Final[Path] = Path(__file__).resolve().parent.parent.parent

#: The schema this module understands.
SCHEMA: Final[str] = "hyperstratum-integration-0.1"


class BridgeStatus(str, enum.Enum):
    """The declared status of a bridge.

    ``OPEN`` means the correspondence is declared but not established.
    ``UNKNOWN`` means the declaration itself is not yet settled. There is no
    member for a closed or certified bridge, because a declaration checker
    cannot certify one: a correspondence that has been proved needs an
    independent derivation, not a status flip.
    """

    OPEN = "OPEN"
    UNKNOWN = "UNKNOWN"


class BridgeRelation(str, enum.Enum):
    """The role a bridge claims to play."""

    INTERPRETATION = "interpretation"
    TRANSPORT = "transport"
    APPLICATION = "application"
    REPRESENTATION = "representation"


class FieldClass(str, enum.Enum):
    """The classification of a bridge endpoint.

    ``FORM`` is a native, closed account. ``FRAME`` is a declared but
    incomplete account. ``OPEN`` is a declared account whose own status is
    unsettled. ``HYPER`` is a candidate that may be embedded at several
    levels.
    """

    FORM = "FORM"
    FRAME = "FRAME"
    OPEN = "OPEN"
    HYPER = "HYPER"


class BridgeError(RuntimeError):
    """Raised when a bridge declaration is missing, unreadable, or invalid."""


@dataclass(frozen=True, slots=True)
class Mapping:
    """One named correspondence between a source and a target concept."""

    source: str
    target: str
    meaning: str

    def __post_init__(self) -> None:
        for label, value in (
            ("source", self.source),
            ("target", self.target),
            ("meaning", self.meaning),
        ):
            if not isinstance(value, str) or not value.strip():
                raise BridgeError(f"a mapping needs a nonempty {label}")


@dataclass(frozen=True, slots=True)
class Bridge:
    """One declared cross-field correspondence.

    Every bridge in the current registry is ``OPEN``. The status is part of
    the record rather than an inference, so a reader can see at a glance that
    no correspondence has been established.
    """

    source: str
    target: str
    relation: BridgeRelation
    source_class: FieldClass
    target_class: FieldClass
    status: BridgeStatus
    mappings: tuple[Mapping, ...]
    preserves: tuple[str, ...]
    excludes: tuple[str, ...]
    obligations: tuple[str, ...]

    def __post_init__(self) -> None:
        if not self.source or not self.target:
            raise BridgeError("a bridge needs two endpoints")
        if self.source == self.target:
            raise BridgeError("a cross-field bridge needs two fields")
        if self.target_class is FieldClass.FORM:
            raise BridgeError(
                "this declaration checker cannot certify target FORM; "
                "attach independent derivation elsewhere"
            )
        if not self.mappings:
            raise BridgeError("a bridge needs at least one mapping")
        for label, statements in (
            ("preserves", self.preserves),
            ("excludes", self.excludes),
            ("obligations", self.obligations),
        ):
            if not statements:
                raise BridgeError(f"a bridge needs explicit nonempty {label}")
            for statement in statements:
                if not isinstance(statement, str) or not statement.strip():
                    raise BridgeError(f"a bridge's {label} must be nonempty statements")

    @property
    def is_open(self) -> bool:
        """Whether this bridge is still an open declaration."""
        return self.status is BridgeStatus.OPEN


def _texts(value: Any, label: str, slug: str) -> tuple[str, ...]:
    """Return a nonempty list of statements, or raise."""
    if not isinstance(value, list) or not value:
        raise BridgeError(f"bridge {slug!r} needs explicit nonempty {label}")
    for statement in value:
        if not isinstance(statement, str) or not statement.strip():
            raise BridgeError(f"bridge {slug!r} has an empty statement in {label}")
    return tuple(value)


def _parse_bridge(raw: dict[str, Any]) -> Bridge:
    """Turn one registry record into a :class:`Bridge`."""
    source = str(raw.get("source", ""))
    target = str(raw.get("target", ""))
    slug = f"{source}->{target}"
    try:
        relation = BridgeRelation(raw["relation"])
        source_class = FieldClass(raw["source_class"])
        target_class = FieldClass(raw["target_class"])
        status = BridgeStatus(raw["status"])
    except KeyError as exc:
        raise BridgeError(f"bridge {slug!r} lacks the field {exc.args[0]!r}") from exc
    except ValueError as exc:
        raise BridgeError(f"bridge {slug!r} has an unknown value: {exc}") from exc

    raw_mappings = raw.get("mappings")
    if not isinstance(raw_mappings, list) or not raw_mappings:
        raise BridgeError(f"bridge {slug!r} needs at least one mapping")
    mappings = tuple(
        Mapping(
            source=str(item["source"]),
            target=str(item["target"]),
            meaning=str(item["meaning"]),
        )
        for item in raw_mappings
    )

    return Bridge(
        source=source,
        target=target,
        relation=relation,
        source_class=source_class,
        target_class=target_class,
        status=status,
        mappings=mappings,
        preserves=_texts(raw.get("preserves"), "preserves", slug),
        excludes=_texts(raw.get("excludes"), "excludes", slug),
        obligations=_texts(raw.get("obligations"), "obligations", slug),
    )


def default_bridges_path() -> Path:
    """Return the path of the Lean-rendered bridge record."""
    return Path(__file__).resolve().parent / BRIDGES_RELPATH


def load_bridges(path: Path | None = None) -> tuple[Bridge, ...]:
    """Load the declared bridges from the Lean-rendered bridge record.

    Parameters
    ----------
    path
        The record to read. Defaults to the packaged ``bridges.json``.

    Returns
    -------
    tuple[Bridge, ...]
        Every declared bridge, in the order the record lists them.

    Raises
    ------
    BridgeError
        If the record is missing, unreadable, of an unknown schema, or
        carries a bridge that violates the declaration contract.
    """
    registry_path = default_bridges_path() if path is None else Path(path)
    try:
        raw_text = registry_path.read_text(encoding="utf-8")
    except OSError as exc:
        raise BridgeError(f"the integration registry at {registry_path} is unreadable: {exc}") from exc
    try:
        document = json.loads(raw_text)
    except json.JSONDecodeError as exc:
        raise BridgeError(
            f"the integration registry at {registry_path} is not valid JSON: {exc}"
        ) from exc
    if not isinstance(document, dict):
        raise BridgeError("the integration registry must be a JSON object")
    schema = document.get("schema")
    if schema != SCHEMA:
        raise BridgeError(f"the integration registry has schema {schema!r}, expected {SCHEMA!r}")
    if document.get("classification") != "FRAME":
        raise BridgeError("the integration registry is infrastructure, not native FORM")
    raw_bridges = document.get("bridges")
    if not isinstance(raw_bridges, list):
        raise BridgeError("the integration registry must carry a 'bridges' list")
    return tuple(_parse_bridge(raw) for raw in raw_bridges)


def bridges(path: Path | None = None) -> tuple[Bridge, ...]:
    """Return every declared bridge."""
    return load_bridges(path)


def bridge_by_endpoints(
    source: str, target: str, path: Path | None = None
) -> Bridge:
    """Return the bridge declared between two fields.

    Raises
    ------
    KeyError
        If no bridge joins those endpoints.
    """
    for bridge in load_bridges(path):
        if bridge.source == source and bridge.target == target:
            return bridge
    raise KeyError(f"no bridge is declared between {source!r} and {target!r}")
