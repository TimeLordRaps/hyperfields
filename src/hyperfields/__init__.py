"""Typed objects for the hyperfields ecosystem.

This package is the Python half of the hyperfields catalogue. It reads the
Lean registry rather than restating it, so the catalogue has one source of
truth and the two halves cannot drift.

The public surface is deliberately small:

* :mod:`hyperfields.registry` -- the ecosystem entries, loaded from the
  Lean-rendered manifest.
* :mod:`hyperfields.bridges` -- the cross-field integration bridges, as
  typed records that preserve their ``OPEN`` status.
* :mod:`hyperfields.candidates` -- the five unpublished field candidates and
  the properties their Lean modules establish.

Nothing here asserts a physical or metaphysical claim. Every module in this
package carries the ``[FRAME]`` classification that the candidate fields
themselves carry: these are finite, checkable descriptions whose scope is
bounded by the record they come from.
"""

from __future__ import annotations

from hyperfields.bridges import (
    Bridge,
    BridgeRelation,
    BridgeStatus,
    load_bridges,
)
from hyperfields.candidates import (
    CandidateField,
    candidate_by_slug,
    candidate_fields,
)
from hyperfields.registry import (
    Entry,
    Grounding,
    ManifestError,
    OperatingMode,
    ReviewState,
    Role,
    SourceCoordinate,
    SourceState,
    by_module,
    by_slug,
    candidate_entries,
    entries,
    entries_by_role,
    load_manifest,
    public_entries,
)

__version__ = "0.1.0"

__all__ = [
    "Bridge",
    "BridgeRelation",
    "BridgeStatus",
    "CandidateField",
    "Entry",
    "Grounding",
    "ManifestError",
    "OperatingMode",
    "ReviewState",
    "Role",
    "SourceCoordinate",
    "SourceState",
    "__version__",
    "by_module",
    "by_slug",
    "candidate_by_slug",
    "candidate_entries",
    "candidate_fields",
    "entries",
    "entries_by_role",
    "load_bridges",
    "load_manifest",
    "public_entries",
]
