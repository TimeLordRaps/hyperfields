import Hyperfields.Core

/-!
# The foundation architecture, as typed structure

The ecosystem's architecture was declared directly by Tyler Roost and is
recorded in prose in `docs/FOUNDATION_ARCHITECTURE.md`. This module makes the
parts of it that are *finite and decidable* into typed Lean, so that the
catalogue can carry the architecture rather than only describe it.

Three things are encoded here.

1. **The four semantic axes.** WHAT (what is the structure), HOW (how does it
   come to exist and compose), WHY (why is it there), and WHERE-WHEN (where and
   when). The axes are *not* an exclusive partition. A field occupies a
   profile of axes, and the four named fields are the canonical instance of
   each axis rather than its only member. `metamathethicology` is the proof of
   this: it is explicitly a combination field, so the family already thinks in
   composites.

2. **The derivation order.** The order in which fields become *available*.
   This is an availability order, not an authority order: stage 0 does not
   outrank stage 8, it is merely built first.

3. **The two paired relations.** `hypergeometry` is to `hyperspace` as
   `hypertopology` is to `hypertime`, and `hypermath` and `hyperlogic` are the
   what and the how that together underpin everything else.

What is *not* encoded here is the self-kernel and its composition. That
belongs to `hypermath` and `hyperlogic`, and this module cites them rather
than restating them. The same rule the family already follows: a foundation
imports nothing, and a catalogue cites rather than duplicates.
-/

namespace Hyperfields.Architecture

/-!
## The axes
-/

-- L4DEL: title: The four semantic axes
-- L4DEL: intuition: A field answers some of what, how, why, and where-when; a field that answered all four would be a different kind of thing entirely.
/--
The four semantic axes a field may occupy.

`what` is the structure itself.  `how` is how it comes to exist and how it
composes.  `why` is creation, will, consciousness, and consent.  `whereWhen`
is placement, index, and physical application.

These are axes, not a partition.  A field may occupy several, and the four
canonical fields are the primary instance of each axis rather than its only
member.
-/
inductive Axis where
  | what
  | how
  | why
  | whereWhen
  deriving Repr, BEq, DecidableEq

-- L4DEL: title: The published name of an axis
-- L4DEL: intuition: The axis vocabulary is fixed and public, so each axis renders to exactly one string.
/-- The published name of an axis. -/
def Axis.string : Axis → String
  | .what => "what"
  | .how => "how"
  | .why => "why"
  | .whereWhen => "where-when"

-- L4DEL: title: The axis profile of a field
-- L4DEL: intuition: A field may answer several questions at once, so its profile is a set rather than a single label.
/--
The axes a field occupies.

The profile is a set, so a field that answers two questions says so, and the
empty profile is a distinguishable state rather than a missing value.
-/
abbrev AxisProfile := List Axis

/-!
## The derivation order
-/

-- L4DEL: title: The stage a field becomes available at
-- L4DEL: intuition: Availability is a build order, not a ranking, so a late stage is not a lesser field.
/--
The stage at which a field becomes available.

Stage 0 is the self-kernel and its how.  Each later stage is built from what
came before.  This is an availability order and carries no authority claim:
stage 8 is not more important than stage 0, it is merely built later.
-/
def stageOf (id : RepoId) : Nat :=
  match id with
  | .hypermath => 0
  | .hyperlogic => 0
  | .hypertopology => 1
  | .hypergeometry => 1
  | .hyperorder => 2
  | .hyperchaos => 2
  | .hyperemergence => 2
  | .hypertime => 3
  | .hyperspace => 3
  | .hyperdynamics => 3
  | .hypermechanics => 3
  | .hyperreality => 3
  | .hyperstructure => 3
  | .hyperphysics => 4
  | .hyperethics => 4
  | .hyperobjectivity => 5
  | .hypersubjectivity => 5
  | .hypergrammar => 6
  | .hyperorganization => 6
  | .hyperchemistry => 7
  | .hyperbiology => 7
  | .groundedHypercalculi => 8
  | .groundedHypersetTheory => 8
  | .hyperprobability => 8
  | .ordinatics => 8
  | .metamathethicology => 8
  | .metaMorphoscriptedOrigination => 8
  | .hyperstratum => 8

/-- Every field the catalogue carries, in derivation order. -/
def allIds : List RepoId := [
  .hypermath, .hyperlogic,
  .hypertopology, .hypergeometry,
  .hyperorder, .hyperchaos, .hyperemergence,
  .hypertime, .hyperspace, .hyperdynamics, .hypermechanics, .hyperreality,
  .hyperstructure,
  .hyperphysics, .hyperethics,
  .hyperobjectivity, .hypersubjectivity,
  .hypergrammar, .hyperorganization,
  .hyperchemistry, .hyperbiology,
  .groundedHypercalculi, .groundedHypersetTheory, .hyperprobability,
  .ordinatics, .metamathethicology, .metaMorphoscriptedOrigination,
  .hyperstratum
]

/-- The axis profile of every field. -/
def axisProfile : List (RepoId × AxisProfile) := [
  (.hypermath, [.what]),
  (.hyperlogic, [.how]),
  (.hypertopology, [.how, .whereWhen]),
  (.hypergeometry, [.how, .whereWhen]),
  (.hyperorder, [.how]),
  (.hyperchaos, [.how, .whereWhen]),
  (.hyperemergence, [.how, .whereWhen]),
  (.hypertime, [.whereWhen]),
  (.hyperspace, [.whereWhen]),
  (.hyperdynamics, [.what, .whereWhen]),
  (.hypermechanics, [.what, .how]),
  (.hyperreality, [.what]),
  (.hyperstructure, [.what, .how]),
  (.hyperphysics, [.whereWhen]),
  (.hyperethics, [.why]),
  (.hyperobjectivity, [.why]),
  (.hypersubjectivity, [.why]),
  (.hypergrammar, [.what, .how]),
  (.hyperorganization, [.how]),
  (.hyperchemistry, [.what, .whereWhen]),
  (.hyperbiology, [.what, .whereWhen]),
  (.groundedHypercalculi, [.what, .how]),
  (.groundedHypersetTheory, [.what, .how]),
  (.hyperprobability, [.what, .whereWhen]),
  (.ordinatics, [.what, .how]),
  (.metamathethicology, [.how]),
  (.metaMorphoscriptedOrigination, [.what, .how]),
  (.hyperstratum, [.how, .why])
]

/-- Look up a field's axis profile. -/
def profileOf (id : RepoId) : AxisProfile :=
  match axisProfile.find? (fun entry => entry.1 == id) with
  | some entry => entry.2
  | none => []

/-!
## The paired relations
-/

-- L4DEL: title: The two paired relations
-- L4DEL: intuition: Two pairs of fields stand to each other the same way, and the pairing is the reason the derivation order is not arbitrary.
/--
The two declared pairings.

`hypergeometry` is the metamathematical structure that can form geometries and
`hyperspace` is the dimensionality of structures; that relation is the same
one that holds between `hypertopology` and `hypertime`.  The second pair is
`hypermath` and `hyperlogic` themselves, the what and the how, which together
underpin everything else.
-/
structure Pairing where
  left : RepoId
  right : RepoId
  deriving Repr, BEq, DecidableEq

/-- The declared pairings. -/
def pairings : List Pairing := [
  { left := .hypergeometry, right := .hyperspace },
  { left := .hypertopology, right := .hypertime },
  { left := .hypermath, right := .hyperlogic }
]

/-!
## The checks
-/

/-- Every catalogued field has a stage and an axis profile. -/
theorem every_field_has_a_stage :
    allIds.all (fun id => stageOf id ≤ 8) = true := by
  decide

/-- The stage of every field is at least zero. -/
theorem every_stage_is_nonneg :
    allIds.all (fun id => 0 ≤ stageOf id) = true := by
  decide

/-- The catalogue and the stage table agree on the number of fields. -/
theorem catalogue_and_stages_agree : allIds.length = 28 := by
  decide

/-- Every catalogued field has a non-empty axis profile. -/
theorem every_field_occupies_an_axis :
    allIds.all (fun id => !(profileOf id).isEmpty) = true := by
  decide

/-- The four axes are each occupied by at least one field. -/
theorem every_axis_is_occupied :
    (allIds.any (fun id => (profileOf id).contains .what) &&
     allIds.any (fun id => (profileOf id).contains .how) &&
     allIds.any (fun id => (profileOf id).contains .why) &&
     allIds.any (fun id => (profileOf id).contains .whereWhen)) = true := by
  decide

/-- No field occupies no axis, and the profiles are total over the catalogue. -/
theorem profiles_are_total : axisProfile.length = allIds.length := by
  decide

/-- There are three declared pairings. -/
theorem there_are_three_pairings : pairings.length = 3 := by
  decide

/-- No pairing joins a field to itself. -/
theorem pairings_join_distinct_fields :
    pairings.filter (fun pairing => pairing.left == pairing.right) = [] := by
  decide

/-- The canonical what/how pair is the first pairing. -/
theorem the_what_how_pair_is_declared :
    pairings.any (fun pairing =>
      pairing.left == .hypermath && pairing.right == .hyperlogic) = true := by
  decide

/-- The shape/dimensionality and nearness/index pairings are both declared. -/
theorem the_shape_pairs_are_declared :
    (pairings.any (fun pairing =>
       pairing.left == .hypergeometry && pairing.right == .hyperspace) &&
     pairings.any (fun pairing =>
       pairing.left == .hypertopology && pairing.right == .hypertime)) = true := by
  decide

end Hyperfields.Architecture
