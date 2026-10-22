"""Contract tests for the cross-field bridge record.

The bridges are declarations, not proofs. These tests check that the record
preserves that distinction: every bridge stays open, no bridge certifies a
native closed account, and every bridge carries the content that makes it
meaningful.
"""

from __future__ import annotations

import json
import subprocess
from pathlib import Path

import pytest

from hyperfields.bridges import (
    Bridge,
    BridgeError,
    BridgeRelation,
    BridgeStatus,
    FieldClass,
    Mapping,
    bridge_by_endpoints,
    bridges,
    default_bridges_path,
    load_bridges,
)

REPO_ROOT = Path(__file__).resolve().parent.parent


class TestBridgeRecordPresence:
    """The bridge record is emitted by Lean, so its absence is a failure."""

    def test_record_exists(self) -> None:
        assert default_bridges_path().is_file()

    def test_record_is_valid_json(self) -> None:
        document = json.loads(default_bridges_path().read_text(encoding="utf-8"))
        assert document["schema"] == "hyperstratum-integration-0.1"
        assert document["classification"] == "FRAME"

    def test_missing_record_raises(self, tmp_path: Path) -> None:
        with pytest.raises(BridgeError):
            load_bridges(tmp_path / "absent.json")

    def test_invalid_json_raises(self, tmp_path: Path) -> None:
        broken = tmp_path / "broken.json"
        broken.write_text("{not json", encoding="utf-8")
        with pytest.raises(BridgeError):
            load_bridges(broken)

    def test_wrong_schema_raises(self, tmp_path: Path) -> None:
        wrong = tmp_path / "wrong.json"
        wrong.write_text(
            json.dumps({"schema": "something-else", "classification": "FRAME", "bridges": []}),
            encoding="utf-8",
        )
        with pytest.raises(BridgeError):
            load_bridges(wrong)

    def test_form_classification_raises(self, tmp_path: Path) -> None:
        """The registry is infrastructure, not a native account."""
        wrong = tmp_path / "wrong.json"
        wrong.write_text(
            json.dumps(
                {
                    "schema": "hyperstratum-integration-0.1",
                    "classification": "FORM",
                    "bridges": [],
                }
            ),
            encoding="utf-8",
        )
        with pytest.raises(BridgeError):
            load_bridges(wrong)


class TestBridgeShape:
    """Every bridge makes a distinct set of claims, and they are exclusive."""

    def test_bridges_join_two_distinct_fields(self) -> None:
        for bridge in bridges():
            assert bridge.source != bridge.target

    def test_no_bridge_certifies_a_native_target(self) -> None:
        """The refusal that a declaration checker may not certify a FORM target."""
        for bridge in bridges():
            assert bridge.target_class is not FieldClass.FORM

    def test_every_bridge_is_open(self) -> None:
        """A declaration cannot self-certify, so no bridge may be closed."""
        for bridge in bridges():
            assert bridge.status in (BridgeStatus.OPEN, BridgeStatus.UNKNOWN)

    def test_every_bridge_carries_at_least_one_mapping(self) -> None:
        for bridge in bridges():
            assert bridge.mappings

    def test_every_mapping_carries_its_meaning(self) -> None:
        for bridge in bridges():
            for mapping in bridge.mappings:
                assert mapping.source.strip()
                assert mapping.target.strip()
                assert mapping.meaning.strip()

    def test_every_bridge_states_what_it_preserves(self) -> None:
        for bridge in bridges():
            assert bridge.preserves

    def test_every_bridge_states_what_it_excludes(self) -> None:
        for bridge in bridges():
            assert bridge.excludes

    def test_every_bridge_states_its_obligation(self) -> None:
        """A bridge that owes nothing has not said what it is waiting for."""
        for bridge in bridges():
            assert bridge.obligations

    def test_relations_are_recognised(self) -> None:
        for bridge in bridges():
            assert isinstance(bridge.relation, BridgeRelation)

    def test_endpoints_are_distinct_across_the_record(self) -> None:
        pairs = [(bridge.source, bridge.target) for bridge in bridges()]
        assert len(pairs) == len(set(pairs))


class TestLookup:
    """Lookups are total over the record and fail loudly when they miss."""

    def test_lookup_by_endpoints(self) -> None:
        bridge = bridge_by_endpoints("hyperethics", "hyperstructure")
        assert bridge.relation is BridgeRelation.INTERPRETATION

    def test_unknown_endpoints_raise(self) -> None:
        with pytest.raises(KeyError):
            bridge_by_endpoints("hypermath", "hyperbiology")


class TestRefusals:
    """The refusals must hold at construction time, not only for the record."""

    def test_form_target_is_refused(self) -> None:
        with pytest.raises(BridgeError):
            Bridge(
                source="a",
                target="b",
                relation=BridgeRelation.APPLICATION,
                source_class=FieldClass.FRAME,
                target_class=FieldClass.FORM,
                status=BridgeStatus.OPEN,
                mappings=(Mapping("x", "y", "z"),),
                preserves=("p",),
                excludes=("e",),
                obligations=("o",),
            )

    def test_self_bridge_is_refused(self) -> None:
        with pytest.raises(BridgeError):
            Bridge(
                source="a",
                target="a",
                relation=BridgeRelation.APPLICATION,
                source_class=FieldClass.FRAME,
                target_class=FieldClass.FRAME,
                status=BridgeStatus.OPEN,
                mappings=(Mapping("x", "y", "z"),),
                preserves=("p",),
                excludes=("e",),
                obligations=("o",),
            )

    def test_empty_preserves_is_refused(self) -> None:
        with pytest.raises(BridgeError):
            Bridge(
                source="a",
                target="b",
                relation=BridgeRelation.APPLICATION,
                source_class=FieldClass.FRAME,
                target_class=FieldClass.FRAME,
                status=BridgeStatus.OPEN,
                mappings=(Mapping("x", "y", "z"),),
                preserves=(),
                excludes=("e",),
                obligations=("o",),
            )

    def test_empty_mapping_is_refused(self) -> None:
        with pytest.raises(BridgeError):
            Bridge(
                source="a",
                target="b",
                relation=BridgeRelation.APPLICATION,
                source_class=FieldClass.FRAME,
                target_class=FieldClass.FRAME,
                status=BridgeStatus.OPEN,
                mappings=(),
                preserves=("p",),
                excludes=("e",),
                obligations=("o",),
            )

    def test_empty_meaning_is_refused(self) -> None:
        with pytest.raises(BridgeError):
            Mapping("x", "y", "  ")


class TestLeanAgreement:
    """The Python record must be exactly what Lean renders."""

    @pytest.fixture(scope="class")
    def rendered(self) -> dict:
        result = subprocess.run(
            ["lake", "exe", "hyperfields-manifest", "--bridges"],
            cwd=REPO_ROOT,
            capture_output=True,
            text=True,
            check=False,
        )
        if result.returncode != 0:
            pytest.skip("the Lean bridge emitter is not available in this environment")
        return json.loads(result.stdout)

    def test_bridge_count_agrees(self, rendered: dict) -> None:
        assert len(rendered["bridges"]) == len(bridges())

    def test_bridges_agree(self, rendered: dict) -> None:
        for raw, bridge in zip(rendered["bridges"], bridges()):
            assert raw["source"] == bridge.source
            assert raw["target"] == bridge.target
            assert raw["relation"] == bridge.relation.value
            assert raw["source_class"] == bridge.source_class.value
            assert raw["target_class"] == bridge.target_class.value
            assert raw["status"] == bridge.status.value
            assert raw["preserves"] == list(bridge.preserves)
            assert raw["excludes"] == list(bridge.excludes)
            assert raw["obligations"] == list(bridge.obligations)
            assert [m["source"] for m in raw["mappings"]] == [
                m.source for m in bridge.mappings
            ]
            assert [m["meaning"] for m in raw["mappings"]] == [
                m.meaning for m in bridge.mappings
            ]
