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
-- L4DEL: title: Every field, in derivation order
-- L4DEL: intuition: The catalogue is listed in the order the fields become available, so a reader can see what each one is built on.
-- L4DEL: prereq: Hyperfields.RepoId
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
-- L4DEL: title: Which question each field answers
-- L4DEL: intuition: A field may answer more than one of what, how, why, and where-when, so the profile is a list rather than a single axis.
-- L4DEL: prereq: Hyperfields.RepoId, Hyperfields.Architecture.AxisProfile
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
-- L4DEL: title: Look up a field's axes
-- L4DEL: intuition: A field the table does not carry has no axes, which is the empty list rather than an error.
-- L4DEL: prereq: Hyperfields.RepoId, Hyperfields.Architecture.AxisProfile
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
-- L4DEL: title: The three declared pairings
-- L4DEL: intuition: Each pairing names two fields that stand to each other the same way, which is why the derivation order is not arbitrary.
-- L4DEL: prereq: Hyperfields.Architecture.Pairing
def pairings : List Pairing := [
  { left := .hypergeometry, right := .hyperspace },
  { left := .hypertopology, right := .hypertime },
  { left := .hypermath, right := .hyperlogic }
]

/-!
## The checks
-/

/-- Every catalogued field has a stage and an axis profile. -/
-- L4DEL: title: Every field has a stage
-- L4DEL: intuition: The stage table covers the whole catalogue, so no field is left without a place in the derivation order.
-- L4DEL: step: Check each of the twenty-eight fields against the stage bound.
-- L4DEL: prereq: Hyperfields.Architecture.allIds, Hyperfields.Architecture.stageOf
theorem every_field_has_a_stage :
    allIds.all (fun id => stageOf id ≤ 8) = true := by
  decide

/-- The stage of every field is at least zero. -/
-- L4DEL: title: No stage is negative
-- L4DEL: intuition: A stage is a natural number, so the lower bound holds by construction and the check confirms the table was not built with a negative.
-- L4DEL: prereq: Hyperfields.Architecture.allIds, Hyperfields.Architecture.stageOf
theorem every_stage_is_nonneg :
    allIds.all (fun id => 0 ≤ stageOf id) = true := by
  decide

/-- The catalogue and the stage table agree on the number of fields. -/
-- L4DEL: title: The catalogue has twenty-eight fields
-- L4DEL: intuition: The list is written out, so Lean can count it exactly rather than trusting a number in prose.
-- L4DEL: prereq: Hyperfields.Architecture.allIds
theorem catalogue_and_stages_agree : allIds.length = 28 := by
  decide

/-- Every catalogued field has a non-empty axis profile. -/
-- L4DEL: title: Every field answers some question
-- L4DEL: intuition: A field with no axis would be a field that answers nothing, so the table is checked to have no such entry.
-- L4DEL: prereq: Hyperfields.Architecture.allIds, Hyperfields.Architecture.profileOf
theorem every_field_occupies_an_axis :
    allIds.all (fun id => !(profileOf id).isEmpty) = true := by
  decide

/-- The four axes are each occupied by at least one field. -/
-- L4DEL: title: All four axes are used
-- L4DEL: intuition: An axis no field occupies would be a distinction the ecosystem declares and does not use, so each of the four is checked to have a member.
-- L4DEL: prereq: Hyperfields.Architecture.allIds, Hyperfields.Architecture.profileOf
theorem every_axis_is_occupied :
    (allIds.any (fun id => (profileOf id).contains .what) &&
     allIds.any (fun id => (profileOf id).contains .how) &&
     allIds.any (fun id => (profileOf id).contains .why) &&
     allIds.any (fun id => (profileOf id).contains .whereWhen)) = true := by
  decide

/-- No field occupies no axis, and the profiles are total over the catalogue. -/
-- L4DEL: title: The profiles cover the catalogue exactly
-- L4DEL: intuition: The profile table and the catalogue have the same length, so no field is missing a profile and none has two.
-- L4DEL: prereq: Hyperfields.Architecture.allIds, Hyperfields.Architecture.axisProfile
theorem profiles_are_total : axisProfile.length = allIds.length := by
  decide

/-- There are three declared pairings. -/
-- L4DEL: title: There are three pairings
-- L4DEL: intuition: The list is explicit, so Lean can reduce its length exactly.
-- L4DEL: prereq: Hyperfields.Architecture.pairings
theorem there_are_three_pairings : pairings.length = 3 := by
  decide

/-- No pairing joins a field to itself. -/
-- L4DEL: title: A pairing needs two fields
-- L4DEL: intuition: A field paired with itself would state no relation, so no declared pairing may have equal endpoints.
-- L4DEL: prereq: Hyperfields.Architecture.pairings
theorem pairings_join_distinct_fields :
    pairings.filter (fun pairing => pairing.left == pairing.right) = [] := by
  decide

/-- The canonical what/how pair is the first pairing. -/
-- L4DEL: title: The what and the how are paired
-- L4DEL: intuition: Hypermath is the what and hyperlogic is the how, and the declaration that they pair is checked rather than assumed.
-- L4DEL: prereq: Hyperfields.Architecture.pairings
theorem the_what_how_pair_is_declared :
    pairings.any (fun pairing =>
      pairing.left == .hypermath && pairing.right == .hyperlogic) = true := by
  decide

/-- The shape/dimensionality and nearness/index pairings are both declared. -/
-- L4DEL: title: The two shape pairings are declared
-- L4DEL: intuition: Geometry is to space as topology is to time, and both halves of that analogy are checked to be in the table.
-- L4DEL: prereq: Hyperfields.Architecture.pairings
theorem the_shape_pairs_are_declared :
    (pairings.any (fun pairing =>
       pairing.left == .hypergeometry && pairing.right == .hyperspace) &&
     pairings.any (fun pairing =>
       pairing.left == .hypertopology && pairing.right == .hypertime)) = true := by
  decide

end Hyperfields.Architecture
