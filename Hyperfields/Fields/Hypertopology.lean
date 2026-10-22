import Hyperfields.Registry
import Hyperfields.Finite

/-!
# Hypertopology

[FRAME] Finite topological interpretation of recursive nearness.

This is the Lean port of the local `hypertopology` candidate. It carries the
finite topology frame and the properties that frame establishes, and nothing
more.

What is proved here is finite and mechanical. A topology over a carrier of
known size is a list of open sets; the axioms that matter are that the
empty set and the whole carrier are open, that the opens are closed under
union and intersection, and that closure, interior, and boundary are the
operations the frame defines. Those are decidable over a finite carrier, so
the compiler checks them.

The carrier's size is a *type parameter* rather than a field.  A `Fin n`
whose `n` is a structure field cannot be given a literal point, because the
elaborator cannot reduce the field to a numeral at that point.  Making the
size a parameter means each topology is a type-level choice, and the
numerals are ordinary literals.

What is **not** proved here, and cannot be, is any claim that nearness has a
topological nature in general. The frame is a finite carrier with a chosen
collection of opens. It does not say that recursive nearness is continuous,
and it does not say that the finite models here are the intended ones. The
Python source carries the same `[FRAME]` classification, and this port keeps
it: a finite consistency result is not a foundation.
-/

namespace Hyperfields.Fields.Hypertopology

open Hyperfields.Finite

/-!
## The frame
-/

-- L4DEL: title: A finite topology over a fixed carrier
-- L4DEL: intuition: The carrier's size is part of its type, so a topology is a finite list of opens over a known number of points.
/--
A finite topology over a carrier of `n` points.

The carrier is `Fin n`, so the number of points is fixed by the type rather
than checked at runtime, and every point is a decidable value.  The opens
are a list of carrier subsets; `wellShaped` is where the axioms are
checked.
-/
structure FiniteTopology (n : Nat) where
  opens : List (List (Fin n))
  deriving Repr, BEq, DecidableEq

-- L4DEL: title: The axioms a finite topology must satisfy
-- L4DEL: intuition: A topology is empty set, whole carrier, and closure under the two lattice operations; a frame that drops any of these is not a topology.
/--
Whether the opens satisfy the topology axioms.

The three axioms are checked here rather than assumed:

1. The empty set is open.
2. The whole carrier is open.
3. The opens are closed under union and intersection.

The checks are decidable because the carrier is finite and its equality is
decidable.
-/
def FiniteTopology.wellShaped {n : Nat} (topology : FiniteTopology n) : Bool :=
  let points : List (Fin n) := carrier n
  let le := finLe n
  mem [] topology.opens &&
  mem points topology.opens &&
  (topology.opens.all fun left =>
    topology.opens.all fun right =>
      mem (union le left right) topology.opens && mem (inter le left right) topology.opens) &&
  (topology.opens.all fun opened =>
    opened.all (fun point => mem point points))

/-!
## The operations
-/

-- L4DEL: title: The closure of a subset
-- L4DEL: intuition: Closure is the intersection of every closed superset of the subset, and on a finite carrier that intersection is computable.
/--
The closure of a subset: the intersection of every closed superset of it.

A closed superset of `subset` is the complement of an open set that
contains `subset`.  The closure is therefore the intersection of all such
complements, which is exactly the definition on a finite carrier.
-/
def FiniteTopology.closure {n : Nat} (topology : FiniteTopology n)
    (candidate : List (Fin n)) : List (Fin n) :=
  let points : List (Fin n) := carrier n
  let le := finLe n
  topology.opens.foldl (fun result opened =>
    let closed := diff le points opened
    if subset candidate closed then inter le result closed else result) points

-- L4DEL: title: The interior of a subset
-- L4DEL: intuition: Interior is the union of every open set contained in the subset, which is the largest open set inside it.
/--
The interior of a subset: the union of every open set contained in it.
-/
def FiniteTopology.interior {n : Nat} (topology : FiniteTopology n)
    (candidate : List (Fin n)) : List (Fin n) :=
  let le := finLe n
  topology.opens.foldl (fun result opened =>
    if subset opened candidate then union le result opened else result) []

-- L4DEL: title: The boundary of a subset
-- L4DEL: intuition: The boundary is where the closure and the closure of the complement meet, so it is the set of points that cannot be avoided on either side.
/--
The boundary of a subset: the intersection of its closure with the closure
of its complement.
-/
def FiniteTopology.boundary {n : Nat} (topology : FiniteTopology n)
    (candidate : List (Fin n)) : List (Fin n) :=
  let points : List (Fin n) := carrier n
  let le := finLe n
  inter le (topology.closure candidate) (topology.closure (diff le points candidate))

-- L4DEL: title: Continuity of a map between finite topologies
-- L4DEL: intuition: A map is continuous when the inverse image of every open set is open, which is decidable over a finite carrier.
/--
Whether a map between two finite topologies is continuous.

The map is given as a list of pairs, one per source point, and must be
total and single valued.  Continuity is checked by pulling back every open
set of the target and asking whether the result is open in the source.
-/
def continuousBetween {m n : Nat}
    (source : FiniteTopology m) (target : FiniteTopology n)
    (mapping : List (Fin m × Fin n)) : Bool :=
  let sourcePoints : List (Fin m) := carrier m
  let targetPoints : List (Fin n) := carrier n
  -- The mapping must be total and single valued.
  mapping.length == sourcePoints.length &&
  (mapping.all fun pair => mem pair.1 sourcePoints && mem pair.2 targetPoints) &&
  (mapping.map (fun pair => pair.1)).eraseDups.length == mapping.length &&
  -- Every target open pulls back to a source open.
  (target.opens.all fun opened =>
    let pulled := mapping.filter (fun pair => mem pair.2 opened) |>.map (fun pair => pair.1)
    mem pulled source.opens)

/-!
## A worked example
-/

-- L4DEL: title: The discrete topology on two points
-- L4DEL: intuition: Every subset is open, which is the finest possible topology and the strictest test of continuity.
/-- The discrete topology on two points: every subset is open. -/
def discreteTwo : FiniteTopology 2 where
  opens := [[], [0], [1], [0, 1]]

-- L4DEL: title: The indiscrete topology on two points
-- L4DEL: intuition: Only the empty set and the whole carrier are open, which is the coarsest possible topology.
/-- The indiscrete topology on two points: only the empty set and the whole carrier are open. -/
def indiscreteTwo : FiniteTopology 2 where
  opens := [[], [0, 1]]

-- L4DEL: title: A three-point topology
-- L4DEL: intuition: A concrete frame lets the compiler check the axioms and the operations against something a reader can see.
/--
A concrete three-point topology used to check the axioms and the operations.

The carrier is `{0, 1, 2}` and the opens are `∅`, `{0}`, `{0, 1}`, and the
whole carrier.  This is the finite chain topology, and every property below
is checked by the compiler rather than asserted.
-/
def chainTopology : FiniteTopology 3 where
  opens := [
    [],
    [0],
    [0, 1],
    [0, 1, 2]
  ]

-- L4DEL: title: The chain topology satisfies the axioms
-- L4DEL: intuition: The concrete example must actually clear the axioms the frame demands, or the example proves nothing.
/-- The three-point chain topology satisfies the topology axioms. -/
theorem chain_topology_is_well_shaped : chainTopology.wellShaped = true := by
  decide

-- L4DEL: title: The discrete topology satisfies the axioms
-- L4DEL: intuition: The concrete example must clear the axioms it is used to test.
/-- The discrete two-point topology satisfies the topology axioms. -/
theorem discrete_two_is_well_shaped : discreteTwo.wellShaped = true := by
  decide

-- L4DEL: title: The indiscrete topology satisfies the axioms
-- L4DEL: intuition: The coarsest possible topology still satisfies the axioms, which is the check that the axioms are not too strong.
/-- The indiscrete two-point topology satisfies the topology axioms. -/
theorem indiscrete_two_is_well_shaped : indiscreteTwo.wellShaped = true := by
  decide

-- L4DEL: title: The closure of the open set {0, 1}
-- L4DEL: intuition: Closure is the intersection of the closed supersets, and on a chain the only closed superset of `{0, 1}` is the whole carrier.
/--
The closure of `{0, 1}` in the chain topology is the whole carrier.

This is the case that a hand-written intuition gets wrong. The set `{0, 1}`
is open, but it is not closed: the only closed set that contains it is
`{0, 1, 2}` itself. Closure is the intersection of the closed *supersets*,
not the smallest closed set equal to the argument, so the closure is the
whole carrier. The compiler checks this against the definition.
-/
theorem chain_closure_of_open :
    chainTopology.closure [0, 1] = [0, 1, 2] := by
  decide

-- L4DEL: title: The closure of the closed set {2}
-- L4DEL: intuition: A closed set's closure is itself, because it is one of its own closed supersets and the intersection cannot grow past it.
/-- The closure of `{2}` in the chain topology is `{2}`. -/
theorem chain_closure_of_closed :
    chainTopology.closure [2] = [2] := by
  decide

-- L4DEL: title: The interior of the whole carrier
-- L4DEL: intuition: The interior of the whole carrier is the whole carrier, because the carrier is open.
/-- The interior of the whole carrier in the chain topology is the whole carrier. -/
theorem chain_interior_of_carrier :
    chainTopology.interior [0, 1, 2] = [0, 1, 2] := by
  decide

-- L4DEL: title: The interior of the set {1, 2}
-- L4DEL: intuition: The interior is the largest open set inside the subset, and on the chain no nonempty open set lies inside `{1, 2}`.
/-- The interior of `{1, 2}` in the chain topology is empty. -/
theorem chain_interior_of_tail :
    chainTopology.interior [1, 2] = [] := by
  decide

-- L4DEL: title: The interior of the set {0, 1}
-- L4DEL: intuition: `{0, 1}` is itself open on the chain, so it is the largest open set inside itself and the interior is the set.
/-- The interior of `{0, 1}` in the chain topology is `{0, 1}`. -/
theorem chain_interior_of_open :
    chainTopology.interior [0, 1] = [0, 1] := by
  decide

-- L4DEL: title: The boundary of the open set {0, 1}
-- L4DEL: intuition: A set that is open but not closed has a nonempty boundary, and on the chain the boundary of `{0, 1}` is the point that cannot be avoided.
/--
The boundary of `{0, 1}` in the chain topology is `{2}`.

The boundary is where the set and its complement meet. `{0, 1}` does not
contain `2` and its complement `{2}` does not contain any of `{0, 1}`, so
`2` is not a boundary point of the set itself; the boundary of the set is
the closure of `{0, 1}` intersected with the closure of `{2}`, which is
`{2}`.
-/
theorem chain_boundary_of_open :
    chainTopology.boundary [0, 1] = [2] := by
  decide

-- L4DEL: title: The boundary of the singleton {0}
-- L4DEL: intuition: An open singleton on a chain still has a boundary, because the chain continues past it.
/-- The boundary of `{0}` in the chain topology is `{1, 2}`. -/
theorem chain_boundary_of_singleton :
    chainTopology.boundary [0] = [1, 2] := by
  decide

-- L4DEL: title: The boundary of the whole carrier
-- L4DEL: intuition: The carrier is closed, so its boundary is empty and the chain is connected.
/-- The boundary of the whole carrier in the chain topology is empty. -/
theorem chain_boundary_of_carrier :
    chainTopology.boundary [0, 1, 2] = [] := by
  decide

-- L4DEL: title: An identity map on the chain is continuous
-- L4DEL: intuition: The identity map pulls every open set back to itself, and every open set is open, so it is continuous.
/-- The identity map from the chain topology to itself is continuous. -/
theorem chain_identity_is_continuous :
    continuousBetween chainTopology chainTopology [(0, 0), (1, 1), (2, 2)] = true := by
  decide

-- L4DEL: title: A map to a finer topology is continuous
-- L4DEL: intuition: A constant map is continuous into any topology, because the preimage of every open set is either everything or nothing, and both are open.
/-- A constant map from the chain topology to the discrete two-point topology is continuous. -/
theorem chain_to_discrete_is_continuous :
    continuousBetween chainTopology discreteTwo [(0, 0), (1, 0), (2, 0)] = true := by
  decide

-- L4DEL: title: A map to a coarser topology is continuous
-- L4DEL: intuition: A coarser target has fewer obligations, so a total map that meets them is continuous.
/-- A map from the chain topology to the indiscrete two-point topology is continuous. -/
theorem chain_to_indiscrete_is_continuous :
    continuousBetween chainTopology indiscreteTwo [(0, 0), (1, 0), (2, 0)] = true := by
  decide

-- L4DEL: title: A discontinuous map is rejected
-- L4DEL: intuition: The continuity check must be able to fail, or it certifies nothing.
/--
A map that pulls an open set back to a non-open set is not continuous.

This is the negative case.  A checker that never rejects anything is not a
check, and this theorem is what makes the positive cases meaningful.

The map sends `1` and `2` to different points of the discrete target, so
the preimage of the target's open set `{0}` is `{0}`, which is not open in
the chain topology. The map is therefore not continuous.
-/
theorem a_noncontinuous_map_is_rejected :
    continuousBetween chainTopology discreteTwo [(0, 0), (1, 1), (2, 0)] = false := by
  decide

/-!
## The ecosystem record
-/

-- L4DEL: title: Hypertopology explainer entry
-- L4DEL: intuition: This declaration exposes the checked ecosystem record for Hypertopology on its own stable explainer page.
-- L4DEL: see: Hyperfields.hypertopology
/-- The canonical Hypertopology record used by the unified portal. -/
def entry : Hyperfields.Entry := Hyperfields.hypertopology

end Hyperfields.Fields.Hypertopology
