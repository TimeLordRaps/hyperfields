"""Contract tests for the hyperfields registry.

These tests check the *contract* the registry promises, not the specific
values it happens to hold today. A test that asserted "there are 28 entries"
would pass even if the catalogue had drifted to 27, because the number would
be hard-coded on both sides. These tests instead check the properties that
must hold for any correct catalogue, and they check the *consistency*
between the Lean registry, the manifest it renders, and the Python record
that reads the manifest.
"""

from __future__ import annotations

import json
import subprocess
from pathlib import Path

import pytest

from hyperfields.registry import (
    Grounding,
    ManifestError,
    ReviewState,
    Role,
    SourceState,
    by_module,
    by_slug,
    candidate_entries,
    default_manifest_path,
    entries,
    entries_by_role,
    load_manifest,
    public_entries,
)

REPO_ROOT = Path(__file__).resolve().parent.parent


class TestManifestPresence:
    """The manifest is a build product, so its absence is a failure."""

    def test_manifest_exists(self) -> None:
        assert default_manifest_path().is_file()

    def test_manifest_is_valid_json(self) -> None:
        document = json.loads(default_manifest_path().read_text(encoding="utf-8"))
        assert document["schemaVersion"] == 1
        assert isinstance(document["entries"], list)

    def test_missing_manifest_raises(self, tmp_path: Path) -> None:
        with pytest.raises(ManifestError):
            load_manifest(tmp_path / "absent.json")

    def test_invalid_json_raises(self, tmp_path: Path) -> None:
        broken = tmp_path / "broken.json"
        broken.write_text("{not json", encoding="utf-8")
        with pytest.raises(ManifestError):
            load_manifest(broken)

    def test_wrong_schema_version_raises(self, tmp_path: Path) -> None:
        wrong = tmp_path / "wrong.json"
        wrong.write_text(json.dumps({"schemaVersion": 2, "entries": []}), encoding="utf-8")
        with pytest.raises(ManifestError):
            load_manifest(wrong)

    def test_missing_entries_list_raises(self, tmp_path: Path) -> None:
        wrong = tmp_path / "wrong.json"
        wrong.write_text(json.dumps({"schemaVersion": 1}), encoding="utf-8")
        with pytest.raises(ManifestError):
            load_manifest(wrong)


class TestCatalogueShape:
    """The catalogue's shape is a contract, not a constant."""

    def test_every_entry_has_a_distinct_slug(self) -> None:
        slugs = [entry.slug for entry in entries()]
        assert len(slugs) == len(set(slugs))

    def test_every_entry_has_a_distinct_module(self) -> None:
        modules = [entry.module for entry in entries()]
        assert len(modules) == len(set(modules))

    def test_every_entry_has_a_distinct_display_name(self) -> None:
        names = [entry.display_name for entry in entries()]
        assert len(names) == len(set(names))

    def test_every_entry_declares_at_least_one_mode(self) -> None:
        for entry in entries():
            assert entry.modes, f"{entry.slug} declares no operating mode"

    def test_no_entry_repeats_a_mode(self) -> None:
        for entry in entries():
            assert len(set(entry.modes)) == len(entry.modes)

    def test_every_entry_has_a_summary(self) -> None:
        for entry in entries():
            assert entry.summary.strip()

    def test_every_entry_is_unreviewed(self) -> None:
        """No explanation may claim owner review without the owner."""
        for entry in entries():
            assert entry.review is ReviewState.SOURCE_DERIVED_UNREVIEWED

    def test_every_role_is_recognised(self) -> None:
        for entry in entries():
            assert isinstance(entry.role, Role)

    def test_every_grounding_is_recognised(self) -> None:
        for entry in entries():
            assert isinstance(entry.grounding, Grounding)


class TestSourceStates:
    """Each source state makes a different claim, and the claims are exclusive."""

    def test_pinned_entries_carry_an_exact_revision(self) -> None:
        for entry in entries():
            if entry.source_state is SourceState.PUBLIC_MAIN_PINNED:
                assert entry.source is not None
                assert entry.source.is_pinned
                revision = entry.source.revision
                assert revision is not None
                assert len(revision) == 40
                assert all(character in "0123456789abcdef" for character in revision)

    def test_without_main_entries_carry_no_revision(self) -> None:
        for entry in entries():
            if entry.source_state is SourceState.PUBLIC_WITHOUT_MAIN:
                assert entry.source is not None
                assert not entry.source.is_pinned

    def test_unpublished_candidates_carry_no_coordinate(self) -> None:
        for entry in entries():
            if entry.source_state is SourceState.LOCAL_CANDIDATE_UNPUBLISHED:
                assert entry.source is None

    def test_public_and_candidate_counts_are_disjoint(self) -> None:
        all_entries = entries()
        public = public_entries()
        candidates = candidate_entries()
        assert len(public) + len(candidates) == len(all_entries)
        assert not set(public) & set(candidates)

    def test_every_repository_is_a_timeLordRaps_repository(self) -> None:
        for entry in entries():
            if entry.source is not None:
                assert entry.source.repository.startswith(
                    "https://github.com/TimeLordRaps/"
                )


class TestGrounding:
    """Grounding is relative to the presentation, and the bases are explicit."""

    def test_grounded_entries_name_their_bases(self) -> None:
        for entry in entries():
            if entry.grounding is Grounding.GROUNDED:
                assert entry.grounding_bases

    def test_ungrounded_entries_name_no_bases(self) -> None:
        for entry in entries():
            if entry.grounding is not Grounding.GROUNDED:
                assert not entry.grounding_bases

    def test_grounding_text_is_published(self) -> None:
        for entry in entries():
            assert entry.grounding_text.strip()

    def test_grounding_text_names_the_bases(self) -> None:
        """The prose form must actually mention each base it declares."""
        for entry in entries():
            for base in entry.grounding_bases:
                assert base in entry.grounding_text


class TestLookups:
    """Lookups are total over the catalogue and fail loudly when they miss."""

    def test_lookup_by_slug(self) -> None:
        entry = by_slug("hypermath")
        assert entry.display_name == "Hypermath"

    def test_lookup_by_module(self) -> None:
        entry = by_module("Hypermath")
        assert entry.slug == "hypermath"

    def test_unknown_slug_raises(self) -> None:
        with pytest.raises(KeyError):
            by_slug("no-such-field")

    def test_unknown_module_raises(self) -> None:
        with pytest.raises(KeyError):
            by_module("NoSuchModule")

    def test_role_lookup_partitions_the_catalogue(self) -> None:
        total = sum(len(entries_by_role(role)) for role in Role)
        assert total == len(entries())


class TestLeanAgreement:
    """The Python record must be exactly what the Lean registry renders."""

    @pytest.fixture(scope="class")
    def rendered(self) -> dict:
        """The manifest as the Lean emitter renders it, or skip if Lean is absent."""
        result = subprocess.run(
            ["lake", "exe", "hyperfields-manifest"],
            cwd=REPO_ROOT,
            capture_output=True,
            text=True,
            check=False,
        )
        if result.returncode != 0:
            pytest.skip("the Lean manifest emitter is not available in this environment")
        return json.loads(result.stdout)

    def test_entry_count_agrees(self, rendered: dict) -> None:
        assert len(rendered["entries"]) == len(entries())

    def test_slugs_agree(self, rendered: dict) -> None:
        assert [entry["slug"] for entry in rendered["entries"]] == [
            entry.slug for entry in entries()
        ]

    def test_fields_agree(self, rendered: dict) -> None:
        for raw, entry in zip(rendered["entries"], entries()):
            assert raw["displayName"] == entry.display_name
            assert raw["module"] == entry.module
            assert raw["role"] == entry.role.value
            assert raw["groundingKind"] == entry.grounding.value
            assert raw["grounding"] == entry.grounding_text
            assert raw["groundingBases"] == list(entry.grounding_bases)
            assert raw["modes"] == [mode.value for mode in entry.modes]
            assert raw["summary"] == entry.summary
            assert raw["sourceState"] == entry.source_state.value
            assert raw["reviewState"] == entry.review.value


class TestManifestDrift:
    """The committed manifest must not drift from the Lean registry."""

    def test_committed_manifest_matches_lean_registry(self) -> None:
        result = subprocess.run(
            ["lake", "exe", "hyperfields-manifest"],
            cwd=REPO_ROOT,
            capture_output=True,
            text=True,
            check=False,
        )
        if result.returncode != 0:
            pytest.skip("the Lean manifest emitter is not available in this environment")
        rendered = json.loads(result.stdout)
        committed = json.loads(default_manifest_path().read_text(encoding="utf-8"))
        assert committed["entries"] == rendered["entries"]
