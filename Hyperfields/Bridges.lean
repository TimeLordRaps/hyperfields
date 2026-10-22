import Std

/-!
# Cross-field integration bridges, as typed declarations

Hyperstratum's ``integration-registry.json`` declares three bridges between
fields. Each one is a *declaration of intent*, not a proven correspondence,
and each carries an explicit ``OPEN`` status.

This module encodes those declarations in Lean. The point is not to prove
any of them. The point is to make the declarations *typed*, so that the
properties hyperstratum's own checker enforces are properties of the data
rather than properties of a Python function that has to be run.

Three refusals are preserved exactly, because losing any of them would turn
a declaration into a claim:

1. **A bridge whose target is classified ``FORM`` cannot be certified here.**
   A declaration checker does not certify a native closed account; that
   needs an independent derivation elsewhere.
2. **A bridge cannot self-certify.** Its status is ``OPEN`` or ``UNKNOWN``
   and nothing here promotes it to a closed state.
3. **A bridge needs explicit content.** Every mapping carries a meaning,
   and the preserves, excludes, and obligations lists are nonempty.

The third refusal is the one that keeps the declarations honest. A bridge
with an empty "preserves" list would look like a correspondence and carry
none of the content that makes it meaningful.
-/

namespace Hyperfields.Bridges

/-!
## The vocabulary

The classification names are fixed. `openClass` is the only identifier that
does not match its published string, because `open` is a Lean keyword; the
string it renders to is still `OPEN`.
-/

-- L4DEL: title: The declared status of a bridge
-- L4DEL: intuition: A bridge is either still open or its own declaration is unsettled; neither is a closed correspondence.
/--
The declared status of a bridge.

There is deliberately no member for a certified bridge. A correspondence
that has been proved does not become one by a status change in a
declaration; it needs an independent derivation.
-/
inductive BridgeStatus where
  | declaredOpen
  | unknown
  deriving Repr, BEq, DecidableEq

-- L4DEL: title: The role a bridge claims to play
-- L4DEL: intuition: A bridge must state its role, because "these two fields correspond" and "these two fields are used together" are different claims.
/-- The role a bridge claims to play. -/
inductive BridgeRelation where
  | interpretation
  | transport
  | application
  | representation
  deriving Repr, BEq, DecidableEq

-- L4DEL: title: The classification of a bridge endpoint
-- L4DEL: intuition: A native closed account, a declared incomplete account, an unsettled account, and a multi-level candidate are four different things.
/--
The classification of a bridge endpoint.

`openClass` renders to the published string `OPEN`; the identifier differs
only because `open` is a Lean keyword.
-/
inductive FieldClass where
  | form
  | frame
  | openClass
  | hyper
  deriving Repr, BEq, DecidableEq

-- L4DEL: title: One named correspondence
-- L4DEL: intuition: A mapping between two concepts must carry the meaning it is meant to preserve, or it is an uninterpreted pair of names.
/--
One named correspondence between a source concept and a target concept.

The `meaning` field is not commentary. It is the part that says what the
correspondence does and does not license.
-/
structure Mapping where
  source : String
  target : String
  meaning : String
  deriving Repr, BEq, DecidableEq

-- L4DEL: title: One declared cross-field correspondence
-- L4DEL: intuition: A bridge is a declaration with explicit endpoints, an explicit status, and explicit content; none of it is inferred.
/--
One declared cross-field correspondence.

The status is part of the record rather than an inference, so a reader can
see at a glance that no correspondence has been established.
-/
structure Bridge where
  source : String
  target : String
  relation : BridgeRelation
  sourceClass : FieldClass
  targetClass : FieldClass
  status : BridgeStatus
  mappings : List Mapping
  preserves : List String
  excludes : List String
  obligations : List String
  deriving Repr, BEq, DecidableEq

/-!
## The refusals, as properties of the data
-/

-- L4DEL: title: A declaration checker cannot certify a native target
-- L4DEL: intuition: A `FORM` endpoint is a closed native account, and a declaration has no standing to certify one.
/--
Whether a bridge is well-shaped as a *declaration*.

A bridge is well-shaped when it has two distinct endpoints, a target that
is not a native `FORM` account, at least one mapping with a nonempty
meaning, and nonempty preserves, excludes, and obligations lists.

This is the conjunction of hyperstratum's three refusals, expressed as one
predicate on the record so it can be checked by `decide` over the finite
bridge list.
-/
def Bridge.wellShaped (bridge : Bridge) : Bool :=
  bridge.source != bridge.target &&
  bridge.targetClass != .form &&
  !bridge.mappings.isEmpty &&
  !bridge.preserves.isEmpty &&
  !bridge.excludes.isEmpty &&
  !bridge.obligations.isEmpty &&
  (bridge.mappings.all fun mapping =>
    !mapping.source.isEmpty && !mapping.target.isEmpty && !mapping.meaning.isEmpty)

-- L4DEL: title: A bridge is still an open declaration
-- L4DEL: intuition: A declaration cannot certify itself, so every bridge keeps an explicit status and none of them is closed.
/--
Whether a bridge is still an open declaration.

A bridge that was `UNKNOWN` is unsettled; a bridge that is `OPEN` is
declared but not established. Neither is a correspondence that has been
proved.
-/
def Bridge.isOpen (bridge : Bridge) : Bool :=
  bridge.status == .declaredOpen

/-!
## The three declared bridges

These are the declarations hyperstratum's integration registry carries. The
text is reproduced verbatim so that a reader can compare the Lean record
with the JSON record without translating.
-/

-- L4DEL: title: The declared bridges
-- L4DEL: intuition: Each bridge names what it maps, what it preserves, what it refuses, and what it still owes.
/--
The three declared cross-field bridges.

Every one of them is `OPEN`, and every one of them has a `FRAME` target, so
no declaration here is a claim of a closed correspondence.
-/
def declaredBridges : List Bridge := [
  {
    source := "hyperethics"
    target := "hyperstructure"
    relation := .interpretation
    sourceClass := .frame
    targetClass := .frame
    status := .declaredOpen
    mappings := [
      {
        source := "RealityKind.base-reality"
        target := "layer.reality"
        meaning := "User-facing layer-name alignment only; neither Reality equals Realm nor situated slice equals universal base is inferred."
      }
    ]
    preserves := [
      "four designated kinds are pairwise distinct",
      "the kind taxonomy remains open",
      "areality is not ranked below base-reality"
    ]
    excludes := [
      "a Reality to Realm map",
      "equating sempiternality with eternity",
      "deriving composition from kind distinction alone"
    ]
    obligations := [
      "The sempiternality composition is a new user-declared extension, not a theorem of the existing consciousness layer."
    ]
  },
  {
    source := "hypermechanics"
    target := "hyperdynamics"
    relation := .application
    sourceClass := .frame
    targetClass := .frame
    status := .declaredOpen
    mappings := [
      {
        source := "admissible operation application"
        target := "labelled transition"
        meaning := "A checked operation can supply one transition; a trajectory also requires explicit state and index semantics."
      },
      {
        source := "independent(left, right)"
        target := "commuting labelled transitions"
        meaning := "Hypermechanics' disjoint-footprint criterion is a sufficient condition for two enabled rewrites to commute. It is not a claim that every pair of transitions in a Hyperdynamics trajectory commutes, and it says nothing about associativity of a trajectory's composition."
      },
      {
        source := "rule application order"
        target := "trajectory composition order"
        meaning := "Reordering two independent rules leaves the configuration unchanged, so the two orders reach the same state. That is commutativity of a pair, not associativity of a sequence: associativity is a property of how three or more steps group, and no Hypermechanics clause states it."
      }
    ]
    preserves := [
      "state identity",
      "declared invariants",
      "operation preconditions",
      "the disjoint-footprint criterion as the stated sufficient condition",
      "state identity across a reordered pair"
    ]
    excludes := [
      "global physical time",
      "automatic reversibility",
      "guaranteed reachable states",
      "commutativity as a universal law of rule application",
      "associativity derived from commutativity",
      "physical simultaneity from a commuting pair"
    ]
    obligations := [
      "Replay each transition against its mechanism and declared state encoding.",
      "State the associativity claim separately: commutativity of a pair does not entail associativity of a sequence, and no clause in either field currently asserts the latter.",
      "Show that the disjoint-footprint criterion is sufficient for the specific transition encoding a Hyperdynamics trajectory uses, rather than for the rewrite relation alone."
    ]
  },
  {
    source := "hyperdynamics"
    target := "hyperphysics"
    relation := .application
    sourceClass := .frame
    targetClass := .frame
    status := .declaredOpen
    mappings := [
      {
        source := "local transition index"
        target := "physical observation coordinate"
        meaning := "Only an explicit dimensional and measurement bridge can give a transition index a physical interpretation."
      }
    ]
    preserves := [
      "declared trajectory constraints",
      "open validity obligations"
    ]
    excludes := [
      "seconds inherited from a step number",
      "physical correctness from graph reachability"
    ]
    obligations := [
      "Supply observables, units, sources and sinks, and refutable applicability bounds."
    ]
  }
]

/-!
## The checks

These are the finite checks the Lean side makes. They are all `decide`
proofs over the three declared bridges, so the compiler is the witness.

The recursion depth is raised because the declarations carry long prose
strings, and `decide` unfolds the string comparisons one character at a
time.
-/
set_option maxRecDepth 4096 in
section

/-- Every declared bridge clears the declaration contract. -/
theorem declared_bridges_are_well_shaped :
    declaredBridges.filter (fun bridge => !bridge.wellShaped) = [] := by
  decide

end

-- L4DEL: title: No declared bridge targets a native closed account
-- L4DEL: intuition: A declaration has no standing to certify a `FORM` account, so none of the three may have one as a target.
/-- No declared bridge has a `FORM` target. -/
theorem no_declared_bridge_targets_form :
    declaredBridges.filter (fun bridge => bridge.targetClass == .form) = [] := by
  decide

-- L4DEL: title: No declared bridge is closed
-- L4DEL: intuition: A correspondence that has been proved needs an independent derivation, not a status change in a declaration.
/--
No declared bridge is a closed correspondence.

The `BridgeStatus` type has no closed member, and every declared bridge
carries the `OPEN` status, so this is a statement about the data and about
the vocabulary together.
-/
theorem no_declared_bridge_is_closed :
    declaredBridges.filter (fun bridge => !bridge.isOpen) = [] := by
  decide

-- L4DEL: title: There are three declared bridges
-- L4DEL: intuition: The list is explicit, so Lean can reduce its length exactly.
/-- The integration registry declares exactly three bridges. -/
theorem there_are_three_declared_bridges : declaredBridges.length = 3 := by
  decide

-- L4DEL: title: The declared bridges join distinct fields
-- L4DEL: intuition: A bridge needs two fields, so no declared bridge may begin and end at the same field.
/-- No declared bridge joins a field to itself. -/
theorem declared_bridges_join_distinct_fields :
    declaredBridges.filter (fun bridge => bridge.source == bridge.target) = [] := by
  decide

-- L4DEL: title: Every declared bridge names an open obligation
-- L4DEL: intuition: A bridge that owes nothing has not said what it is waiting for, so each one carries at least one outstanding obligation.
/-- Every declared bridge carries at least one outstanding obligation. -/
theorem every_bridge_carries_an_obligation :
    declaredBridges.all (fun bridge => !bridge.obligations.isEmpty) = true := by
  decide

/-!
## Rendering

The Python side reads the bridges from this module rather than from a second
copy of hyperstratum's registry, so the Lean record and the Python record
cannot disagree about a status or a mapping.
-/

-- L4DEL: title: The published string of a bridge status
-- L4DEL: intuition: The published vocabulary is fixed, so each status renders to exactly one string.
/-- The published string of a bridge status. -/
def BridgeStatus.string : BridgeStatus → String
  | .declaredOpen => "OPEN"
  | .unknown => "UNKNOWN"

-- L4DEL: title: The published string of a bridge relation
-- L4DEL: intuition: The published vocabulary is fixed, so each relation renders to exactly one string.
/-- The published string of a bridge relation. -/
def BridgeRelation.string : BridgeRelation → String
  | .interpretation => "interpretation"
  | .transport => "transport"
  | .application => "application"
  | .representation => "representation"

-- L4DEL: title: The published string of a field classification
-- L4DEL: intuition: The published vocabulary is fixed, so each classification renders to exactly one string.
/-- The published string of a field classification. -/
def FieldClass.string : FieldClass → String
  | .form => "FORM"
  | .frame => "FRAME"
  | .openClass => "OPEN"
  | .hyper => "HYPER"

-- L4DEL: title: Render one bridge as a JSON object
-- L4DEL: intuition: A consumer must be able to see the status, the content, and the obligations without reconstructing them.
/--
Render one bridge as a JSON object.

The status is published as data, never inferred. A consumer that reads this
file cannot mistake a declared bridge for a proved correspondence.
-/
def Bridge.render (bridge : Bridge) : String :=
  let quote (value : String) : String :=
    "\"" ++ value ++ "\""
  let quoteAll (values : List String) : String :=
    "[" ++ String.intercalate ", " (values.map quote) ++ "]"
  let renderMapping (mapping : Mapping) : String :=
    let mappingFields : List (String × String) := [
      ("source", quote mapping.source),
      ("target", quote mapping.target),
      ("meaning", quote mapping.meaning)
    ]
    "{" ++ String.intercalate ", "
      (mappingFields.map (fun (key, value) => quote key ++ ": " ++ value)) ++ "}"
  let fields : List (String × String) := [
    ("source", quote bridge.source),
    ("target", quote bridge.target),
    ("relation", quote bridge.relation.string),
    ("source_class", quote bridge.sourceClass.string),
    ("target_class", quote bridge.targetClass.string),
    ("status", quote bridge.status.string),
    ("mappings", "[" ++ String.intercalate ", "
      (bridge.mappings.map renderMapping) ++ "]"),
    ("preserves", quoteAll bridge.preserves),
    ("excludes", quoteAll bridge.excludes),
    ("obligations", quoteAll bridge.obligations)
  ]
  "{" ++ String.intercalate ", "
    (fields.map (fun (key, value) => quote key ++ ": " ++ value)) ++ "}"

-- L4DEL: title: Render the whole bridge record
-- L4DEL: intuition: The bridge record is a single document, so a consumer reads it in one place rather than assembling it from parts.
/-- Render the whole bridge record. -/
def renderBridges : String :=
  "{\n  \"schema\": \"hyperstratum-integration-0.1\",\n  \"classification\": \"FRAME\",\n  \"bridges\": [\n"
  ++ String.intercalate ",\n" (declaredBridges.map (fun bridge => "    " ++ bridge.render))
  ++ "\n  ]\n}"

end Hyperfields.Bridges
