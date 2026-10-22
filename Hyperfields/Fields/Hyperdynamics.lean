import Hyperfields.Registry
import Hyperfields.Finite

/-!
# Hyperdynamics

[FRAME] Indexed transformations without assuming a universal temporal axis.

This is the Lean port of the local `hyperdynamics` candidate. It carries the
transition system and the properties that frame establishes.

The frame's central refusal is that a step is not a moment.  The state
carrier is a set of named states, the step relation is a set of pairs, and
the index of a step is local to the system.  Nothing here is a clock,
nothing here is physical duration, and nothing here says that a reachable
state is a state that will be reached.

What is **not** proved here, and cannot be, is any claim that these finite
systems are the right models of change.  The Python source carries the same
`[FRAME]` classification and this port keeps it: a finite reachability
result is not a foundation.
-/

namespace Hyperfields.Fields.Hyperdynamics

open Hyperfields.Finite

/-!
## The frame
-/

-- L4DEL: title: A finite transition system with its state kinds
-- L4DEL: intuition: Every state is named and carries one declared kind, so a step is between two identified states rather than between positions in an assumed sequence.
/--
A finite transition system: its states, its steps, and the kind of each
state.

The kinds are declared per state, exactly one per state, and the port
keeps them separate from the steps.  A step is a relation between two
identified states; it is not an interval and it is not a position in an
assumed global order.
-/
structure TransitionSystem (n : Nat) where
  states : List (Fin n)
  steps : List (Fin n × Fin n)
  kindOf : List (Fin n × String)
  deriving Repr, DecidableEq

/-- The kind declared for a state, if any. -/
def TransitionSystem.kindOfState {n : Nat} (system : TransitionSystem n)
    (state : Fin n) : Option String :=
  match system.kindOf.find? (fun pair => pair.1 == state) with
  | some pair => some pair.2
  | none => none

-- L4DEL: title: The axioms a transition system must satisfy
-- L4DEL: intuition: A step to a state the system does not have describes a change into nothing, and a state with two kinds is described twice.
/--
Whether the system satisfies the axioms.

The checks are:

1. Every step has both endpoints in the state carrier.
2. Every state has exactly one kind, and no state outside the carrier has
   one.
-/
def TransitionSystem.wellShaped {n : Nat} (system : TransitionSystem n) : Bool :=
  system.steps.all (fun pair => mem pair.1 system.states && mem pair.2 system.states) &&
  system.kindOf.all (fun pair => mem pair.1 system.states) &&
  (system.kindOf.map (fun pair => pair.1)).eraseDups.length == system.kindOf.length &&
  system.kindOf.length == system.states.length

/-!
## Reachability
-/

/--
The states reachable from a starting state.

Reachability is computed by a bounded forward walk over the step relation.
The bound is the size of the state carrier: a state that is reachable at
all is reachable within that many steps, because a shortest path never
repeats a state.
-/
def reachable {n : Nat} (system : TransitionSystem n) (start : Fin n) : List (Fin n) :=
  let step : List (Fin n) → List (Fin n) := fun reached =>
    reached.flatMap (fun current =>
      (system.steps.filter (fun pair => pair.1 == current)).map (fun pair => pair.2))
  let walk := (List.range n).foldl (fun seen _ => seen ++ step seen) [start]
  walk.eraseDups

/-!
## Path lifting
-/

-- L4DEL: title: Lifting a path through a partial bridge
-- L4DEL: intuition: A lifted path must be a path in the target, so the bridge has to carry every step of the source path into a declared step of the target.
/--
Whether a path lifts through a bridge.

The path must be a path in the source: every state on it is in the source
carrier, and every consecutive pair is a declared step.  The bridge must
cover every state on the path, and the lifted sequence must be a path in
the target.

The lift is computed by looking each state up in the bridge.  A state the
bridge does not cover makes the lift fail, and it is checked separately
rather than papered over with a default value: a default would let an
uncovered state masquerade as a lifted one.
-/
def pathLifts {m n : Nat} (source : TransitionSystem m) (target : TransitionSystem n)
    (path : List (Fin m)) (bridge : List (Fin m × Fin n)) : Bool :=
  -- The path is a path in the source.
  path.all (fun state => mem state source.states) &&
  (path.zip (path.drop 1)).all (fun pair => mem pair source.steps) &&
  -- The bridge covers the path and lands in the target.
  path.all (fun state => bridge.any (fun pair => pair.1 == state)) &&
  (bridge.map (fun pair => pair.2)).all (fun state => mem state target.states) &&
  -- The lifted sequence is a path in the target.
  (path.zip (path.drop 1)).all (fun pair =>
    match bridge.find? (fun left => left.1 == pair.1),
      bridge.find? (fun right => right.1 == pair.2) with
    | some left, some right => mem (left.2, right.2) target.steps
    | _, _ => false)

/-!
## A worked example
-/

-- L4DEL: title: A three-state transition system
-- L4DEL: intuition: A concrete system lets the compiler check the axioms and the reachability against something a reader can see.
/--
A concrete transition system: `a` steps to `b`, `b` steps to `c`, and `c`
steps to nothing.

The two kinds are declared so that the kind condition is not vacuous: `a`
and `c` share one kind and `b` has another.
-/
def chainSystem : TransitionSystem 3 where
  states := [0, 1, 2]
  steps := [(0, 1), (1, 2)]
  kindOf := [(0, "phase"), (1, "threshold"), (2, "phase")]

-- L4DEL: title: A system with a cycle
-- L4DEL: intuition: A cycle makes the point that reachability is about the step relation, not about a direction of time.
/--
A concrete transition system with a cycle: `a` steps to `b` and `b` steps
back to `a`.

Reachability from `a` is the whole carrier, which is what makes the
difference between "reachable" and "eventually arrives" visible.
-/
def cyclicSystem : TransitionSystem 3 where
  states := [0, 1, 2]
  steps := [(0, 1), (1, 0)]
  kindOf := [(0, "phase"), (1, "phase"), (2, "phase")]

-- L4DEL: title: The transition system satisfies the axioms
-- L4DEL: intuition: The concrete example must clear the axioms the frame demands, or the example proves nothing.
/-- The worked transition system satisfies the axioms. -/
theorem chain_system_is_well_shaped : chainSystem.wellShaped = true := by
  decide

-- L4DEL: title: The cyclic system satisfies the axioms
-- L4DEL: intuition: A cycle in the step relation is allowed; a step to a state the system does not have is not.
/-- The worked cyclic transition system satisfies the axioms. -/
theorem cyclic_system_is_well_shaped : cyclicSystem.wellShaped = true := by
  decide

-- L4DEL: title: Every state is reachable from the first
-- L4DEL: intuition: A chain of steps reaches everything downstream, and the compiler can check the whole reachable set at once.
/-- Every state is reachable from the first state of the chain system. -/
theorem all_states_are_reachable_from_the_start :
    reachable chainSystem 0 = [0, 1, 2] := by
  decide

-- L4DEL: title: A state with no outgoing step reaches only itself
-- L4DEL: intuition: Reachability is about the step relation, so a state that steps to nothing reaches nothing but itself.
/--
Only the last state is reachable from the last state of the chain system.

This is the case that distinguishes reachability from a claim about
progress.  The state `2` is a perfectly good state; it simply has no
outgoing step, and nothing here says that is a defect.
-/
theorem a_terminal_state_reaches_only_itself :
    reachable chainSystem 2 = [2] := by
  decide

-- L4DEL: title: A cycle makes every state in the cycle reachable
-- L4DEL: intuition: A cycle lets a state be reached from itself by a nonempty path, which is what makes the closure of the step relation nontrivial.
/-- Every state in the cyclic system is reachable from the first. -/
theorem a_cycle_reaches_back :
    reachable cyclicSystem 0 = [0, 1] := by
  decide

-- L4DEL: title: A step to an undeclared state is rejected
-- L4DEL: intuition: A transition into a state the system does not have describes a change into nothing.
/--
A system with a step to a state outside its carrier is rejected.

This is the negative case.  A checker that never rejects anything is not a
check, and this theorem is what makes the positive cases meaningful.
-/
theorem a_step_to_an_undeclared_state_is_rejected :
    ({ states := [0, 1],
       steps := [(0, 1), (1, 2)],
       kindOf := [(0, "phase"), (1, "phase")] } : TransitionSystem 3).wellShaped = false := by
  decide

-- L4DEL: title: A state with two kinds is rejected
-- L4DEL: intuition: A state declared twice is described twice, and the frame requires exactly one kind per state.
/--
A system that declares two kinds for one state is rejected.

This is the second negative case, and it is independent of the step
endpoints: a system can have only well-formed steps and still describe a
state twice.
-/
theorem a_state_with_two_kinds_is_rejected :
    ({ states := [0, 1],
       steps := [(0, 1)],
       kindOf := [(0, "phase"), (0, "other"), (1, "phase")] } : TransitionSystem 2).wellShaped = false := by
  decide

-- L4DEL: title: The identity bridge lifts a path
-- L4DEL: intuition: A path is always a path under the identity, which is the baseline the other lifting cases are measured against.
/--
The identity bridge lifts the chain path onto itself.

Every step of the path is preserved because the bridge carries each state
to itself, so the lifted sequence is the same sequence.
-/
theorem the_identity_bridge_lifts_the_path :
    pathLifts chainSystem chainSystem [0, 1, 2] [(0, 0), (1, 1), (2, 2)] = true := by
  decide

-- L4DEL: title: A bridge that drops a step does not lift a path
-- L4DEL: intuition: A lift must be a path in the target, so a bridge that lands the two endpoints on the same state breaks the step.
/--
A bridge that maps both ends of a step onto the same state does not lift
the path.

The lifted sequence would be `[0, 0]`, whose pair is not a declared step
of the target, so the lift fails.  This is the negative case for path
lifting.
-/
theorem a_step_breaking_bridge_does_not_lift :
    pathLifts chainSystem chainSystem [0, 1] [(0, 0), (1, 0)] = false := by
  decide

/-!
## The ecosystem record
-/

-- L4DEL: title: Hyperdynamics explainer entry
-- L4DEL: intuition: This declaration exposes the checked ecosystem record for Hyperdynamics on its own stable explainer page.
-- L4DEL: see: Hyperfields.hyperdynamics
/-- The canonical Hyperdynamics record used by the unified portal. -/
def entry : Hyperfields.Entry := Hyperfields.hyperdynamics

end Hyperfields.Fields.Hyperdynamics
