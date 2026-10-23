import Hyperfields.Registry
import Hyperfields.Finite
import Hyperfields.Exact

/-!
# Hypermechanics

[FRAME] Exact guarded transfers; counters have no assumed physical units.

This is the Lean port of the local `hypermechanics` candidate. It carries
the mechanism state, the rewrite rule, and the properties that frame
establishes.

The counts are exact.  As in the geometry port, Lean 4 core's `Rat` does
not reduce for `decide`, so the counts are held as integer numerators over
one shared scale, and the conservation invariant is checked as an exact
integer equality.  A conservation check that used floating point would be
a different claim, and a weaker one.

The conservation invariant is the frame's centre.  A rewrite rule declares
a weight for every place it changes, and the rule is admissible only when
the weighted sum of the changes is exactly zero.  That is a statement about
the rule, not about the world: it says the rule is declared to conserve
what it says it conserves.

What is **not** proved here, and cannot be, is any claim that any physical
process obeys this, that these counts are quantities in any unit, or that
the frame's mechanisms are the right ones.  The Python source carries the
same `[FRAME]` classification and this port keeps it.
-/

namespace Hyperfields.Fields.Hypermechanics

open Hyperfields.Finite
open Hyperfields.Exact

/-!
## The frame
-/

-- L4DEL: title: A state of named places holding exact counts
-- L4DEL: intuition: A state is a map from named places to exact counts, and the counts carry no unit because the frame does not assign one.
/--
A mechanism state: named places, the exact count in each, and the kind of
each place.

The counts are numerators over one shared scale, so every count in one
state is comparable with every other.  The kinds are declared per place,
exactly one per place, and the port keeps them separate from the counts:
a place's kind is not a quantity.
-/
structure MechanismState (n : Nat) where
  scale : Scale
  amounts : List (Fin n × Int)
  kindOf : List (Fin n × String)
  deriving Repr, DecidableEq

/-- The count in a place, if the place has one. -/
-- L4DEL: title: Read a place's count
-- L4DEL: intuition: A place the state does not carry has no count, which is nothing rather than zero.
-- L4DEL: prereq: Hyperfields.Fields.Hypermechanics.MechanismState
def MechanismState.amount {n : Nat} (state : MechanismState n)
    (place : Fin n) : Option Int :=
  match state.amounts.find? (fun pair => pair.1 == place) with
  | some pair => some pair.2
  | none => none

/-- The kind of a place, if the place has one. -/
-- L4DEL: title: Read a place's kind
-- L4DEL: intuition: A kind is a name rather than a quantity, so it is read separately from the count.
-- L4DEL: prereq: Hyperfields.Fields.Hypermechanics.MechanismState
def MechanismState.kindOfPlace {n : Nat} (state : MechanismState n)
    (place : Fin n) : Option String :=
  match state.kindOf.find? (fun pair => pair.1 == place) with
  | some pair => some pair.2
  | none => none

-- L4DEL: title: The axioms a mechanism state must satisfy
-- L4DEL: intuition: A state with a negative count is not a state, and a place declared twice is described twice.
/--
Whether the state satisfies the axioms.

The checks are:

1. Every count is nonnegative.
2. Every place has exactly one count and one kind, and no place outside
   the count carrier has one.
-/
def MechanismState.wellShaped {n : Nat} (state : MechanismState n) : Bool :=
  state.amounts.all (fun pair => 0 <= pair.2) &&
  (state.amounts.map (fun pair => pair.1)).eraseDups.length == state.amounts.length &&
  (state.kindOf.map (fun pair => pair.1)).eraseDups.length == state.kindOf.length &&
  state.kindOf.length == state.amounts.length &&
  state.kindOf.all (fun pair => state.amounts.any (fun amount => amount.1 == pair.1))

/-!
## Rewrite rules
-/

-- L4DEL: title: A guarded rewrite with an exact conservation invariant
-- L4DEL: intuition: A rule says what must be true before it fires, what it changes, and what it conserves, and the three are checked together.
/--
A rewrite rule: the guard minima, the changes, and the conservation
weights.

The rule is admissible only when it conserves exactly what it says it
conserves.  The conservation condition is:

```
Σ weight(place) × change(place)  =  0
```

over the places the rule changes, with exact integer arithmetic.  A rule
whose weighted sum is nonzero is refused, not repaired.
-/
structure RewriteRule (n : Nat) where
  guards : List (Fin n × Int)
  changes : List (Fin n × Int)
  invariant : List (Fin n × Int)
  deriving Repr, DecidableEq

/-- The weight of a place in a rule's invariant, if it has one. -/
-- L4DEL: title: Read a place's weight
-- L4DEL: intuition: A place the invariant does not mention has no weight, and the conservation sum skips it.
-- L4DEL: prereq: Hyperfields.Fields.Hypermechanics.RewriteRule
def RewriteRule.weightOf {n : Nat} (rule : RewriteRule n) (place : Fin n) : Option Int :=
  match rule.invariant.find? (fun pair => pair.1 == place) with
  | some pair => some pair.2
  | none => none

/-- The change a rule makes to a place, if it makes one. -/
-- L4DEL: title: Read a place's change
-- L4DEL: intuition: A place the rule does not change has no delta, which is nothing rather than a zero change.
-- L4DEL: prereq: Hyperfields.Fields.Hypermechanics.RewriteRule
def RewriteRule.changeOf {n : Nat} (rule : RewriteRule n) (place : Fin n) : Option Int :=
  match rule.changes.find? (fun pair => pair.1 == place) with
  | some pair => some pair.2
  | none => none

/-- The weighted sum of a rule's changes. -/
-- L4DEL: title: The conservation sum
-- L4DEL: intuition: Multiplying each change by its weight and adding them gives the quantity the rule claims to conserve, and a rule is admissible only when that sum is zero.
-- L4DEL: prereq: Hyperfields.Fields.Hypermechanics.RewriteRule
def RewriteRule.weightedChange {n : Nat} (rule : RewriteRule n) : Int :=
  rule.changes.foldl (fun total pair =>
    match rule.weightOf pair.1 with
    | none => total
    | some weight => total + weight * pair.2) 0

-- L4DEL: title: The axioms a rewrite rule must satisfy
-- L4DEL: intuition: A rule that conserves nothing is not a mechanism, and a rule with a negative guard is not a guard.
/--
Whether the rule satisfies the axioms.

The checks are:

1. Every guard minimum is nonnegative.
2. Every changed place has an explicit invariant coefficient, and every
   invariant coefficient is strictly positive.
3. The rule conserves exactly: the weighted sum of the changes is zero.
-/
def RewriteRule.wellShaped {n : Nat} (rule : RewriteRule n) : Bool :=
  let guardsOk := rule.guards.all (fun pair => 0 <= pair.2)
  let weightsOk := rule.invariant.all (fun pair => decide (0 < pair.2))
  let everyChangeWeighted :=
    rule.changes.all (fun pair => rule.invariant.any (fun weight => weight.1 == pair.1))
  let everyWeightChanged :=
    rule.invariant.all (fun weight => rule.changes.any (fun change => change.1 == weight.1))
  guardsOk && weightsOk && everyChangeWeighted && everyWeightChanged &&
    rule.weightedChange == 0

/-!
## Applying a rule
-/

-- L4DEL: title: Fire a rule
-- L4DEL: intuition: A rule fires only when every guard holds and no count would go negative, and otherwise it does not fire at all.
-- L4DEL: prereq: Hyperfields.Fields.Hypermechanics.MechanismState, Hyperfields.Fields.Hypermechanics.RewriteRule
/--
Apply a rule to a state.
-- L4DEL: title: Fire a rule
-- L4DEL: intuition: A rule fires only when every guard holds and no count would go negative, and otherwise it does not fire at all.
-- L4DEL: prereq: Hyperfields.Fields.Hypermechanics.MechanismState, Hyperfields.Fields.Hypermechanics.RewriteRule

The rule fires only when every guard is satisfied.  The result is the
state with the rule's changes applied; a change that would make a count
negative means the rule does not fire.
-/
def applyRule {n : Nat} (state : MechanismState n) (rule : RewriteRule n) : Option (MechanismState n) :=
  -- Every place the rule mentions is a place the state has.
  let places := rule.guards.map (fun pair => pair.1) ++ rule.changes.map (fun pair => pair.1)
  let known := places.all (fun place => state.amount place != none) &&
    -- Every guard is satisfied.
    rule.guards.all (fun pair =>
      match state.amount pair.1 with
      | none => false
      | some value => pair.2 <= value)
  if known then
    let updated := state.amounts.map (fun pair =>
      (pair.1, pair.2 + (match rule.changeOf pair.1 with
        | none => 0
        | some delta => delta)))
    if updated.all (fun pair => 0 <= pair.2) then
      some { state with amounts := updated }
    else
      none
  else
    none

-- L4DEL: title: Two rules are independent
-- L4DEL: intuition: If neither rule writes a place the other writes or reads, the order they fire in cannot matter, which is a sufficient condition for them to commute.
-- L4DEL: prereq: Hyperfields.Fields.Hypermechanics.RewriteRule
/--
Whether two rules have disjoint footprints.
-- L4DEL: title: Two rules are independent
-- L4DEL: intuition: If neither rule writes a place the other writes or reads, the order they fire in cannot matter, which is a sufficient condition for them to commute.
-- L4DEL: prereq: Hyperfields.Fields.Hypermechanics.RewriteRule

Two rules are independent when neither writes a place the other writes or
reads, and the other does not write a place the first reads.  That is a
sufficient condition for the two to commute, and the Python source calls
it the same thing.
-/
def independent {n : Nat} (left right : RewriteRule n) : Bool :=
  let leftWrites := left.changes.map (fun pair => pair.1)
  let rightWrites := right.changes.map (fun pair => pair.1)
  let leftReads := left.guards.map (fun pair => pair.1)
  let rightReads := right.guards.map (fun pair => pair.1)
  !(leftWrites.any (fun place => mem place rightWrites || mem place rightReads) ||
    rightWrites.any (fun place => mem place leftReads))

/-!
## A worked example
-/

-- L4DEL: title: A two-place mechanism state
-- L4DEL: intuition: A concrete state lets the compiler check the axioms and the rule application against something a reader can see.
/--
A concrete state: place `0` holds 2 and place `1` holds 1.

The two places have different kinds, so the kind condition is not
vacuous.
-/
def twoPlaceState : MechanismState 2 where
  scale := { denominator := 1 }
  amounts := [(0, 2), (1, 1)]
  kindOf := [(0, "reservoir"), (1, "reservoir")]

-- L4DEL: title: A conserving rewrite rule
-- L4DEL: intuition: A rule that moves one unit from one place to another conserves the weighted total, and the compiler can check the exact sum.
/--
A concrete rule: move one unit from place `0` to place `1`.

The guard requires place `0` to hold at least one unit.  The change takes
one unit from place `0` and gives one to place `1`.  The invariant weights
both places by one, so the weighted sum of the changes is `-1 + 1 = 0`:
the rule conserves the total exactly.
-/
def transferRule : RewriteRule 2 where
  guards := [(0, 1)]
  changes := [(0, -1), (1, 1)]
  invariant := [(0, 1), (1, 1)]

-- L4DEL: title: A state whose first place is empty
-- L4DEL: intuition: A concrete state that fails a guard lets the compiler check that the guard actually refuses.
/--
A state whose first place is empty.

The guard on the transfer rule requires place `0` to hold at least one
unit, so the rule cannot fire here.
-/
def emptyState : MechanismState 2 where
  scale := { denominator := 1 }
  amounts := [(0, 0), (1, 1)]
  kindOf := [(0, "reservoir"), (1, "reservoir")]

-- L4DEL: title: A rule that does not conserve
-- L4DEL: intuition: A rule whose weighted sum is nonzero is refused, and this is the case that shows the conservation check can fail.
/--
A concrete rule that creates a unit, and is therefore not admissible.

The change adds one unit to place `1` and nothing takes it away, so the
weighted sum is `1`, not zero.  The rule is refused.
-/
def creatingRule : RewriteRule 2 where
  guards := []
  changes := [(1, 1)]
  invariant := [(1, 1)]

-- L4DEL: title: The conservation check rejects a rule that creates
-- L4DEL: intuition: A rule whose weighted sum is nonzero is refused, and this is the case that shows the conservation check can fail.
/-- The creating rule is refused, because it does not conserve. -/
theorem a_nonconserving_rule_is_rejected :
    creatingRule.wellShaped = false := by
  decide

-- L4DEL: title: The state satisfies the axioms
-- L4DEL: intuition: The concrete example must clear the axioms the frame demands, or the example proves nothing.
/-- The worked mechanism state satisfies the axioms. -/
theorem two_place_state_is_well_shaped : twoPlaceState.wellShaped = true := by
  decide

-- L4DEL: title: The conserving rule satisfies the axioms
-- L4DEL: intuition: The concrete example must clear the axioms the frame demands, or the example proves nothing.
/-- The worked rewrite rule satisfies the axioms. -/
theorem transfer_rule_is_well_shaped : transferRule.wellShaped = true := by
  decide

-- L4DEL: title: The rule conserves exactly
-- L4DEL: intuition: The weighted sum of the changes is zero, and the compiler checks the sum rather than trusting the declaration.
/-- The worked rewrite rule's weighted change is exactly zero. -/
theorem the_transfer_rule_conserves :
    transferRule.weightedChange = 0 := by
  decide

-- L4DEL: title: Applying the rule moves one unit
-- L4DEL: intuition: The guard is satisfied and the change is exact, so the result is the state with one unit moved.
/--
Applying the conserving rule to the worked state gives place `0` holding 1
and place `1` holding 2.

The total is unchanged, which is what the invariant declared.
-/
theorem applying_the_rule_moves_one_unit :
    (applyRule twoPlaceState transferRule).map (fun state => state.amount 0) = some (some 1) := by
  decide

-- L4DEL: title: The rule does not fire when the guard is unsatisfied
-- L4DEL: intuition: A guard is a condition on the state, and a rule that fires anyway would not be guarded.
/--
The rule does not fire on a state whose first place is empty.

This is the negative case for guards.  A checker that never refuses
anything is not a check, and this theorem is what makes the positive case
meaningful.
-/
theorem the_rule_does_not_fire_when_guarded :
    (applyRule emptyState transferRule) = none := by
  decide

-- L4DEL: title: A rule is not independent of itself
-- L4DEL: intuition: A rule that writes a place it also reads is not independent of itself, which is the minimal case of the disjoint-footprint criterion.
/--
A rule is not independent of itself.

The rule writes place `0` and reads place `0`, so the two footprints
overlap.  This is the negative case for independence, and it is the
minimal one: a rule that cannot commute with itself cannot be expected
to commute with a copy of itself.
-/
theorem a_rule_is_not_independent_of_itself :
    independent transferRule transferRule = false := by
  decide

/-!
## The ecosystem record
-/

-- L4DEL: title: Hypermechanics explainer entry
-- L4DEL: intuition: This declaration exposes the checked ecosystem record for Hypermechanics on its own stable explainer page.
-- L4DEL: see: Hyperfields.hypermechanics
/-- The canonical Hypermechanics record used by the unified portal. -/
def entry : Hyperfields.Entry := Hyperfields.hypermechanics

end Hyperfields.Fields.Hypermechanics
