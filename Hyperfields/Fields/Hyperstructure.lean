import Hyperfields.Registry
import Hyperfields.Finite

/-!
# Hyperstructure

[FRAME] Independent class, containment, composition and recursive relations.

This is the Lean port of the local `hyperstructure` candidate. It carries
the sempiternality view and the recursive structure, and the properties
that frame establishes.

The frame keeps four relations apart rather than collapsing them into one
"relation": an abstract member is an *instance of* a class, a contained
item is *contained by* a whole, a component is *component of* a whole, and
a recursive structure adds *contains*, *represents*, and *connects*. The
port keeps that separation, because the whole point of the field is that
these are independent.

The four designated kinds are the frame's own requirement, not a theorem
about kinds in general: `base-reality`, `surreality`, `preality`, and
`areality` must all be declared, must be pairwise distinct, and a
composition must contain a representative of each.

What is **not** proved here, and cannot be, is any claim that these four
kinds are the right kinds, that they are exhaustive, or that composition
follows from kind distinction. The Python source carries the same
`[FRAME]` classification and this port keeps it.
-/

namespace Hyperfields.Fields.Hyperstructure

open Hyperfields.Finite

/-!
## The designated kinds
-/

/--
The four designated kinds.

These are the kinds the frame requires.  They are named, not derived: the
field declares that a presentation must distinguish these four, and it does
not claim that they are the only kinds there are.
-/
-- L4DEL: title: The four designated kinds
-- L4DEL: intuition: The frame requires a presentation to distinguish these four kinds, and it does not claim they are the only kinds there are.
def requiredKinds : List String := ["base-reality", "surreality", "preality", "areality"]

/-- Whether every designated kind is declared. -/
-- L4DEL: title: All four kinds are declared
-- L4DEL: intuition: A presentation that omits one of the four designated kinds has not distinguished it, so the check requires all four.
-- L4DEL: prereq: Hyperfields.Fields.Hyperstructure.requiredKinds
def declaresAllRequiredKinds (declared : List String) : Bool :=
  requiredKinds.all (fun kind => mem kind declared)

/-- Whether the declared kinds are pairwise distinct. -/
-- L4DEL: title: The kinds are distinct
-- L4DEL: intuition: Two names for one kind would make the taxonomy say less than it appears to, so the list is checked to have no repeats.
-- L4DEL: prereq: Hyperfields.Fields.Hyperstructure.requiredKinds
def kindsAreDistinct (declared : List String) : Bool :=
  declared.eraseDups.length == declared.length

/-!
## The sempiternality view
-/

-- L4DEL: title: A presentation of a whole with its members and kinds
-- L4DEL: intuition: A view separates what a member is an instance of, what it is contained by, and what it is a component of, because those are different relations.
/--
A presentation of a whole: its abstract members, their kinds, what it
contains, and what it is composed of.

The four relation carriers are separate fields on purpose.  Collapsing
them would erase the distinction the field exists to draw.
-/
structure SempiternalityView (n : Nat) where
  subject : Fin n
  kindOf : List (Fin n × String)
  abstractMembers : List (Fin n)
  contained : List (Fin n)
  components : List (Fin n)
  declaredKinds : List String
  deriving Repr, DecidableEq

/-- The kind assigned to a member, if any. -/
-- L4DEL: title: Read a member's kind
-- L4DEL: intuition: A member the view does not classify has no kind, which is nothing rather than a default.
-- L4DEL: prereq: Hyperfields.Fields.Hyperstructure.SempiternalityView
def SempiternalityView.kindOfMember {n : Nat} (view : SempiternalityView n)
    (member : Fin n) : Option String :=
  match view.kindOf.find? (fun pair => pair.1 == member) with
  | some pair => some pair.2
  | none => none

/-- The relations a member stands in, as a list of relation names. -/
-- L4DEL: title: Which relations a member stands in
-- L4DEL: intuition: Being an instance of, being contained by, and being a component of are three different relations, so a member can stand in any combination of them.
-- L4DEL: prereq: Hyperfields.Fields.Hyperstructure.SempiternalityView
def SempiternalityView.relations {n : Nat} (view : SempiternalityView n)
    (member : Fin n) : List String :=
  let instanceOf := if mem member view.abstractMembers then ["instance_of"] else []
  let containedBy := if mem member view.contained then ["contained_by"] else []
  let componentOf := if mem member view.components then ["component_of"] else []
  instanceOf ++ containedBy ++ componentOf

-- L4DEL: title: The axioms a presentation must satisfy
-- L4DEL: intuition: Every abstract member needs exactly one kind, the designated kinds must be declared, and composition must have a representative of each.
/--
Whether the view satisfies the presentation axioms.

The checks are:

1. Every abstract member has exactly one kind assignment, and no member
   outside the abstract members has one.
2. The four designated kinds are all declared, and the declared kinds are
   pairwise distinct.
3. Every assigned kind is a declared kind.
4. Composition requires both class and containment: every component is
   abstract and contained.
5. A composition has a representative of each designated kind.
-/
def SempiternalityView.wellShaped {n : Nat} (view : SempiternalityView n) : Bool :=
  -- Every abstract member has exactly one kind, and nobody else has one.
  view.abstractMembers.all (fun member => view.kindOfMember member != none) &&
  (view.kindOf.all (fun pair => mem pair.1 view.abstractMembers)) &&
  (view.kindOf.map (fun pair => pair.1)).eraseDups.length == view.kindOf.length &&
  view.kindOf.length == view.abstractMembers.length &&
  -- The designated kinds are declared and distinct.
  declaresAllRequiredKinds view.declaredKinds &&
  kindsAreDistinct view.declaredKinds &&
  -- Every assigned kind is declared.
  view.kindOf.all (fun pair => mem pair.2 view.declaredKinds) &&
  -- Composition requires both class and containment.
  view.components.all (fun part => mem part view.abstractMembers && mem part view.contained) &&
  -- A composition has a representative of each designated kind.
  requiredKinds.all (fun kind =>
    view.components.any (fun part => view.kindOfMember part == some kind))

/-!
## The recursive structure
-/

-- L4DEL: title: A finite recursive structure with its three relations
-- L4DEL: intuition: Containment, representation, and connection are different relations, and keeping them apart is what stops a cycle in one from being a cycle in another.
/--
A finite recursive structure: its nodes and its three relations.

`contains` is the containment relation, `represents` the representation
relation, and `connects` the operational connection relation.  A cycle in
one of them says nothing about a cycle in another, which is why the
containment acyclicity check below only looks at `contains`.
-/
structure RecursiveStructure (n : Nat) where
  nodes : List (Fin n)
  contains : List (Fin n × Fin n)
  represents : List (Fin n × Fin n)
  connects : List (Fin n × Fin n)
  deriving Repr, DecidableEq

/-- Whether every endpoint of a relation is one of the structure's nodes. -/
-- L4DEL: title: No dangling endpoints
-- L4DEL: intuition: A relation that names a node the structure does not have is describing something outside the structure, so every endpoint must be a node.
-- L4DEL: prereq: Hyperfields.Fields.Hyperstructure.RecursiveStructure
def RecursiveStructure.noDanglingEndpoints {n : Nat}
    (graph : RecursiveStructure n) : Bool :=
  graph.contains.all (fun pair => mem pair.1 graph.nodes && mem pair.2 graph.nodes) &&
  graph.represents.all (fun pair => mem pair.1 graph.nodes && mem pair.2 graph.nodes) &&
  graph.connects.all (fun pair => mem pair.1 graph.nodes && mem pair.2 graph.nodes)

-- L4DEL: title: Containment has no cycle
-- L4DEL: intuition: A node that can reach itself by following containment is contained in itself, which no well-founded whole allows.
-- L4DEL: step: From each node, walk containment forward n steps and check the node never reappears.
-- L4DEL: prereq: Hyperfields.Fields.Hyperstructure.RecursiveStructure
/--
Whether the containment relation is acyclic.
-- L4DEL: title: Containment has no cycle
-- L4DEL: intuition: A node that can reach itself by following containment is contained in itself, which no well-founded whole allows.
-- L4DEL: step: From each node, walk containment forward n steps and check the node never reappears.
-- L4DEL: prereq: Hyperfields.Fields.Hyperstructure.RecursiveStructure

Containment is acyclic when no node is reachable from itself by following
`contains`.  The check is a bounded reachability scan: from each node, the
set of nodes reachable in one, two, ..., `n` steps must never contain the
node itself, where `n` is the number of nodes.  A cycle among `k` nodes
shows up within `k` steps, so `n` steps is enough to catch every cycle.
-/
def RecursiveStructure.containmentAcyclic {n : Nat}
    (graph : RecursiveStructure n) : Bool :=
  graph.nodes.all (fun node =>
    -- The set of nodes reachable from `node` in one containment step.
    let step : List (Fin n) → List (Fin n) := fun reached =>
      reached.flatMap (fun current =>
        (graph.contains.filter (fun pair => pair.1 == current)).map (fun pair => pair.2))
    -- Walk forward `n` steps, tracking the nodes reached *after* at least
    -- one step.  The starting node is deliberately not seeded into the
    -- tracked set: a node is in a cycle when a step can return to it.
    let reached := (List.range n).foldl (fun seen _ => seen ++ step seen) (step [node])
    !mem node reached)

-- L4DEL: title: The axioms a recursive structure must satisfy
-- L4DEL: intuition: A structure with a dangling endpoint describes something that is not there, and a structure with a containment cycle describes a whole that contains itself.
/--
Whether the structure satisfies the axioms.

The checks are:

1. Every relation endpoint is one of the structure's nodes.
2. The containment relation is acyclic.
-/
def RecursiveStructure.wellShaped {n : Nat} (graph : RecursiveStructure n) : Bool :=
  graph.noDanglingEndpoints && graph.containmentAcyclic

/-!
## A worked example
-/

-- L4DEL: title: A presentation with one member of each designated kind
-- L4DEL: intuition: A concrete view lets the compiler check the axioms against something a reader can see.
/--
A presentation of a whole with four abstract members, one of each
designated kind, all of them contained and all of them components.

Every member is an instance of the class, contained by the whole, and a
component of it, which is what makes this the maximal case rather than a
partial one.
-/
def fullView : SempiternalityView 5 where
  subject := 0
  kindOf := [(1, "base-reality"), (2, "surreality"), (3, "preality"), (4, "areality")]
  abstractMembers := [1, 2, 3, 4]
  contained := [1, 2, 3, 4]
  components := [1, 2, 3, 4]
  declaredKinds := ["base-reality", "surreality", "preality", "areality"]

-- L4DEL: title: The recursive structure of the whole
-- L4DEL: intuition: A concrete structure lets the compiler check the acyclicity and the endpoint conditions.
/--
The recursive structure of the whole: five nodes, the subject containing
the four members, and one operational connection between two members.

There is no representation edge here, which is deliberate: the frame keeps
the three relations independent, and a structure that exercised only two
of them would not show that.
-/
def fullStructure : RecursiveStructure 5 where
  nodes := [0, 1, 2, 3, 4]
  contains := [(0, 1), (0, 2), (0, 3), (0, 4)]
  represents := []
  connects := [(1, 2)]

-- L4DEL: title: The presentation satisfies the axioms
-- L4DEL: intuition: The concrete example must clear the axioms the frame demands, or the example proves nothing.
/-- The worked presentation satisfies the presentation axioms. -/
theorem full_view_is_well_shaped : fullView.wellShaped = true := by
  decide

-- L4DEL: title: The recursive structure satisfies the axioms
-- L4DEL: intuition: The concrete example must clear the axioms the frame demands, or the example proves nothing.
/-- The worked recursive structure satisfies the structure axioms. -/
theorem full_structure_is_well_shaped : fullStructure.wellShaped = true := by
  decide

-- L4DEL: title: A member stands in three relations at once
-- L4DEL: intuition: The point of the field is that instance, containment, and composition are separate relations that can hold of the same member simultaneously.
/--
A member that is abstract, contained, and a component stands in all three
relations.

This is the claim the frame exists to make.  The three relations are
independent, so one member can be in all of them at once without the
relations being identified.
-/
theorem a_member_stands_in_three_relations :
    fullView.relations 1 = ["instance_of", "contained_by", "component_of"] := by
  decide

-- L4DEL: title: A member outside the abstract class stands in no relation
-- L4DEL: intuition: The subject is not an instance of the class it presents, so it stands in none of the three member relations.
/--
The subject of the view stands in none of the three member relations.

The subject is the whole that presents the members, not a member of it.
-/
theorem the_subject_stands_in_no_relation :
    fullView.relations 0 = [] := by
  decide

-- L4DEL: title: The kinds are pairwise distinct
-- L4DEL: intuition: The four designated kinds must be four different kinds, or the taxonomy would collapse.
/-- The four designated kinds are pairwise distinct. -/
theorem the_designated_kinds_are_distinct :
    requiredKinds.eraseDups.length = requiredKinds.length := by
  decide

-- L4DEL: title: A missing designated kind is rejected
-- L4DEL: intuition: The frame requires all four, so a view that omits one is not a presentation of the kind the frame describes.
/--
A view that declares only three of the four designated kinds is rejected.

This is the negative case.  A checker that never rejects anything is not a
check, and this theorem is what makes the positive case meaningful.
-/
theorem a_missing_designated_kind_is_rejected :
    ({ subject := 0,
       kindOf := [(1, "base-reality"), (2, "surreality"), (3, "preality")],
       abstractMembers := [1, 2, 3],
       contained := [1, 2, 3],
       components := [1, 2, 3],
       declaredKinds := ["base-reality", "surreality", "preality"] } :
      SempiternalityView 4).wellShaped = false := by
  decide

-- L4DEL: title: A composition missing a kind is rejected
-- L4DEL: intuition: A composition must represent each designated kind, so dropping one member breaks the composition requirement.
/--
A view whose composition omits the `areality` representative is rejected.

The composition has three members instead of four, so it does not
represent every designated kind.
-/
theorem a_composition_missing_a_kind_is_rejected :
    ({ subject := 0,
       kindOf := [(1, "base-reality"), (2, "surreality"), (3, "preality")],
       abstractMembers := [1, 2, 3],
       contained := [1, 2, 3],
       components := [1, 2, 3],
       declaredKinds := ["base-reality", "surreality", "preality", "areality"] } :
      SempiternalityView 4).wellShaped = false := by
  decide

-- L4DEL: title: A containment cycle is rejected
-- L4DEL: intuition: A whole that contains itself is not a finite recursive structure, so the acyclicity check must be able to fail.
/--
A structure whose containment relation loops back to its own start is
rejected.

This is the negative case for acyclicity, and it is the reason the frame
requires acyclic containment rather than merely well-formed endpoints.
-/
theorem a_containment_cycle_is_rejected :
    ({ nodes := [0, 1],
       contains := [(0, 1), (1, 0)],
       represents := [],
       connects := [] } : RecursiveStructure 2).wellShaped = false := by
  decide

-- L4DEL: title: A dangling relation endpoint is rejected
-- L4DEL: intuition: A relation to a node the structure does not have describes something that is not there.
/--
A structure whose relation names a node it does not have is rejected.

This is the second negative case, and it is independent of the acyclicity
check: a structure can be acyclic and still describe a node that is not
there.
-/
theorem a_dangling_endpoint_is_rejected :
    ({ nodes := [0, 1],
       contains := [(0, 1), (1, 2)],
       represents := [],
       connects := [] } : RecursiveStructure 3).wellShaped = false := by
  decide

/-!
## The ecosystem record
-/

-- L4DEL: title: Hyperstructure explainer entry
-- L4DEL: intuition: This declaration exposes the checked ecosystem record for Hyperstructure on its own stable explainer page.
-- L4DEL: see: Hyperfields.hyperstructure
/-- The canonical Hyperstructure record used by the unified portal. -/
def entry : Hyperfields.Entry := Hyperfields.hyperstructure

end Hyperfields.Fields.Hyperstructure
