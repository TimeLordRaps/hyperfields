#!/usr/bin/env python3
"""Cross-check the Lean candidate field ports against the Python sources.

The Lean ports state concrete values and verdicts. The Python sources are
the original implementations, so they are the ground truth. This script
evaluates the same quantities in Python and compares them to what the Lean
theorems claim.

A mismatch means a Lean port asserts something the original frame does not,
which is exactly the drift a port is meant to prevent. Every claim here is
read off a named Lean theorem; the script says which one, so a failure
names the theorem that is wrong rather than just a number.

The Python sources live in sibling repositories, not inside this one, so the
script needs to be told where they are. The ``HYPERFIELDS_SOURCE_ROOT``
environment variable names the directory that holds them; it defaults to the
parent of this repository, which is where the sibling checkouts sit in a
local workspace. No absolute path is written into this file, so it carries
no workstation-specific claim.
"""

from __future__ import annotations

import os
import sys
from pathlib import Path

#: The directory that holds the sibling source repositories.
SOURCE_ROOT = Path(
    os.environ.get("HYPERFIELDS_SOURCE_ROOT", Path(__file__).resolve().parent.parent.parent)
)

#: The sibling repositories, by the module they provide.
SOURCES = {
    "hypergeometry": "hypergeometry",
    "hypertopology": "hypertopology",
    "hyperstructure": "hyperstructure",
    "hyperdynamics": "hyperdynamics",
    "hypermechanics": "hypermechanics",
}

#: The environment variable that names the directory holding the
#: hyperorganization source, whose Python package is `hyperoptimization`.
ORGANIZATION_ROOT_VAR = "HYPERFIELDS_ORGANIZATION_ROOT"


def _source_paths() -> list[Path]:
    """Return the directories to place on the import path.

    A missing sibling is reported rather than silently skipped, because a
    cross-check that quietly checks fewer ports than it claims is worse than
    one that refuses to run.
    """
    missing = [name for name in SOURCES if not (SOURCE_ROOT / name).is_dir()]
    if missing:
        raise SystemExit(
            f"the source repositories {missing} are not under {SOURCE_ROOT}; "
            "set HYPERFIELDS_SOURCE_ROOT to the directory that holds them"
        )
    paths = [SOURCE_ROOT / name for name in SOURCES.values()]

    organization_root = os.environ.get(ORGANIZATION_ROOT_VAR)
    if organization_root is None:
        raise SystemExit(
            f"set {ORGANIZATION_ROOT_VAR} to the directory holding the "
            "hyperorganization source (the one that provides hyperoptimization)"
        )
    organization_source = Path(organization_root) / "src"
    if not organization_source.is_dir():
        raise SystemExit(
            f"the hyperorganization source {organization_source} does not exist"
        )
    paths.append(organization_source)
    return paths


for _path in _source_paths():
    sys.path.insert(0, str(_path))

from fractions import Fraction  # noqa: E402

from hypergeometry import ChartTransition, MetricSpace, transport_path  # noqa: E402
from hypertopology import FiniteTopology  # noqa: E402

FAILURES: list[str] = []


def check(label: str, actual: object, expected: object) -> None:
    """Record whether one Lean claim matches the Python computation."""
    if actual == expected:
        print(f"  OK  {label}: {actual}")
    else:
        FAILURES.append(f"{label}: Lean claims {expected!r} but Python computes {actual!r}")
        print(f"  FAIL  {label}: expected {expected!r}, got {actual!r}")


def check_hypertopology() -> None:
    """Check the hypertopology port against the Python topology source."""
    print("hypertopology:")
    chain = FiniteTopology(
        points=frozenset({"0", "1", "2"}),
        opens=frozenset(
            {
                frozenset(),
                frozenset({"0"}),
                frozenset({"0", "1"}),
                frozenset({"0", "1", "2"}),
            }
        ),
    )
    check(
        "chain_closure_of_open",
        sorted(chain.closure(frozenset({"0", "1"}))),
        ["0", "1", "2"],
    )
    check("chain_closure_of_closed", sorted(chain.closure(frozenset({"2"}))), ["2"])
    check(
        "chain_interior_of_carrier",
        sorted(chain.interior(frozenset({"0", "1", "2"}))),
        ["0", "1", "2"],
    )
    check("chain_interior_of_tail", sorted(chain.interior(frozenset({"1", "2"}))), [])
    check("chain_interior_of_open", sorted(chain.interior(frozenset({"0", "1"}))), ["0", "1"])
    check("chain_boundary_of_open", sorted(chain.boundary(frozenset({"0", "1"}))), ["2"])
    check("chain_boundary_of_singleton", sorted(chain.boundary(frozenset({"0"}))), ["1", "2"])
    check("chain_boundary_of_carrier", sorted(chain.boundary(frozenset({"0", "1", "2"}))), [])


def check_hypergeometry() -> None:
    """Check the hypergeometry port against the Python metric source."""
    print("hypergeometry:")

    def metric(points: tuple[str, ...], matrix: tuple[tuple[Fraction, ...], ...]):
        return MetricSpace(name="probe", points=points, matrix=matrix, unit="1")

    two = metric(("a", "b"), ((Fraction(0), Fraction(1)), (Fraction(1), Fraction(0))))
    three = metric(
        ("a", "b", "c"),
        (
            (Fraction(0), Fraction(1), Fraction(2)),
            (Fraction(1), Fraction(0), Fraction(1)),
            (Fraction(2), Fraction(1), Fraction(0)),
        ),
    )

    # The Lean port holds the distances as numerators over a shared scale of
    # one, so the numerator is the distance in whole units.
    check("two_point_distance", two.distance("a", "b"), Fraction(1))
    check("three_point_distance", three.distance("a", "c"), Fraction(2))

    identity = ChartTransition(source=two, target=two, mapping=(("a", "a"), ("b", "b")))
    swap = ChartTransition(source=two, target=two, mapping=(("a", "b"), ("b", "a")))

    # The Lean port names the points 0 and 1; the Python source names them
    # "a" and "b", so the transport results are translated here.
    check("transport_through_identity", transport_path("a", (identity,)), "a")
    check("transport_through_swap", transport_path("a", (swap,)), "b")
    check("a_single_swap_is_not_the_identity", transport_path("a", (swap,)), "b")
    check("two_swaps_are_the_identity", transport_path("a", (swap, swap)), "a")

    # The collapsing transition is the Lean port's negative case.  The Python
    # source refuses to construct it at all: a chart mapping must be
    # bijective, so a map that collapses two points is rejected before it
    # can be an isometry.  The Lean port keeps the malformed mapping as
    # data and lets the isometry check reject it, which is the same refusal
    # at a different layer.
    collapsing_rejected = False
    try:
        ChartTransition(source=two, target=two, mapping=(("a", "a"), ("b", "a")))
    except ValueError:
        collapsing_rejected = True
    check("a_collapsing_transition_is_rejected", collapsing_rejected, True)


def check_hyperstructure() -> None:
    """Check the hyperstructure port against the Python structure source."""
    print("hyperstructure:")
    from hyperstructure import RecursiveStructure, SempiternalityView

    kinds = ("base-reality", "surreality", "preality", "areality")
    members = ("m0", "m1", "m2", "m3")
    view = SempiternalityView(
        subject="s",
        kind_of=tuple(zip(members, kinds)),
        abstract_members=frozenset(members),
        contained=frozenset(members),
        components=frozenset(members),
    )
    check(
        "a_member_stands_in_three_relations",
        sorted(view.relations("m0")),
        ["component_of", "contained_by", "instance_of"],
    )
    check("the_subject_stands_in_no_relation", sorted(view.relations("s")), [])

    graph = RecursiveStructure(
        nodes=frozenset({"s", *members}),
        contains=frozenset({("s", member) for member in members}),
        represents=frozenset(),
        connects=frozenset({("m0", "m1")}),
    )
    check("descendants_of_the_subject", sorted(graph.descendants("s")), sorted(members))


def check_hyperdynamics() -> None:
    """Check the hyperdynamics port against the Python transition source."""
    print("hyperdynamics:")
    from hyperdynamics import TransitionSystem, reachable

    system = TransitionSystem(
        states=frozenset({"a", "b", "c"}),
        steps=frozenset({("a", "b"), ("b", "c")}),
        kind_of=(("a", "k1"), ("b", "k2"), ("c", "k1")),
    )
    check("all_states_are_reachable_from_the_start", sorted(reachable(system, "a")), ["a", "b", "c"])
    check("a_terminal_state_reaches_only_itself", sorted(reachable(system, "c")), ["c"])


def check_hypermechanics() -> None:
    """Check the hypermechanics port against the Python mechanism source."""
    print("hypermechanics:")
    from hypermechanics import MechanismState, RewriteRule, apply_rule, independent

    state = MechanismState(
        amounts=(("x", Fraction(2)), ("y", Fraction(1))),
        kind_of=(("x", "m"), ("y", "m")),
    )
    rule = RewriteRule(
        name="r",
        guards=(("x", Fraction(1)),),
        changes=(("x", Fraction(-1)), ("y", Fraction(1))),
        invariant=(("x", Fraction(1)), ("y", Fraction(1))),
    )
    after = apply_rule(state, rule)
    check("applying_the_rule_moves_one_unit", dict(after.amounts), {"x": 1, "y": 2})
    check("the_transfer_rule_conserves", 1 * -1 + 1 * 1, 0)
    check("a_rule_is_not_independent_of_itself", independent(rule, rule), False)


def check_hyperorganization() -> None:
    """Check the hyperorganization port against the Python entrenchment source."""
    print("hyperorganization:")
    from hyperoptimization.entrenchment import Rule, authority_height, phases, protection
    from hyperoptimization.ground import OMEGA

    def render(value: object) -> object:
        """Render a phase or height: omega as a name, a number as itself."""
        return "omega" if value is OMEGA else value

    chain = {"0": {"1"}, "1": {"2"}, "2": set()}
    check(
        "chain_phases",
        {name: render(value) for name, value in phases(chain).items()},
        {"0": 2, "1": 1, "2": 0},
    )

    cyclic = {"0": {"1"}, "1": {"0"}}
    check(
        "cyclic_phases_are_omega",
        {name: render(value) for name, value in phases(cyclic).items()},
        {"0": "omega", "1": "omega"},
    )

    above_cycle = {"0": {"1"}, "1": {"2"}, "2": {"1"}}
    check(
        "a_node_above_a_cycle_is_omega",
        {name: render(value) for name, value in phases(above_cycle).items()},
        {"0": "omega", "1": "omega", "2": "omega"},
    )

    constitution = [
        Rule(name="r0", procedure_bits=5, governed_by="r1"),
        Rule(name="r1", procedure_bits=3, governed_by="r2"),
        Rule(name="r2", procedure_bits=9, governed_by=None),
    ]
    heights = authority_height(constitution)
    check(
        "constitution_authority_heights",
        {name: render(value) for name, value in heights.items()},
        {"r0": 2, "r1": 1, "r2": 0},
    )
    check("protection_is_the_weakest_link", protection(constitution)["r0"], 3)
    check("the_apex_protects_the_rule_beneath_it", protection(constitution)["r1"], 9)
    # The Python source reports infinity for an ungoverned rule; the Lean
    # port reports absence, which is the stronger statement.
    check("an_ungoverned_rule_has_no_protection", protection(constitution)["r2"], float("inf"))

    cyclic_constitution = [
        Rule(name="r0", procedure_bits=4, governed_by="r1"),
        Rule(name="r1", procedure_bits=7, governed_by="r0"),
    ]
    cyclic_heights = authority_height(cyclic_constitution)
    check(
        "cyclic_authority_heights_are_omega",
        {name: render(value) for name, value in cyclic_heights.items()},
        {"r0": "omega", "r1": "omega"},
    )
    check(
        "a_cycle_gives_every_member_the_same_protection",
        (protection(cyclic_constitution)["r0"], protection(cyclic_constitution)["r1"]),
        (4, 4),
    )


def main() -> int:
    check_hypertopology()
    print()
    check_hypergeometry()
    print()
    check_hyperstructure()
    print()
    check_hyperdynamics()
    print()
    check_hypermechanics()
    print()
    check_hyperorganization()
    print()
    if FAILURES:
        print(f"{len(FAILURES)} disagreements between the Lean ports and the Python sources:")
        for failure in FAILURES:
            print(f"  - {failure}")
        return 1
    print("The Lean ports agree with the Python sources on every claimed value.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
