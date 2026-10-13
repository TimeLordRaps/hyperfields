import Std

/-!
# A typed vocabulary for the hyperfield ecosystem

The types in this module keep four questions separate:

1. What kind of ecosystem artifact is this?
2. Is its presentation field-primitive, grounded in another field, or unresolved?
3. How does it operate: formatively, communicatively, compositionally, integratively,
   or reflectively?
4. How far has this catalogue entry itself been reviewed?

Compiling the vocabulary checks those distinctions.  It does not prove that a
repository has found physically or metaphysically absolute axioms.
-/

namespace Hyperfields

-- L4DEL: title: Stable ecosystem identifiers
-- L4DEL: intuition: A closed identifier type prevents dependencies from being recorded as misspelled free text.
/-- Stable identifiers for repositories and unpublished field candidates known to this catalogue. -/
inductive RepoId where
  | hyperchaos
  | hyperorder
  | hyperemergence
  | hyperobjectivity
  | hypersubjectivity
  | hyperreality
  | hypertime
  | hyperspace
  | hypergeometry
  | hypertopology
  | hyperstructure
  | hyperdynamics
  | hypermechanics
  | hypergrammar
  | hyperlogic
  | hypermath
  | hyperphysics
  | hyperethics
  | hyperchemistry
  | hyperbiology
  | hyperprobability
  | hyperstratum
  | hyperorganization
  | ordinatics
  | metamathethicology
  | metaMorphoscriptedOrigination
  | groundedHypercalculi
  | groundedHypersetTheory
  deriving Repr, BEq, DecidableEq

-- L4DEL: title: Ecosystem roles
-- L4DEL: intuition: A repository's role in the map is independent of whether the structure it presents is grounded in another field.
/-- A repository's role is distinct from whether its internal account is grounded. -/
inductive EcosystemRole where
  | hyperfield
  | groundedLayer
  | structuralHub
  | ordinalInfrastructure
  | metaFramework
  deriving Repr, BEq, DecidableEq

-- L4DEL: title: Relative grounding
-- L4DEL: intuition: A field may be primitive in its own presentation, explicitly grounded in named upstream structure, or still unresolved.
/--
Grounding is relative to the presentation recorded here.  `fieldPrimitive` means
"presented as primitive inside this field", not "proved absolutely primitive in reality".
-/
inductive Grounding where
  | fieldPrimitive
  | grounded (primary : RepoId) (additional : List RepoId := [])
  | unresolved
  deriving Repr, BEq, DecidableEq

-- L4DEL: title: Operating modes
-- L4DEL: intuition: A field can expose formative structure while also communicating, composing, integrating, or reflecting across fields.
/-- Multiple modes may describe one field; communicative and formative are not opposites. -/
inductive OperatingMode where
  | formative
  | communicative
  | compositional
  | integrative
  | reflective
  deriving Repr, BEq, DecidableEq

-- L4DEL: title: Public source state
-- L4DEL: intuition: A pinned main commit, a repository without a main ref, and an unpublished local candidate require different evidence claims.
/-- What public source coordinate is available for an entry. -/
inductive SourceState where
  | publicMainPinned
  | publicWithoutMain
  | localCandidateUnpublished
  deriving Repr, BEq, DecidableEq

-- L4DEL: title: Explanation review state
-- L4DEL: intuition: Compiling generated or source-derived prose cannot silently convert it into Tyler-reviewed prose.
/-- Review state of the explanatory text in this repository, not of the source project. -/
inductive ReviewState where
  | sourceDerivedUnreviewed
  | ownerReviewed
  deriving Repr, BEq, DecidableEq

-- L4DEL: title: Exact source coordinate
-- L4DEL: intuition: Repository, revision, and branch travel together so an explanation can be bound to source bytes.
/-- Exact public bytes used as the source for an explanatory entry. -/
structure SourceCoordinate where
  repository : String
  revision : String
  branch : String := "main"
  deriving Repr, BEq, DecidableEq

-- L4DEL: title: One hyperfield ecosystem entry
-- L4DEL: intuition: Identity, role, grounding, operating modes, prose, source evidence, and review state remain separately visible.
/--
One ecosystem entry.  `summary` is explanatory prose; its `review` field prevents
that prose from being confused with a kernel-checked theorem.
-/
structure Entry where
  id : RepoId
  slug : String
  displayName : String
  role : EcosystemRole
  grounding : Grounding
  modes : List OperatingMode
  summary : String
  sourceState : SourceState
  source : Option SourceCoordinate
  review : ReviewState := .sourceDerivedUnreviewed
  deriving Repr, BEq, DecidableEq

-- L4DEL: title: Validate the shape of a source claim
-- L4DEL: intuition: A public-main claim needs a repository, a forty-character revision, and the main branch; unresolved source states must not carry a false pin.
/-- A public-main entry is internally well-shaped only when it carries an exact source coordinate. -/
def Entry.sourceShapeValid (entry : Entry) : Bool :=
  match entry.sourceState, entry.source with
  | .publicMainPinned, some coordinate =>
      !coordinate.repository.isEmpty &&
      coordinate.revision.length == 40 &&
      coordinate.branch == "main"
  | .publicWithoutMain, none => true
  | .localCandidateUnpublished, none => true
  | _, _ => false

-- L4DEL: title: Identify explanations awaiting owner review
-- L4DEL: intuition: Structural compilation and semantic review are separate gates.
/-- No entry may claim owner review merely because this Lean catalogue compiles. -/
def Entry.awaitingOwnerReview (entry : Entry) : Bool :=
  entry.review == .sourceDerivedUnreviewed

-- L4DEL: title: A grounded entry names an upstream basis
-- L4DEL: intuition: Grounding is carried by the constructor, so a grounded record cannot omit its primary dependency.
-- L4DEL: step: Inspect the grounded constructor.
-- L4DEL: step: Return its required primary repository identifier.
theorem grounded_has_primary (primary : RepoId) (additional : List RepoId) :
    ∃ basis, Grounding.grounded primary additional = Grounding.grounded basis additional := by
  exact ⟨primary, rfl⟩

end Hyperfields
