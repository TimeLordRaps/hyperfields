"""Contract tests for the unpublished field candidates.

Five repositories have no public source. These tests check that the
candidate list and the catalogue agree, and that no candidate has been
quietly promoted to a stronger claim.
"""

from __future__ import annotations

import pytest

from hyperfields.candidates import (
    CandidateField,
    candidate_by_slug,
    candidate_entry,
    candidate_fields,
    candidate_slugs,
)
from hyperfields.registry import SourceState, by_slug, entries


class TestCandidateList:
    """The candidate list is a contract with the catalogue."""

    def test_every_candidate_is_in_the_catalogue(self) -> None:
        for candidate in candidate_fields():
            entry = candidate_entry(candidate)
            assert entry.source_state is SourceState.LOCAL_CANDIDATE_UNPUBLISHED

    def test_every_catalogue_candidate_is_in_the_list(self) -> None:
        catalogue_candidates = {
            entry.slug
            for entry in entries()
            if entry.source_state is SourceState.LOCAL_CANDIDATE_UNPUBLISHED
        }
        assert catalogue_candidates == set(candidate_slugs())

    def test_candidate_slugs_are_distinct(self) -> None:
        slugs = candidate_slugs()
        assert len(slugs) == len(set(slugs))

    def test_lean_modules_are_distinct(self) -> None:
        modules = [candidate.lean_module for candidate in candidate_fields()]
        assert len(modules) == len(set(modules))

    def test_every_candidate_names_a_lean_module(self) -> None:
        for candidate in candidate_fields():
            assert candidate.lean_module.startswith("Hyperfields.Fields.")

    def test_every_candidate_has_local_sources(self) -> None:
        for candidate in candidate_fields():
            assert candidate.local_sources


class TestClassification:
    """No candidate may claim more than it has."""

    def test_every_candidate_is_a_frame(self) -> None:
        for candidate in candidate_fields():
            assert candidate.classification == "FRAME"

    def test_a_candidate_cannot_claim_a_stronger_classification(self) -> None:
        with pytest.raises(ValueError):
            CandidateField(
                slug="example",
                lean_module="Hyperfields.Fields.Example",
                subject="An example.",
                local_sources=("example.py",),
                classification="FORM",
            )

    def test_a_candidate_needs_a_subject(self) -> None:
        with pytest.raises(ValueError):
            CandidateField(
                slug="example",
                lean_module="Hyperfields.Fields.Example",
                subject="  ",
                local_sources=("example.py",),
            )

    def test_a_candidate_needs_local_sources(self) -> None:
        with pytest.raises(ValueError):
            CandidateField(
                slug="example",
                lean_module="Hyperfields.Fields.Example",
                subject="An example.",
                local_sources=(),
            )


class TestLookup:
    """Lookups are total over the candidate list."""

    def test_lookup_by_slug(self) -> None:
        candidate = candidate_by_slug("hypertopology")
        assert candidate.lean_module == "Hyperfields.Fields.Hypertopology"

    def test_unknown_slug_raises(self) -> None:
        with pytest.raises(KeyError):
            candidate_by_slug("no-such-candidate")

    def test_candidate_entry_matches_the_catalogue(self) -> None:
        candidate = candidate_by_slug("hyperdynamics")
        assert candidate_entry(candidate) == by_slug("hyperdynamics")
