import Hyperfields.Registry
import Hyperfields.Finite

/-!
# Hyperorganization

[FRAME] The ordinal phase of a graph of reliance, and the arithmetic of
amendment.

This is the Lean port of the core results in `hyperoptimization`'s
`entrenchment` and `family` modules. It carries three results:

1. **The ordinal phase of a graph of reliance.** A node's phase is 0 if it
   relies on nothing, one more than the largest phase among what it relies
   on, and ω if its reliance never bottoms out.
2. **Protection, the weakest link.** A rule's protection is the price of
   the cheapest procedure among the rules above it. This is Ross's
   paradox: a clause an ordinary majority can amend is protected by an
   ordinary majority, whatever the clause says of itself.
3. **Authority height.** The number of governors above a rule before the
   chain ends, or ω when it never does.

Every result is finite and mechanical. A graph over a carrier of known
size is a list of edges, and the phase is computed by the same round-by-round
peeling the Python source uses. So the compiler can check the result
against a concrete graph.

What is **not** proved here, and cannot be, is any claim that the graphs
these results are applied to are the right ones, that a citation is a
dependence, or that a phase means anything outside the graph. The Python
source makes the same refusals: a citation is evidence that one repository
mentions another, not that it needs it. This port keeps the `[FRAME]`
classification.
-/

namespace Hyperfields.Fields.Hyperorganization

open Hyperfields.Finite

/-!
## The phase of a graph of reliance
-/

/--
The phase of a node: a natural number, or ω when the node's reliance never
bottoms out.

The `omega` case is not a large number.  It says the node lies on a cycle,
or relies on something that does, and so has no finite rank.
-/
inductive Phase where
  | finite (value : Nat)
  | omega
  deriving Repr, BEq, DecidableEq

-- L4DEL: title: The phase of a node in a graph of reliance
-- L4DEL: intuition: A node that relies on nothing has phase 0, a node that relies on finite-phase nodes has one more than the largest of them, and a node whose reliance never bottoms out has no finite phase at all.
/--
The phase of every node of a graph of reliance.

The graph is given as a list of edges `(source, target)` read as *source
relies on target*.  The phase is computed by peeling rounds: round 0 takes
every node whose dependencies were all taken in earlier rounds (which
means a node that relies on nothing), round 1 takes the rest, and so on.  A
node never taken lies on a cycle or relies on one, and gets ω.

This is the same round-by-round computation the Python source uses, so the
two agree by construction rather than by inspection.
-/
def phases {n : Nat} (edges : List (Fin n × Fin n)) : List (Fin n × Phase) :=
  let nodes : List (Fin n) := carrier n
  -- The direct dependencies of each node.
  let deps : Fin n → List (Fin n) := fun node =>
    (edges.filter (fun edge => edge.1 == node)).map (fun edge => edge.2)
  -- Peel up to `n` rounds: a node that is ever taken is taken by round
  -- `n - 1`, so `n` rounds is enough to settle every finite phase.
  let taken := (List.range (n + 1)).foldl (fun takenSoFar layer =>
    let ready := nodes.filter (fun node =>
      !takenSoFar.any (fun entry => entry.1 == node) &&
      (deps node).all (fun dependency =>
        takenSoFar.any (fun entry => entry.1 == dependency)))
    takenSoFar ++ ready.map (fun node => (node, layer))) ([] : List (Fin n × Nat))
  nodes.map (fun node =>
    match taken.find? (fun entry => entry.1 == node) with
    | some entry => (node, .finite entry.2)
    | none => (node, .omega))

/-- The phase of one node. -/
def phaseOf {n : Nat} (edges : List (Fin n × Fin n)) (node : Fin n) : Phase :=
  match (phases edges).find? (fun entry => entry.1 == node) with
  | some entry => entry.2
  | none => .omega

/-- Whether a node's phase is finite. -/
def Phase.isFinite : Phase → Bool
  | .finite _ => true
  | .omega => false

/-!
## Governance: the arithmetic of amendment
-/

-- L4DEL: title: A rule and the rule that governs it
-- L4DEL: intuition: A rule carries the price of the procedure that changes it and names the rule that governs it, and the two together decide how hard the rule is to change.
/--
A rule: the price in bits of the procedure that changes it, and the rule
that governs it.

The governor is optional.  A rule with no governor is unamendable, and
that is what an apex is.
-/
structure Rule (n : Nat) where
  index : Fin n
  price : Nat
  governedBy : Option (Fin n)
  deriving Repr, DecidableEq

-- L4DEL: title: The rules above a rule, following governors
-- L4DEL: intuition: Protection and authority are both about the chain of governors above a rule, so that chain is the shared object both results compute from.
/--
The rules above a rule, in order, and whether the chain ended.

The chain ends when it reaches a rule nothing governs.  It does not end
when it returns to a rule it has already met, and that is exactly the
distinction between a finite authority height and ω.

The walk is a bounded iteration rather than a recursive function.  A
governance chain in a set of `n` rules visits at most `n` distinct rules
before it must either end or repeat, so `n` steps settle it.  The bounded
form is also what lets the compiler check the result: a recursive function
would need a termination proof, and a bounded scan is decidable outright.
-/
def chainAbove {n : Nat} (rules : List (Rule n)) (start : Fin n) :
    List (Fin n) × Bool :=
  let governor : Fin n → Option (Fin n) := fun node =>
    match rules.find? (fun rule => rule.index == node) with
    | some rule => rule.governedBy
    | none => none
  -- The chain after `k` steps, as the governors met and the next to visit.
  let step : List (Fin n) × Option (Fin n) → List (Fin n) × Option (Fin n) :=
    fun (above, current) =>
      match current with
      | none => (above, none)
      | some node =>
          if above.any (fun visited => visited == node) then
            -- The chain has returned to a governor it already met: it does not end.
            (above, some node)
          else
            (above ++ [node], governor node)
  -- The walk starts at the governor of `start`, not at `start` itself: the
  -- rules above a rule do not include the rule itself.
  let result := (List.range (n + 1)).foldl (fun state _ => step state) ([], governor start)
  -- The chain ended exactly when the last position had no governor.
  (result.1, result.2.isNone)

/--
The protection of a rule: the price of the cheapest procedure among the
rules above it.

This is the weakest link in the chain of authority.  To change a rule you
may satisfy the procedure of its governor, or first change the governor
and then change the rule for nothing.  The cheapest way is therefore the
cheapest procedure anywhere above the rule, which is what the minimum
computes.

Around a cycle every member is above every other, so every member has the
same protection: the cheapest procedure on the cycle.  That is Ross's
paradox, and it is a consequence of the formula rather than an extra
assumption.
-/
def protection {n : Nat} (rules : List (Rule n)) (start : Fin n) : Option Nat :=
  let (above, _) := chainAbove rules start
  let prices := above.filterMap (fun node =>
    match rules.find? (fun rule => rule.index == node) with
    | some rule => some rule.price
    | none => none)
  match prices with
  | [] => none
  | first :: rest => some (rest.foldl (fun best price => if price < best then price else best) first)

/--
The authority height of a rule: the number of governors above it before
the chain ends.

The height is finite exactly when the chain ends at a rule that nothing
governs.  If every rule has a governor, then in a finite set every chain
returns to itself and every height is ω: a constitution that obeys the
no-apex rule has no finite rank for validity at all.
-/
def authorityHeight {n : Nat} (rules : List (Rule n)) (start : Fin n) : Phase :=
  let (above, ended) := chainAbove rules start
  if ended then .finite above.length else .omega

/-!
## A worked example
-/

-- L4DEL: title: A three-node chain of reliance
-- L4DEL: intuition: A concrete graph lets the compiler check the phases against something a reader can see.
/--
A concrete graph: `0` relies on `1`, `1` relies on `2`, and `2` relies on
nothing.

The phases are the obvious ones, and the compiler checks them.
-/
def chainEdges : List (Fin 3 × Fin 3) := [(0, 1), (1, 2)]

-- L4DEL: title: A graph with a cycle
-- L4DEL: intuition: A cycle is the case where reliance never bottoms out, and the compiler has to be able to see that it does not.
/--
A concrete graph with a cycle: `0` relies on `1` and `1` relies on `0`.

Neither node has a finite phase, because neither one's reliance bottoms
out.
-/
def cyclicEdges : List (Fin 2 × Fin 2) := [(0, 1), (1, 0)]

-- L4DEL: title: A node that relies on a cycle
-- L4DEL: intuition: A node above a cycle never bottoms out, and the compiler has to be able to see the phase propagate.
/--
A concrete graph where one node relies on a cycle.

Node `0` relies on `1`, and `1` and `2` rely on each other.  Node `0` is
not itself on the cycle, but it relies on one, so its reliance never
bottoms out either.
-/
def aboveCycleEdges : List (Fin 3 × Fin 3) := [(0, 1), (1, 2), (2, 1)]

-- L4DEL: title: A constitution with an apex
-- L4DEL: intuition: A constitution with an unamendable rule at the top has finite authority heights, and the compiler can check the exact numbers.
/--
A concrete constitution: rule `0` is governed by rule `1`, rule `1` is
governed by rule `2`, and rule `2` is governed by nothing.

Rule `2` is the apex.  The authority heights are 2, 1, and 0.
-/
def constitution : List (Rule 3) := [
  { index := 0, price := 5, governedBy := some 1 },
  { index := 1, price := 3, governedBy := some 2 },
  { index := 2, price := 9, governedBy := none }
]

-- L4DEL: title: A constitution with a cycle of rules
-- L4DEL: intuition: A cycle of rules has no apex, so every height is omega, and that is the case Ross's paradox is about.
/--
A concrete constitution with a cycle: rule `0` is governed by rule `1` and
rule `1` is governed by rule `0`.

Neither rule has a finite authority height, and both have the same
protection, because around a cycle every member is above every other.
-/
def cyclicConstitution : List (Rule 2) := [
  { index := 0, price := 4, governedBy := some 1 },
  { index := 1, price := 7, governedBy := some 0 }
]

-- L4DEL: title: The chain graph's phases
-- L4DEL: intuition: The phase of a node in a chain is its distance from the node that relies on nothing.
/-- The chain graph has phases 2, 1, and 0. -/
theorem chain_phases :
    phases chainEdges = [(0, .finite 2), (1, .finite 1), (2, .finite 0)] := by
  decide

-- L4DEL: title: A cycle has no finite phase
-- L4DEL: intuition: Reliance that goes round in a circle never bottoms out, so the phase is omega rather than a large number.
/-- Neither node of the cyclic graph has a finite phase. -/
theorem cyclic_phases_are_omega :
    phases cyclicEdges = [(0, .omega), (1, .omega)] := by
  decide

-- L4DEL: title: A node that relies on a cycle has no finite phase either
-- L4DEL: intuition: The phase of omega spreads to everything that relies on it, so a node downstream of a cycle is also omega.
/--
The node that relies on a cycle has no finite phase.

This is the propagation the Python source describes: a node never taken
relies on a cycle, and so does everything that relies on it.
-/
theorem a_node_above_a_cycle_is_omega :
    phases aboveCycleEdges = [(0, .omega), (1, .omega), (2, .omega)] := by
  decide

-- L4DEL: title: The authority heights of a constitution with an apex
-- L4DEL: intuition: The height of a rule is the number of governors above it before the chain ends at the apex.
/-- The constitution's authority heights are 2, 1, and 0. -/
theorem constitution_authority_heights :
    (authorityHeight constitution 0, authorityHeight constitution 1,
      authorityHeight constitution 2) =
      (.finite 2, .finite 1, .finite 0) := by
  decide

-- L4DEL: title: A cycle of rules has no finite authority height
-- L4DEL: intuition: A constitution with no apex has no finite rank for validity at all, and the height of every rule is omega.
/-- Neither rule of the cyclic constitution has a finite authority height. -/
theorem cyclic_authority_heights_are_omega :
    (authorityHeight cyclicConstitution 0, authorityHeight cyclicConstitution 1) =
      (.omega, .omega) := by
  decide

-- L4DEL: title: Protection is the weakest link
-- L4DEL: intuition: The cheapest way to change a rule is the cheapest procedure among the rules above it, so the weakest link governs.
/--
The protection of rule `0` is 3, not 5.

Rule `0` is governed by rule `1`, whose procedure costs 3.  Satisfying
rule `1`'s procedure is cheaper than satisfying rule `2`'s, which costs 9,
so the weakest link is what protects rule `0`.  This is the whole content
of the protection formula.
-/
theorem protection_is_the_weakest_link :
    protection constitution 0 = some 3 := by
  decide

-- L4DEL: title: An apex protects the rules beneath it
-- L4DEL: intuition: The apex is the only rule above the top of the chain, so its procedure price is the protection of everything beneath.
/-- The protection of rule `1` is 9, the price of the apex's procedure. -/
theorem the_apex_protects_the_rule_beneath_it :
    protection constitution 1 = some 9 := by
  decide

-- L4DEL: title: An ungoverned rule has no protection
-- L4DEL: intuition: A rule nothing governs cannot be changed through any procedure, so there is no price to report.
/--
The apex's protection is absent rather than infinite.

The Python source reports `inf` for this case.  Here the absence is
represented by `none`, which is a stronger statement: there is no
procedure that changes it, not merely an unboundedly expensive one.
-/
theorem an_ungoverned_rule_has_no_protection :
    protection constitution 2 = none := by
  decide

-- L4DEL: title: A cycle gives every member the same protection
-- L4DEL: intuition: Around a cycle every member is above every other, so the cheapest procedure on the cycle protects them all equally.
/--
Both rules of the cyclic constitution have protection 4.

The cycle's procedures cost 4 and 7, and around a cycle every member is
above every other, so the cheaper one protects both.  This is Ross's
paradox: an entrenched clause is protected by whatever the cheapest
procedure on the cycle happens to be.
-/
theorem a_cycle_gives_every_member_the_same_protection :
    (protection cyclicConstitution 0, protection cyclicConstitution 1) =
      (some 4, some 4) := by
  decide

/-!
## The ecosystem record
-/

-- L4DEL: title: Hyperorganization explainer entry
-- L4DEL: intuition: This declaration exposes the checked ecosystem record for Hyperorganization on its own stable explainer page.
-- L4DEL: see: Hyperfields.hyperorganization
/-- The canonical Hyperorganization record used by the unified portal. -/
def entry : Hyperfields.Entry := Hyperfields.hyperorganization

end Hyperfields.Fields.Hyperorganization
