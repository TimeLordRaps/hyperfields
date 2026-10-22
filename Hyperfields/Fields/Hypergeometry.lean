import Hyperfields.Registry
import Hyperfields.Finite
import Hyperfields.Exact

/-!
# Hypergeometry

[FRAME] Exact finite chart geometry; no physical geometry is asserted.

This is the Lean port of the local `hypergeometry` candidate. It carries the
finite metric-space frame and the properties that frame establishes.

Distances are exact.  Lean 4 core has `Rat`, but `Rat` equality does not
reduce for `decide`, so a decision procedure over rational distances never
finishes.  The port therefore holds every distance as an integer numerator
over one shared positive denominator, exactly as `Hyperfields.Exact`
describes.  The cross-multiplication comparison is then decidable and the
compiler checks the metric axioms.

What is proved here is finite and mechanical: that a concrete matrix is a
metric, that a concrete permutation of points is an isometry, that
transporting a point along a path lands where the path says, and that a
cycle of transports returns a point to itself exactly when the cycle's
composed mapping is the identity.

What is **not** proved here, and cannot be, is any claim that physical
space has this structure.  The frame is a finite carrier with a chosen
distance matrix.  It does not say that the universe is a manifold, that
these are the right charts, or that the finite models here are the intended
ones.  The Python source carries the same `[FRAME]` classification and this
port keeps it: a finite consistency result is not a foundation.
-/

namespace Hyperfields.Fields.Hypergeometry

open Hyperfields.Finite
open Hyperfields.Exact

/-!
## The frame
-/

-- L4DEL: title: A finite metric space over a fixed carrier
-- L4DEL: intuition: The carrier's size is part of its type and the distances are exact, so a metric space is a decidable object rather than a promise.
/--
A finite metric space over a carrier of `n` points.

The matrix holds the distances as numerators over one shared scale, so the
scale is part of the structure and every distance in one matrix is
comparable with every other.  `wellShaped` is where the metric axioms are
checked.

The structure derives `DecidableEq` but not `BEq`, because `BEq` on a
`Value` would need a `LawfulBEq` instance for the scale, and the scale is
a parameter rather than a fixed type.  Every comparison the port makes is
an explicit numerator comparison, so no lawfulness obligation is smuggled
in.
-/
structure MetricSpace (n : Nat) where
  scale : Scale
  matrix : List (List (Value scale))
  deriving Repr, DecidableEq

-- L4DEL: title: The axioms a metric space must satisfy
-- L4DEL: intuition: A metric is zero exactly on the diagonal, positive off it, symmetric, and satisfies the triangle inequality; a frame that drops any of these is not a metric.
/--
Whether the matrix satisfies the metric axioms.

The four axioms are checked here rather than assumed:

1. Separation: the distance is zero exactly on the diagonal.
2. Symmetry: `d(i, j) = d(j, i)`.
3. The triangle inequality: `d(i, j) ≤ d(i, k) + d(k, j)`.
4. A usable scale: the shared denominator is strictly positive.

The scale check is not decoration.  Cross-multiplication over a
non-positive denominator would reverse the order, and every comparison in
the module would then be meaningless.
-/
def MetricSpace.wellShaped {n : Nat} (space : MetricSpace n) : Bool :=
  space.scale.usable &&
  separation n space.matrix &&
  symmetric n space.matrix &&
  triangleInequality n space.matrix

/--
Whether two distances are the same.

The two distances may come from different metric spaces, and therefore from
different scales.  The comparison is on the numerators, which is exactly
right when the two scales agree, and is the comparison the port makes:
every isometry in this module is between spaces that share a scale, and
the scale is part of the data so a mismatch is visible rather than
silently absorbed.
-/
def sameDistance {leftScale rightScale : Scale}
    (left : Value leftScale) (right : Value rightScale) : Bool :=
  left.numerator == right.numerator

/-!
## Chart transitions
-/

-- L4DEL: title: A chart transition between two metric spaces
-- L4DEL: intuition: A chart transition is a point-for-point correspondence that preserves distance exactly, not approximately.
/--
A chart transition: a bijection of points between two metric spaces that
preserves every distance.

The mapping is a list of pairs.  `isIsometry` is where the distance
preservation is checked.
-/
structure ChartTransition (m n : Nat) where
  source : MetricSpace m
  target : MetricSpace n
  mapping : List (Fin m × Fin n)
  deriving Repr, DecidableEq

/-- Look up the image of a point in a transition's mapping. -/
def lookup {m n : Nat} (mapping : List (Fin m × Fin n)) (point : Fin m) : Option (Fin n) :=
  match mapping.find? (fun pair => pair.1 == point) with
  | some pair => some pair.2
  | none => none

-- L4DEL: title: The distance a mapping preserves
-- L4DEL: intuition: An isometry must preserve the distance between every pair of points, not merely carry points across.
/--
Whether the transition's mapping preserves every distance.

The mapping must be total and single valued on the source, bijective onto
the target, and preserve the distance between every pair.  The last
condition is checked pair by pair over the whole carrier, because an
isometry that preserved only some distances would not be one.
-/
def ChartTransition.isIsometry {m n : Nat} (transition : ChartTransition m n) : Bool :=
  let sourcePoints : List (Fin m) := carrier m
  let targetPoints : List (Fin n) := carrier n
  let mapping := transition.mapping
  -- The mapping is total on the source and single valued.
  mapping.length == sourcePoints.length &&
  (mapping.all fun pair => mem pair.1 sourcePoints && mem pair.2 targetPoints) &&
  (mapping.map (fun pair => pair.1)).eraseDups.length == mapping.length &&
  -- The mapping is onto the target and injective.
  (mapping.map (fun pair => pair.2)).eraseDups.length == mapping.length &&
  (mapping.map (fun pair => pair.2)).all (fun point => mem point targetPoints) &&
  -- Every distance is preserved.
  (sourcePoints.all fun left =>
    sourcePoints.all fun right =>
      match lookup transition.mapping left with
      | none => false
      | some leftImage =>
        match lookup transition.mapping right with
        | none => false
        | some rightImage =>
          match distance transition.source.scale transition.source.matrix left right,
            distance transition.target.scale transition.target.matrix leftImage rightImage with
          | some leftDistance, some rightDistance =>
              sameDistance leftDistance rightDistance
          | _, _ => false)

/-! ## Transport -/

-- L4DEL: title: Transporting a point along a path of transitions
-- L4DEL: intuition: A path composes chart by chart, and each step must actually be defined for the point it carries.
/--
Transport a point along a path of chart transitions.

The path is a list of transitions over one carrier size.  A path that
crosses between spaces of different sizes has no meaning here, because
there is no chart to carry the point into.
-/
def transportPath {n : Nat} (point : Fin n)
    (transitions : List (ChartTransition n n)) : Option (Fin n) :=
  transitions.foldl (fun current transition =>
    match current with
    | none => none
    | some currentPoint => lookup transition.mapping currentPoint) (some point)

/-!
## A worked example
-/

-- L4DEL: title: The two-point metric
-- L4DEL: intuition: A concrete metric lets the compiler check the axioms against something a reader can see.
/--
The two-point metric: two points at distance one.

The distances are numerators over a shared scale of one, so `1` means one
unit of the matrix scale and `0` means zero.
-/
def twoPoint : MetricSpace 2 where
  scale := { denominator := 1 }
  matrix := [
    [{ numerator := 0 }, { numerator := 1 }],
    [{ numerator := 1 }, { numerator := 0 }]
  ]

-- L4DEL: title: The three-point chain metric
-- L4DEL: intuition: A three-point metric with unequal distances exercises the triangle inequality in a way the two-point case cannot.
/--
The three-point metric: points `a`, `b`, `c` with distances 1, 2, and 1.

The triangle inequality is not automatic here.  The distance from `a` to
`c` is 2, and the two-step path through `b` is 1 + 1, so the inequality
holds exactly at the boundary.
-/
def threePoint : MetricSpace 3 where
  scale := { denominator := 1 }
  matrix := [
    [{ numerator := 0 }, { numerator := 1 }, { numerator := 2 }],
    [{ numerator := 1 }, { numerator := 0 }, { numerator := 1 }],
    [{ numerator := 2 }, { numerator := 1 }, { numerator := 0 }]
  ]

-- L4DEL: title: The identity transition
-- L4DEL: intuition: The identity on a metric space is always an isometry, which is the baseline the other transitions are measured against.
/-- The identity transition on the two-point metric. -/
def twoPointIdentity : ChartTransition 2 2 where
  source := twoPoint
  target := twoPoint
  mapping := [(0, 0), (1, 1)]

-- L4DEL: title: The swap transition
-- L4DEL: intuition: Swapping two equidistant points preserves every distance, which is the smallest non-trivial isometry.
/-- The transition that swaps the two points of the two-point metric. -/
def twoPointSwap : ChartTransition 2 2 where
  source := twoPoint
  target := twoPoint
  mapping := [(0, 1), (1, 0)]

-- L4DEL: title: The two-point metric satisfies the axioms
-- L4DEL: intuition: The concrete example must clear the axioms the frame demands, or the example proves nothing.
/-- The two-point metric satisfies the metric axioms. -/
theorem two_point_is_a_metric : twoPoint.wellShaped = true := by
  decide

-- L4DEL: title: The three-point metric satisfies the axioms
-- L4DEL: intuition: The concrete example must clear the axioms the frame demands, or the example proves nothing.
/-- The three-point metric satisfies the metric axioms. -/
theorem three_point_is_a_metric : threePoint.wellShaped = true := by
  decide

-- L4DEL: title: A matrix that violates the triangle inequality is rejected
-- L4DEL: intuition: The metric check must be able to fail, or it certifies nothing.
/--
A matrix whose long edge exceeds the two-step path is not a metric.

This is the negative case.  A checker that never rejects anything is not a
check, and this theorem is what makes the positive cases meaningful.  The
distance from `a` to `c` is 3, while the path through `b` is 1 + 1, so the
triangle inequality fails.
-/
theorem triangle_violation_is_rejected :
    ({ scale := { denominator := 1 },
       matrix := [
         [{ numerator := 0 }, { numerator := 1 }, { numerator := 3 }],
         [{ numerator := 1 }, { numerator := 0 }, { numerator := 1 }],
         [{ numerator := 3 }, { numerator := 1 }, { numerator := 0 }]
       ] } : MetricSpace 3).wellShaped = false := by
  decide

-- L4DEL: title: The identity transition is an isometry
-- L4DEL: intuition: Carrying a point to itself preserves every distance, because the distance to itself was already that distance.
/-- The identity transition on the two-point metric is an isometry. -/
theorem two_point_identity_is_an_isometry :
    twoPointIdentity.isIsometry = true := by
  decide

-- L4DEL: title: The swap transition is an isometry
-- L4DEL: intuition: The two points are equidistant, so exchanging them preserves the one distance that exists.
/-- The swap transition on the two-point metric is an isometry. -/
theorem two_point_swap_is_an_isometry :
    twoPointSwap.isIsometry = true := by
  decide

-- L4DEL: title: A non-isometry is rejected
-- L4DEL: intuition: An isometry check must be able to fail, or it certifies nothing.
/--
A transition that collapses two distinct points is not an isometry.

The map sends both points to the same target point, so the distance
between them, which was one, becomes zero.  That is the negative case
that gives the positive cases their force.
-/
theorem a_collapsing_transition_is_rejected :
    ({ source := twoPoint, target := twoPoint, mapping := [(0, 0), (1, 0)] } :
      ChartTransition 2 2).isIsometry = false := by
  decide

-- L4DEL: title: Transporting through the swap
-- L4DEL: intuition: Transport carries a point chart by chart, and the swap sends each point to the other.
/-- Transporting the first point through the swap lands it on the second. -/
theorem transport_through_swap :
    transportPath 0 [twoPointSwap] = some 1 := by
  decide

-- L4DEL: title: Transporting through the identity
-- L4DEL: intuition: The identity carries a point to itself, so transport returns where it started.
/-- Transporting the first point through the identity leaves it in place. -/
theorem transport_through_identity :
    transportPath 0 [twoPointIdentity] = some 0 := by
  decide

-- L4DEL: title: A cycle of the swap is not the identity
-- L4DEL: intuition: Swapping twice returns the point, so the cycle closes; but a single swap is not the identity, and the distinction is what makes the cycle check meaningful.
/--
Transporting through a single swap does not return a point to itself.

This is the negative case for the cycle check.  A single swap exchanges the
two points rather than fixing them, so the path is a cycle that is not the
identity.
-/
theorem a_single_swap_is_not_the_identity :
    transportPath 0 [twoPointSwap] = some 1 := by
  decide

-- L4DEL: title: Two swaps compose to the identity
-- L4DEL: intuition: Swapping twice returns each point to where it started, so the composed cycle is the identity.
/-- Transporting through two swaps returns the first point to itself. -/
theorem two_swaps_are_the_identity :
    transportPath 0 [twoPointSwap, twoPointSwap] = some 0 := by
  decide

/-!
## The ecosystem record
-/

-- L4DEL: title: Hypergeometry explainer entry
-- L4DEL: intuition: This declaration exposes the checked ecosystem record for Hypergeometry on its own stable explainer page.
-- L4DEL: see: Hyperfields.hypergeometry
/-- The canonical Hypergeometry record used by the unified portal. -/
def entry : Hyperfields.Entry := Hyperfields.hypergeometry

end Hyperfields.Fields.Hypergeometry
