"""The ecosystem registry: one record per repository the portal explains.

This module is the Python half of a single source of truth. The Lean
``Hyperfields.Registry`` module declares the records, and
``Hyperfields.Manifest`` renders them to ``ecosystem.json``. This module
*reads* that rendered file. It does not re-declare a single field.

That is the whole point. An earlier draft of this module carried its own
``_ROLES``, ``_MODES``, ``_SUMMARIES`` and ``_DISPLAY_NAMES`` tables. Those
tables were a second copy of the catalogue, and they had already drifted:
the Python copy listed one operating mode per repository where the Lean
registry records one or two, and it carried summaries the catalogue never
published. A registry with two copies of the truth is a registry that will
publish one of them.

So the record is *loaded* from the manifest, and the loader is strict. If the
manifest is missing, unreadable, or internally inconsistent, loading raises.
It never falls back to a default and it never quietly drops an entry.

The record keeps five distinctions separate, exactly as the Lean types do:

1. What kind of ecosystem artifact this is.
2. Whether its presentation is field-primitive, grounded in another field, or
   still unresolved.
3. How it operates: formatively, communicatively, compositionally,
   integratively, or reflectively.
4. How far this catalogue entry itself has been reviewed.
5. Whether its source is a public pinned revision, a public repository with
   no pinned main, or an unpublished local candidate.

Every one of these is a closed enumeration, so a misspelling is a type error
rather than free text that the portal renders as a claim.
"""

from __future__ import annotations

import enum
import json
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Final

#: The manifest file, relative to the repository root.
MANIFEST_RELPATH: Final[str] = "ecosystem.json"

#: The repository root when the package is used from a source checkout. Used
#: only to locate the manifest, which is a build product of the Lean
#: registry and lives at the repository root rather than inside the package.
_REPO_ROOT: Final[Path] = Path(__file__).resolve().parent.parent.parent


class Role(str, enum.Enum):
    """A repository's role in the ecosystem map.

    The role is independent of whether the structure the repository presents
    is grounded in another field.
    """

    HYPERFIELD = "hyperfield"
    GROUNDED_LAYER = "grounded-layer"
    STRUCTURAL_HUB = "structural-hub"
    ORDINAL_INFRASTRUCTURE = "ordinal-infrastructure"
    META_FRAMEWORK = "meta-framework"


class Grounding(str, enum.Enum):
    """How a field's presentation relates to upstream structure.

    Grounding is relative to the presentation recorded here.
    ``FIELD_PRIMITIVE`` means "presented as primitive inside this field", not
    "proved absolutely primitive in reality".
    """

    FIELD_PRIMITIVE = "field-primitive"
    GROUNDED = "grounded"
    UNRESOLVED = "unresolved"


class OperatingMode(str, enum.Enum):
    """How a field operates."""

    FORMATIVE = "formative"
    COMMUNICATIVE = "communicative"
    COMPOSITIONAL = "compositional"
    INTEGRATIVE = "integrative"
    REFLECTIVE = "reflective"


class ReviewState(str, enum.Enum):
    """How far this catalogue entry itself has been reviewed.

    Every explanation begins as ``SOURCE_DERIVED_UNREVIEWED``. The owner's
    review, not the compiler's, is the gate for moving an entry to
    ``OWNER_REVIEWED``.
    """

    SOURCE_DERIVED_UNREVIEWED = "source-derived-unreviewed"
    OWNER_REVIEWED = "owner-reviewed"


class SourceState(str, enum.Enum):
    """Where an entry's source lives.

    ``PUBLIC_MAIN_PINNED`` means the entry names an exact public revision.
    ``PUBLIC_WITHOUT_MAIN`` means the repository is public but no ``main``
    revision is pinned, so the entry must not claim one.
    ``LOCAL_CANDIDATE_UNPUBLISHED`` means there is no public source at all.
    """

    PUBLIC_MAIN_PINNED = "public-main-pinned"
    PUBLIC_WITHOUT_MAIN = "public-without-main"
    LOCAL_CANDIDATE_UNPUBLISHED = "local-candidate-unpublished"


class ManifestError(RuntimeError):
    """Raised when the manifest is missing, unreadable, or inconsistent."""


@dataclass(frozen=True, slots=True)
class SourceCoordinate:
    """An exact public source coordinate.

    ``revision`` is optional because a public repository can exist without a
    resolvable ``main`` commit. The repository URL alone is still a true
    claim; inventing a revision for it would not be.
    """

    repository: str
    revision: str | None = None

    @property
    def is_pinned(self) -> bool:
        """Whether this coordinate names an exact commit."""
        return self.revision is not None


@dataclass(frozen=True, slots=True)
class Entry:
    """One repository the portal explains."""

    id: str
    slug: str
    display_name: str
    module: str
    role: Role
    grounding: Grounding
    grounding_text: str
    grounding_bases: tuple[str, ...]
    modes: tuple[OperatingMode, ...]
    summary: str
    review: ReviewState
    source_state: SourceState
    source: SourceCoordinate | None

    def __post_init__(self) -> None:
        if not self.id or not self.slug or not self.display_name or not self.module:
            raise ValueError("an entry needs an id, a slug, a display name, and a module")
        if not self.summary.strip():
            raise ValueError("an entry needs a summary")
        if not self.modes:
            raise ValueError("an entry needs at least one operating mode")
        if len(set(self.modes)) != len(self.modes):
            raise ValueError("an entry must not repeat an operating mode")
        pinned = self.source_state is SourceState.PUBLIC_MAIN_PINNED
        without_main = self.source_state is SourceState.PUBLIC_WITHOUT_MAIN
        if pinned and self.source is None:
            raise ValueError("a public-main-pinned entry needs a source coordinate")
        if pinned and self.source is not None and not self.source.is_pinned:
            raise ValueError("a public-main-pinned entry needs an exact revision")
        if without_main and self.source is not None and self.source.is_pinned:
            raise ValueError(
                "a public-without-main entry must not claim a revision it cannot honour"
            )
        if not pinned and not without_main and self.source is not None:
            raise ValueError(
                f"a {self.source_state.value} entry must not carry a source coordinate"
            )
        if self.source is not None:
            if not self.source.repository.startswith("https://github.com/TimeLordRaps/"):
                raise ValueError("a source coordinate must name a TimeLordRaps repository")
            if self.source.revision is not None:
                if len(self.source.revision) != 40 or not all(
                    character in "0123456789abcdef" for character in self.source.revision
                ):
                    raise ValueError(
                        "a pinned revision must be a full 40-character lowercase SHA"
                    )
        grounded = self.grounding is Grounding.GROUNDED
        if grounded and not self.grounding_bases:
            raise ValueError("a grounded entry must name at least one base field")
        if not grounded and self.grounding_bases:
            raise ValueError("only a grounded entry may name base fields")

    @property
    def is_public(self) -> bool:
        """Whether this entry has any public source."""
        return self.source_state is not SourceState.LOCAL_CANDIDATE_UNPUBLISHED

    @property
    def is_pinned(self) -> bool:
        """Whether this entry names an exact public commit."""
        return self.source_state is SourceState.PUBLIC_MAIN_PINNED


def default_manifest_path() -> Path:
    """Return the manifest path for a source checkout of this repository.

    The manifest is a build product of the Lean registry, so it lives at the
    repository root rather than inside the installed package.
    """
    return _REPO_ROOT / MANIFEST_RELPATH


def _require(entry: dict[str, Any], field: str, slug: str) -> Any:
    """Return a required field from a manifest entry, or raise."""
    if field not in entry:
        raise ManifestError(f"manifest entry {slug!r} lacks the field {field!r}")
    return entry[field]


def _parse_entry(raw: dict[str, Any]) -> Entry:
    """Turn one manifest record into an :class:`Entry`.

    Raises
    ------
    ManifestError
        If any field is missing or names a value outside the closed
        enumerations. A manifest that cannot be parsed is a failure, not a
        reason to drop the entry.
    """
    slug = str(raw.get("slug", "<unknown>"))
    try:
        role = Role(_require(raw, "role", slug))
        grounding = Grounding(_require(raw, "groundingKind", slug))
        review = ReviewState(_require(raw, "reviewState", slug))
        source_state = SourceState(_require(raw, "sourceState", slug))
    except ValueError as exc:
        raise ManifestError(f"manifest entry {slug!r} has an unknown value: {exc}") from exc

    raw_modes = _require(raw, "modes", slug)
    if not isinstance(raw_modes, list):
        raise ManifestError(f"manifest entry {slug!r} must carry a list of modes")
    try:
        modes = tuple(OperatingMode(mode) for mode in raw_modes)
    except ValueError as exc:
        raise ManifestError(f"manifest entry {slug!r} has an unknown mode: {exc}") from exc

    raw_bases = _require(raw, "groundingBases", slug)
    if not isinstance(raw_bases, list):
        raise ManifestError(f"manifest entry {slug!r} must carry a list of grounding bases")
    bases = tuple(str(base) for base in raw_bases)

    raw_repository = raw.get("repository")
    raw_revision = raw.get("revision")
    source: SourceCoordinate | None = None
    if raw_repository is not None:
        source = SourceCoordinate(
            repository=str(raw_repository),
            revision=None if raw_revision is None else str(raw_revision),
        )

    module = str(_require(raw, "module", slug))
    return Entry(
        id=module,
        slug=slug,
        display_name=str(_require(raw, "displayName", slug)),
        module=module,
        role=role,
        grounding=grounding,
        grounding_text=str(_require(raw, "grounding", slug)),
        grounding_bases=bases,
        modes=modes,
        summary=str(_require(raw, "summary", slug)),
        review=review,
        source_state=source_state,
        source=source,
    )


def load_manifest(path: Path | None = None) -> tuple[Entry, ...]:
    """Load the registry from the Lean-rendered manifest.

    Parameters
    ----------
    path
        The manifest to read. Defaults to the repository root's
        ``ecosystem.json``.

    Returns
    -------
    tuple[Entry, ...]
        Every entry, in the order the manifest lists them.

    Raises
    ------
    ManifestError
        If the manifest is missing, is not valid JSON, has the wrong schema
        version, or carries an entry that cannot be parsed.
    """
    manifest_path = default_manifest_path() if path is None else Path(path)
    try:
        raw_text = manifest_path.read_text(encoding="utf-8")
    except OSError as exc:
        raise ManifestError(f"the manifest at {manifest_path} is unreadable: {exc}") from exc
    try:
        document = json.loads(raw_text)
    except json.JSONDecodeError as exc:
        raise ManifestError(f"the manifest at {manifest_path} is not valid JSON: {exc}") from exc
    if not isinstance(document, dict):
        raise ManifestError("the manifest must be a JSON object")
    if document.get("schemaVersion") != 1:
        raise ManifestError(
            f"the manifest has schemaVersion {document.get('schemaVersion')!r}, expected 1"
        )
    raw_entries = document.get("entries")
    if not isinstance(raw_entries, list):
        raise ManifestError("the manifest must carry an 'entries' list")
    entries = tuple(_parse_entry(raw) for raw in raw_entries)
    slugs = [entry.slug for entry in entries]
    if len(set(slugs)) != len(slugs):
        raise ManifestError("the manifest contains duplicate slugs")
    modules = [entry.module for entry in entries]
    if len(set(modules)) != len(modules):
        raise ManifestError("the manifest contains duplicate module names")
    return entries


def entries(path: Path | None = None) -> tuple[Entry, ...]:
    """Return every registry entry, loading the manifest if needed."""
    return load_manifest(path)


def by_slug(slug: str, path: Path | None = None) -> Entry:
    """Return the entry with the given slug.

    Raises
    ------
    KeyError
        If no entry carries that slug.
    """
    for entry in load_manifest(path):
        if entry.slug == slug:
            return entry
    raise KeyError(f"no registry entry carries the slug {slug!r}")


def by_module(module: str, path: Path | None = None) -> Entry:
    """Return the entry explained by the given Lean module.

    Raises
    ------
    KeyError
        If no entry names that module.
    """
    for entry in load_manifest(path):
        if entry.module == module:
            return entry
    raise KeyError(f"no registry entry names the module {module!r}")


def public_entries(path: Path | None = None) -> tuple[Entry, ...]:
    """Return every entry that has a public source."""
    return tuple(entry for entry in load_manifest(path) if entry.is_public)


def candidate_entries(path: Path | None = None) -> tuple[Entry, ...]:
    """Return every unpublished local candidate."""
    return tuple(
        entry
        for entry in load_manifest(path)
        if entry.source_state is SourceState.LOCAL_CANDIDATE_UNPUBLISHED
    )


def entries_by_role(role: Role, path: Path | None = None) -> tuple[Entry, ...]:
    """Return every entry with the given role."""
    return tuple(entry for entry in load_manifest(path) if entry.role is role)
