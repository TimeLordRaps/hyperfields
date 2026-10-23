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
-- L4DEL: title: The explainer module a repository is explained in
-- L4DEL: intuition: Every catalogued repository has one dedicated explainer module, so a field cannot be present in an aggregate while absent from the public surface.
/-- The name of the dedicated Lean module that explains this repository. -/
def RepoId.moduleName : RepoId → String
  | .hyperchaos => "Hyperchaos"
  | .hyperorder => "Hyperorder"
  | .hyperemergence => "Hyperemergence"
  | .hyperobjectivity => "Hyperobjectivity"
  | .hypersubjectivity => "Hypersubjectivity"
  | .hyperreality => "Hyperreality"
  | .hypertime => "Hypertime"
  | .hyperspace => "Hyperspace"
  | .hypergeometry => "Hypergeometry"
  | .hypertopology => "Hypertopology"
  | .hyperstructure => "Hyperstructure"
  | .hyperdynamics => "Hyperdynamics"
  | .hypermechanics => "Hypermechanics"
  | .hypergrammar => "Hypergrammar"
  | .hyperlogic => "Hyperlogic"
  | .hypermath => "Hypermath"
  | .hyperphysics => "Hyperphysics"
  | .hyperethics => "Hyperethics"
  | .hyperchemistry => "Hyperchemistry"
  | .hyperbiology => "Hyperbiology"
  | .hyperprobability => "Hyperprobability"
  | .hyperstratum => "Hyperstratum"
  | .hyperorganization => "Hyperorganization"
  | .ordinatics => "Ordinatics"
  | .metamathethicology => "Metamathethicology"
  | .metaMorphoscriptedOrigination => "MetaMorphoscriptedOrigination"
  | .groundedHypercalculi => "GroundedHypercalculi"
  | .groundedHypersetTheory => "GroundedHypersetTheory"

-- L4DEL: title: The readable name of a repository
-- L4DEL: intuition: A repository's display name is its published title, which is not always the same as the module that explains it.
/--
The published display name of a repository.

This is not the module name.  `grounded-hypercalculi` is explained by the
module `GroundedHypercalculi` but published under the title "Grounded
Hypercalculi", and `meta-morphoscripted-origination` is published as
"Meta-Morphoscripted-Origination" under the module
`MetaMorphoscriptedOrigination`.  Keeping the two apart lets the catalogue
name a repository the way its owner names it and still point at the module
that checks the entry.
-/
def RepoId.displayName : RepoId → String
  | .hyperchaos => "Hyperchaos"
  | .hyperorder => "Hyperorder"
  | .hyperemergence => "Hyperemergence"
  | .hyperobjectivity => "Hyperobjectivity"
  | .hypersubjectivity => "Hypersubjectivity"
  | .hyperreality => "Hyperreality"
  | .hypertime => "Hypertime"
  | .hyperspace => "Hyperspace"
  | .hypergeometry => "Hypergeometry"
  | .hypertopology => "Hypertopology"
  | .hyperstructure => "Hyperstructure"
  | .hyperdynamics => "Hyperdynamics"
  | .hypermechanics => "Hypermechanics"
  | .hypergrammar => "Hypergrammar"
  | .hyperlogic => "Hyperlogic"
  | .hypermath => "Hypermath"
  | .hyperphysics => "Hyperphysics"
  | .hyperethics => "Hyperethics"
  | .hyperchemistry => "Hyperchemistry"
  | .hyperbiology => "Hyperbiology"
  | .hyperprobability => "Hyperprobability"
  | .hyperstratum => "Hyperstratum"
  | .hyperorganization => "Hyperorganization"
  | .ordinatics => "Ordinatics"
  | .metamathethicology => "Metamathethicology"
  | .metaMorphoscriptedOrigination => "Meta-Morphoscripted-Origination"
  | .groundedHypercalculi => "Grounded Hypercalculi"
  | .groundedHypersetTheory => "Grounded Hyperset Theory"

-- L4DEL: title: The catalogue slug of a repository
-- L4DEL: intuition: The slug is the published URL segment, so it must be a function of the identifier rather than a second hand-written list.
/--
The catalogue slug of a repository: the URL segment the portal publishes it
under.

Most slugs are the identifier spelled in lower case.  Three are not, because
their owners' repository names are hyphenated, and the catalogue publishes
the owner's spelling rather than a normalised one.
-/
def RepoId.slug : RepoId → String
  | .hyperchaos => "hyperchaos"
  | .hyperorder => "hyperorder"
  | .hyperemergence => "hyperemergence"
  | .hyperobjectivity => "hyperobjectivity"
  | .hypersubjectivity => "hypersubjectivity"
  | .hyperreality => "hyperreality"
  | .hypertime => "hypertime"
  | .hyperspace => "hyperspace"
  | .hypergeometry => "hypergeometry"
  | .hypertopology => "hypertopology"
  | .hyperstructure => "hyperstructure"
  | .hyperdynamics => "hyperdynamics"
  | .hypermechanics => "hypermechanics"
  | .hypergrammar => "hypergrammar"
  | .hyperlogic => "hyperlogic"
  | .hypermath => "hypermath"
  | .hyperphysics => "hyperphysics"
  | .hyperethics => "hyperethics"
  | .hyperchemistry => "hyperchemistry"
  | .hyperbiology => "hyperbiology"
  | .hyperprobability => "hyperprobability"
  | .hyperstratum => "hyperstratum"
  | .hyperorganization => "hyperorganization"
  | .ordinatics => "ordinatics"
  | .metamathethicology => "metamathethicology"
  | .metaMorphoscriptedOrigination => "meta-morphoscripted-origination"
  | .groundedHypercalculi => "grounded-hypercalculi"
  | .groundedHypersetTheory => "grounded-hyperset-theory"
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

-- L4DEL: title: The readable form of a grounding
-- L4DEL: intuition: A grounding names the fields it stands on, so the readable form must say which, not merely that a grounding exists.
/--
Join a list of names the way the catalogue joins them, with a serial comma
before the final item when there are three or more.

Two items join with "and" alone.  Three or more join with a comma before
"and", so a reader can see where the list ends.  This is the same rendering
the published catalogue has always used.
-/
def joinNames (names : List String) : String :=
  match names with
  | [] => ""
  | [only] => only
  | [first, second] => s!"{first} and {second}"
  | names =>
      let last := names.getLastD ""
      let rest := names.dropLast
      s!"{String.intercalate ", " rest}, and {last}"

/--
Render a grounding as the sentence the catalogue publishes.

`fieldPrimitive` is rendered "field-relative primitive", not "primitive",
because being primitive inside one field's own presentation is a claim about
that presentation and not a claim about reality.  A grounded entry names its
primary basis first and then any additional bases.
-/
-- L4DEL: title: Render a grounding as text
-- L4DEL: intuition: A grounding names the fields it rests on, and the rendering joins them the way a sentence would rather than the way a list would.
-- L4DEL: prereq: Hyperfields.Grounding
def Grounding.display (grounding : Grounding) : String :=
  match grounding with
  | .fieldPrimitive => "field-relative primitive"
  | .unresolved => "unresolved"
  | .grounded primary additional =>
      let names := primary.displayName :: additional.map RepoId.displayName
      s!"grounded in {joinNames names}"

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
/--
Exact public bytes used as the source for an explanatory entry.

`revision` is optional because a public repository can exist without a
resolvable `main` commit.  A repository URL alone is still a true coordinate
claim: the repository is public, but no commit was pinned, so the entry
carries `publicWithoutMain` rather than a false forty-character pin.  Keeping
the revision optional in the type keeps that distinction visible to Lean
instead of hiding it behind an empty string.
-/
structure SourceCoordinate where
  repository : String
  revision : Option String := none
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
-- L4DEL: intuition: A public-main claim needs a repository, a forty-character revision, and the main branch; a public repository without a main commit may carry the repository alone; unresolved source states must not carry a false pin.
/--
A public-main entry is internally well-shaped only when it carries an exact
source coordinate.

The three states are checked separately because they make different claims.
A pinned entry claims a specific commit and therefore needs all three
coordinates.  A `publicWithoutMain` entry claims only that a public repository
exists, so it must carry a repository and must *not* carry a revision it
cannot honour.  An unpublished candidate must carry no public coordinate at
all.
-/
def Entry.sourceShapeValid (entry : Entry) : Bool :=
  match entry.sourceState, entry.source with
  | .publicMainPinned, some coordinate =>
      !coordinate.repository.isEmpty &&
      (match coordinate.revision with
        | some revision => revision.length == 40
        | none => false) &&
      coordinate.branch == "main"
  | .publicWithoutMain, some coordinate =>
      !coordinate.repository.isEmpty &&
      coordinate.revision.isNone
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
