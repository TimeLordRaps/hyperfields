"""The five unpublished field candidates, and what their Lean modules establish.

Five repositories in the catalogue have no public source yet:
``hypergeometry``, ``hypertopology``, ``hyperstructure``,
``hyperdynamics``, and ``hypermechanics``. Each carries a local Python
implementation, a field specification, and a validation script.

This module records what is known about each of them and points at the Lean
module that checks the corresponding finite structure. It states no property
that the Lean module does not check.

Every candidate is a ``[FRAME]``: a bounded, finite description whose scope
is limited by the record it comes from. None of them asserts a physical,
metaphysical, or absolute claim. The candidates module says so in one place
so that a reader does not have to infer it from five separate files.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Final

from hyperfields.registry import Entry, by_slug


@dataclass(frozen=True, slots=True)
class CandidateField:
    """One unpublished field candidate and its checked Lean module.

    Attributes
    ----------
    slug
        The catalogue slug, which is also the repository directory name.
    lean_module
        The Lean module that checks the candidate's finite structure.
    subject
        What the candidate is about, in one sentence.
    local_sources
        The files inside the candidate repository that carry its content.
    classification
        The candidate's classification. Every candidate is a ``FRAME``.
    """

    slug: str
    lean_module: str
    subject: str
    local_sources: tuple[str, ...]
    classification: str = "FRAME"

    def __post_init__(self) -> None:
        if not self.slug.strip() or not self.lean_module.strip():
            raise ValueError("a candidate needs a slug and a Lean module")
        if not self.subject.strip():
            raise ValueError("a candidate needs a subject")
        if not self.local_sources:
            raise ValueError("a candidate needs at least one local source file")
        if self.classification != "FRAME":
            raise ValueError(
                "every candidate is a FRAME; a candidate that claimed a stronger "
                "classification would be asserting a native account it does not have"
            )


#: The five unpublished candidates, and the finite structure each one checks.
CANDIDATES: Final[tuple[CandidateField, ...]] = (
    CandidateField(
        slug="hypergeometry",
        lean_module="Hyperfields.Fields.Hypergeometry",
        subject="Exact finite chart geometry with exact path transport.",
        local_sources=("hypergeometry.py", "FIELD_SPEC.md", "validate.py"),
    ),
    CandidateField(
        slug="hypertopology",
        lean_module="Hyperfields.Fields.Hypertopology",
        subject="Finite opens, closure, interior, boundary, and continuity.",
        local_sources=("hypertopology.py", "FIELD_SPEC.md", "validate.py"),
    ),
    CandidateField(
        slug="hyperstructure",
        lean_module="Hyperfields.Fields.Hyperstructure",
        subject="Typed structures, components, kind assignment, and presentation isomorphism.",
        local_sources=("hyperstructure.py", "FIELD_SPEC.md", "validate.py"),
    ),
    CandidateField(
        slug="hyperdynamics",
        lean_module="Hyperfields.Fields.Hyperdynamics",
        subject="Transitions, path lifting, and coupled products under explicit indices.",
        local_sources=("hyperdynamics.py", "FIELD_SPEC.md", "validate.py"),
    ),
    CandidateField(
        slug="hypermechanics",
        lean_module="Hyperfields.Fields.Hypermechanics",
        subject="Guarded rewrites, exact conservation, and connection rules.",
        local_sources=("hypermechanics.py", "FIELD_SPEC.md", "validate.py"),
    ),
)


def candidate_fields() -> tuple[CandidateField, ...]:
    """Return every unpublished candidate with its checked Lean module."""
    return CANDIDATES


def candidate_by_slug(slug: str) -> CandidateField:
    """Return the candidate with the given slug.

    Raises
    ------
    KeyError
        If no candidate carries that slug.
    """
    for candidate in CANDIDATES:
        if candidate.slug == slug:
            return candidate
    raise KeyError(f"no candidate field carries the slug {slug!r}")


def candidate_entry(candidate: CandidateField) -> Entry:
    """Return the catalogue entry for a candidate.

    Raises
    ------
    KeyError
        If the candidate is not in the catalogue, which would mean the Lean
        registry and the candidate list have drifted.
    """
    return by_slug(candidate.slug)


def candidate_slugs() -> tuple[str, ...]:
    """Return the slug of every unpublished candidate."""
    return tuple(candidate.slug for candidate in CANDIDATES)
