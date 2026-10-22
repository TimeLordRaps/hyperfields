import Hyperfields.Core

/-!
# Initial source-pinned ecosystem registry

Each public entry below points to the exact `main` commit inspected on 2026-10-13.
Candidate branches and dirty local worktrees are deliberately not promoted into this
registry.  Five field candidates have no public repository yet and are marked as such.

Every explanation begins as `sourceDerivedUnreviewed`.  Lean checks the structure of
the catalogue, but Tyler's review is the gate for changing an explanation to
`ownerReviewed`.
-/

namespace Hyperfields

-- L4DEL: title: Bind an entry to a public main revision
-- L4DEL: intuition: The repository URL and exact revision are constructed together.
def sourceOnMain (slug revision : String) : Option SourceCoordinate :=
  some {
    repository := s!"https://github.com/TimeLordRaps/{slug}"
    revision := revision
  }

-- L4DEL: title: Construct a source-pinned public entry
-- L4DEL: intuition: Every public-main entry begins with an exact coordinate and unreviewed explanatory status.
def mkPublicEntry
    (id : RepoId)
    (slug displayName : String)
    (role : EcosystemRole)
    (grounding : Grounding)
    (modes : List OperatingMode)
    (summary revision : String) : Entry :=
  {
    id := id
    slug := slug
    displayName := displayName
    role := role
    grounding := grounding
    modes := modes
    summary := summary
    sourceState := .publicMainPinned
    source := sourceOnMain slug revision
  }

-- L4DEL: title: Construct an unpublished field candidate
-- L4DEL: intuition: A local candidate is registered without inventing a public source coordinate or settled grounding.
def mkUnpublishedEntry
    (id : RepoId)
    (slug displayName summary : String)
    (modes : List OperatingMode) : Entry :=
  {
    id := id
    slug := slug
    displayName := displayName
    role := .hyperfield
    grounding := .unresolved
    modes := modes
    summary := summary
    sourceState := .localCandidateUnpublished
    source := none
  }

-- L4DEL: title: Hyperchaos
-- L4DEL: intuition: A deliberately unresolved field frame records uses of chaos without silently choosing a native meaning.
-- L4DEL: term: field frame = A typed place to record a proposed field while its native axioms remain unresolved.
-- L4DEL: source: Pinned repository = https://github.com/TimeLordRaps/hyperchaos/tree/cead99a681f46a5cdf6fba752af96fd59b3c70e8
def hyperchaos : Entry := mkPublicEntry .hyperchaos "hyperchaos" "Hyperchaos" .hyperfield
  .unresolved [.formative] "An intentionally unresolved frame for the native structure of chaos."
  "cead99a681f46a5cdf6fba752af96fd59b3c70e8"

-- L4DEL: title: Hyperorder
-- L4DEL: intuition: Hyperorder records finite ordering structure while treating an absent relation as unknown rather than false.
-- L4DEL: source: Pinned repository = https://github.com/TimeLordRaps/hyperorder/tree/3b9932ce80546b3c5ad1b4616a08d1b72a0b3a03
def hyperorder : Entry := mkPublicEntry .hyperorder "hyperorder" "Hyperorder" .hyperfield
  .fieldPrimitive [.formative, .communicative] "A finite partial-order frame with explicit unknown relations."
  "3b9932ce80546b3c5ad1b4616a08d1b72a0b3a03"

-- L4DEL: title: Hyperemergence
-- L4DEL: intuition: Hyperemergence asks whether coherent behavior persists across levels rather than merely appearing at one level.
-- L4DEL: source: Pinned repository = https://github.com/TimeLordRaps/hyperemergence/tree/a19d2927ce80bd82a2b68e66600a237b0f967e76
def hyperemergence : Entry := mkPublicEntry .hyperemergence "hyperemergence" "Hyperemergence" .hyperfield
  (.grounded .hyperstratum) [.formative, .integrative] "A candidate cross-level coherence frame whose positive native criterion remains open."
  "a19d2927ce80bd82a2b68e66600a237b0f967e76"

-- L4DEL: title: Hyperobjectivity
-- L4DEL: intuition: Hyperobjectivity studies what remains invariant across situated presentations.
-- L4DEL: source: Pinned repository = https://github.com/TimeLordRaps/hyperobjectivity/tree/ed75d14f5ce8b59b1b72983a58a207ea9fc73bfc
def hyperobjectivity : Entry := mkPublicEntry .hyperobjectivity "hyperobjectivity" "Hyperobjectivity" .hyperfield
  (.grounded .hyperreality) [.formative, .communicative] "Hyperobjects, hyperform instantiation, and invariance across situated reality presentations."
  "ed75d14f5ce8b59b1b72983a58a207ea9fc73bfc"

-- L4DEL: title: Hypersubjectivity
-- L4DEL: intuition: Hypersubjectivity makes the situated perspective part of the formal object instead of erasing it.
-- L4DEL: source: Pinned repository = https://github.com/TimeLordRaps/hypersubjectivity/tree/1f7f8a75daa569563d1fa607000a655beb21158c
def hypersubjectivity : Entry := mkPublicEntry .hypersubjectivity "hypersubjectivity" "Hypersubjectivity" .hyperfield
  (.grounded .hyperreality [.hyperobjectivity]) [.formative, .communicative] "Situated perspective, cross-reality linkage, and candidate novelty from hyperobjects."
  "1f7f8a75daa569563d1fa607000a655beb21158c"

-- L4DEL: title: Hyperreality
-- L4DEL: intuition: Hyperreality provides the repository's current taxonomy of reality presentations and their containment order.
-- L4DEL: source: Pinned repository = https://github.com/TimeLordRaps/hyperreality/tree/9e217aef1c39228bb1042c9ebc10b59cacefafc4
def hyperreality : Entry := mkPublicEntry .hyperreality "hyperreality" "Hyperreality" .hyperfield
  .fieldPrimitive [.formative, .integrative] "A taxonomy of what a reality is and which kinds of reality are presented."
  "9e217aef1c39228bb1042c9ebc10b59cacefafc4"

-- L4DEL: title: Hypertime
-- L4DEL: intuition: Hypertime records branching and order among reality presentations without assuming an outside clock.
-- L4DEL: source: Pinned repository = https://github.com/TimeLordRaps/hypertime/tree/cb980b5f2377013444e8b41f8ba0577271ba82cf
def hypertime : Entry := mkPublicEntry .hypertime "hypertime" "Hypertime" .hyperfield
  (.grounded .hyperreality) [.formative, .communicative] "The axis of branching among reality presentations, where order need not become an outside clock."
  "cb980b5f2377013444e8b41f8ba0577271ba82cf"

-- L4DEL: title: Hyperspace
-- L4DEL: intuition: Hyperspace records placement among observable realities without silently converting placement into passage.
-- L4DEL: source: Pinned repository = https://github.com/TimeLordRaps/hyperspace/tree/bfcf5e7d8d1ea6b30672c32285810178514d61d4
def hyperspace : Entry := mkPublicEntry .hyperspace "hyperspace" "Hyperspace" .hyperfield
  (.grounded .hyperreality) [.formative, .communicative] "The axis of placement among observable realities, preserving the source term hyperphere without fixing its geometry here."
  "bfcf5e7d8d1ea6b30672c32285810178514d61d4"

-- L4DEL: title: Hypergeometry
-- L4DEL: intuition: A finite local candidate records chart, metric, and transport structure without claiming a public source or native completion.
def hypergeometry : Entry := mkUnpublishedEntry .hypergeometry "hypergeometry" "Hypergeometry"
  "A local finite-frame candidate for charts, metrics, and exact path transport." [.formative]

-- L4DEL: title: Hypertopology
-- L4DEL: intuition: A finite local candidate records open, closure, boundary, and continuity structure without claiming a public source or native completion.
def hypertopology : Entry := mkUnpublishedEntry .hypertopology "hypertopology" "Hypertopology"
  "A local finite-frame candidate for opens, closure, boundary, and continuity." [.formative]

-- L4DEL: title: Hyperstructure
-- L4DEL: intuition: A finite local candidate separates abstract roles, containers, components, and exact presentation isomorphism.
def hyperstructure : Entry := mkUnpublishedEntry .hyperstructure "hyperstructure" "Hyperstructure"
  "A local finite-frame candidate for typed structures, components, and presentation isomorphism." [.formative, .integrative]

-- L4DEL: title: Hyperdynamics
-- L4DEL: intuition: A finite local candidate records transitions, path lifting, and coupled products without claiming native dynamics are complete.
def hyperdynamics : Entry := mkUnpublishedEntry .hyperdynamics "hyperdynamics" "Hyperdynamics"
  "A local finite-frame candidate for transitions, path lifting, and coupled products." [.formative, .compositional]

-- L4DEL: title: Hypermechanics
-- L4DEL: intuition: A finite local candidate records guarded rewrites, conservation, noninterference, and connection rules.
def hypermechanics : Entry := mkUnpublishedEntry .hypermechanics "hypermechanics" "Hypermechanics"
  "A local finite-frame candidate for guarded rewrites, conservation, and connection rules." [.formative, .compositional]

-- L4DEL: title: Hypergrammar
-- L4DEL: intuition: Hypergrammar is the communicative field for forming and relating expressions across the ecosystem.
-- L4DEL: source: Pinned repository = https://github.com/TimeLordRaps/hypergrammar/tree/045435a452d3380b6492c5619da8488865238e80
def hypergrammar : Entry := mkPublicEntry .hypergrammar "hypergrammar" "Hypergrammar" .hyperfield
  .fieldPrimitive [.formative, .communicative] "A source-defined grammatical layer whose current public description is: the solution."
  "045435a452d3380b6492c5619da8488865238e80"

-- L4DEL: title: Hyperlogic
-- L4DEL: intuition: Hyperlogic is presented as Hypermath's logic counterpart.
-- L4DEL: source: Pinned repository = https://github.com/TimeLordRaps/hyperlogic/tree/81987c0bf3fe850afcc8ff665ce3caf81e0e3b0b
def hyperlogic : Entry := mkPublicEntry .hyperlogic "hyperlogic" "Hyperlogic" .hyperfield
  (.grounded .hypermath) [.formative, .communicative] "Hypermath's logic counterpart."
  "81987c0bf3fe850afcc8ff665ce3caf81e0e3b0b"

-- L4DEL: title: Hypermath
-- L4DEL: intuition: Hypermath is the ecosystem's primitive mathematical kernel and Lean-facing bridge.
-- L4DEL: source: Pinned repository = https://github.com/TimeLordRaps/hypermath/tree/1db85b32286eeb882e2604c826669bc231029f90
def hypermath : Entry := mkPublicEntry .hypermath "hypermath" "Hypermath" .hyperfield
  .fieldPrimitive [.formative, .communicative] "A closed formal universe derived from one primitive operation, with a Lean translation and reproducible open-obligation audit."
  "1db85b32286eeb882e2604c826669bc231029f90"

-- L4DEL: title: Hyperphysics
-- L4DEL: intuition: Hyperphysics applies the hyperfield programme to physical law while keeping model evidence distinct from physical confirmation.
-- L4DEL: source: Pinned repository = https://github.com/TimeLordRaps/hyperphysics/tree/66a86b97a587445218bab8f7f7a3abe853797988
def hyperphysics : Entry := mkPublicEntry .hyperphysics "hyperphysics" "Hyperphysics" .hyperfield
  (.grounded .hypermath) [.formative, .compositional] "Hypermath's physics counterpart."
  "66a86b97a587445218bab8f7f7a3abe853797988"

-- L4DEL: title: Hyperethics
-- L4DEL: intuition: Hyperethics applies the hyperfield programme to moral and governance structure.
-- L4DEL: source: Pinned repository = https://github.com/TimeLordRaps/hyperethics/tree/51835e12a0674ab73cd6782d6f05697a47cdd933
def hyperethics : Entry := mkPublicEntry .hyperethics "hyperethics" "Hyperethics" .hyperfield
  (.grounded .hypermath) [.formative, .communicative] "Hypermath for morals."
  "51835e12a0674ab73cd6782d6f05697a47cdd933"

-- L4DEL: title: Hyperchemistry
-- L4DEL: intuition: Hyperchemistry models how operations compose inside Hyperphysics.
-- L4DEL: source: Pinned repository = https://github.com/TimeLordRaps/hyperchemistry/tree/9adb2663ed61b6910fd8ba22a40ec7c133c30821
def hyperchemistry : Entry := mkPublicEntry .hyperchemistry "hyperchemistry" "Hyperchemistry" .hyperfield
  (.grounded .hyperphysics) [.formative, .compositional] "The operation of operations within Hyperphysics, beginning with finite, refutable composition."
  "9adb2663ed61b6910fd8ba22a40ec7c133c30821"

-- L4DEL: title: Hyperbiology
-- L4DEL: intuition: Hyperbiology is registered without a public main coordinate, so its current public source remains unresolved here.
def hyperbiology : Entry := {
  id := .hyperbiology
  slug := "hyperbiology"
  displayName := "Hyperbiology"
  role := .hyperfield
  grounding := .unresolved
  modes := [.formative, .compositional]
  summary := "The study of the studies of how life interacts; no public main branch was available at inspection time."
  sourceState := .publicWithoutMain
  source := none
}

-- L4DEL: title: Hyperprobability
-- L4DEL: intuition: Hyperprobability isolates the field structure of bounded uncertainty and guaranteed outcomes.
-- L4DEL: source: Pinned repository = https://github.com/TimeLordRaps/hyperprobability/tree/c09bfbd9a3dc5e2563cc02c3d52250becfe607f7
def hyperprobability : Entry := mkPublicEntry .hyperprobability "hyperprobability" "Hyperprobability" .hyperfield
  .unresolved [.formative, .communicative] "A field candidate for probability, guarantees, and bounded uncertainty."
  "c09bfbd9a3dc5e2563cc02c3d52250becfe607f7"

-- L4DEL: title: Hyperstratum
-- L4DEL: intuition: Hyperstratum organizes form, frame, field, relation, graph, structure, and representation across levels.
-- L4DEL: source: Pinned repository = https://github.com/TimeLordRaps/hyperstratum/tree/d9eaf8089c495b5487c7267b67a5827ac6e2d31e
def hyperstratum : Entry := mkPublicEntry .hyperstratum "hyperstratum" "Hyperstratum" .structuralHub
  .unresolved [.integrative, .reflective] "A recursive ontology of form, frame, field, node, relation, graph, structure, and representation across base, meta, and whole-form levels."
  "d9eaf8089c495b5487c7267b67a5827ac6e2d31e"

-- L4DEL: title: Hyperorganization
-- L4DEL: intuition: Hyperorganization is registered as a structural hub pending an owner-reviewed account of its relation to the fields.
-- L4DEL: source: Pinned repository = https://github.com/TimeLordRaps/hyperorganization/tree/8e1a4ea6841703c0573425cd7ceeb35d658fa26f
def hyperorganization : Entry := mkPublicEntry .hyperorganization "hyperorganization" "Hyperorganization" .structuralHub
  .unresolved [.integrative, .reflective] "A newly public organizational layer whose exact ecosystem role requires owner review."
  "8e1a4ea6841703c0573425cd7ceeb35d658fa26f"

-- L4DEL: title: Ordinatics
-- L4DEL: intuition: Ordinatics supplies ordinal-first arithmetic and staged semantics rather than being silently relabelled as a hyperfield.
-- L4DEL: source: Pinned repository = https://github.com/TimeLordRaps/ordinatics/tree/ef2cd7af7c07520d614ee407bc7982110f66295a
def ordinatics : Entry := mkPublicEntry .ordinatics "ordinatics" "Ordinatics" .ordinalInfrastructure
  (.grounded .hypermath) [.formative, .compositional] "Ordinal arithmetic and an ordinal-first metalanguage for definable arithmetic truth."
  "ef2cd7af7c07520d614ee407bc7982110f66295a"

-- L4DEL: title: Metamathethicology
-- L4DEL: intuition: Metamathethicology combines meta-level accounts without transferring authority among them automatically.
-- L4DEL: source: Pinned repository = https://github.com/TimeLordRaps/metamathethicology/tree/272a3e58a8bc0fbdfc460549d4166c10c6a7feb4
def metamathethicology : Entry := mkPublicEntry .metamathethicology "metamathethicology" "Metamathethicology" .metaFramework
  (.grounded .hypermath [.hyperlogic, .hyperethics, .hyperphysics]) [.integrative, .reflective] "Metamath, metaphysics, metaethics, and metalogic in one meta-level framework."
  "272a3e58a8bc0fbdfc460549d4166c10c6a7feb4"

-- L4DEL: title: Meta-Morphoscripted-Origination
-- L4DEL: intuition: This framework studies how narratives of origination are formed and transformed under limited cognition.
-- L4DEL: source: Pinned repository = https://github.com/TimeLordRaps/meta-morphoscripted-origination/tree/b3445b65c6843ee30aaadff6c26cace21357f0dd
def metaMorphoscriptedOrigination : Entry := mkPublicEntry .metaMorphoscriptedOrigination
  "meta-morphoscripted-origination" "Meta-Morphoscripted-Origination" .metaFramework
  (.grounded .hypergrammar [.hyperreality]) [.communicative, .reflective]
  "A framework for discoverable anchors and morphisms among origination narratives under limited cognition."
  "b3445b65c6843ee30aaadff6c26cace21357f0dd"

-- L4DEL: title: Grounded Hypercalculi
-- L4DEL: intuition: The calculi are grounded because they operate over lower-level Hypermath and adjacent foundational concepts.
-- L4DEL: source: Pinned repository = https://github.com/TimeLordRaps/grounded-hypercalculi/tree/6eb5e0af1b7831fec887632d35814b78619cede3
def groundedHypercalculi : Entry := mkPublicEntry .groundedHypercalculi "grounded-hypercalculi"
  "Grounded Hypercalculi" .groundedLayer (.grounded .hypermath [.ordinatics, .groundedHypersetTheory])
  [.compositional, .communicative]
  "A derived execution and domain-calculus layer spanning language, meta, hyper, ordinal, real-analysis, and oracle calculi."
  "6eb5e0af1b7831fec887632d35814b78619cede3"

-- L4DEL: title: Grounded Hyperset Theory
-- L4DEL: intuition: The hyperset layer is grounded in lower-level mathematical structure while supplying APGs, AFA, and bisimulation machinery.
-- L4DEL: acronym: APG = accessible pointed graph
-- L4DEL: acronym: AFA = Anti-Foundation Axiom
-- L4DEL: source: Pinned repository = https://github.com/TimeLordRaps/grounded-hyperset-theory/tree/d7cb4372f65a8da2fe0817e6af7e975ce8f866b0
def groundedHypersetTheory : Entry := mkPublicEntry .groundedHypersetTheory "grounded-hyperset-theory"
  "Grounded Hyperset Theory" .groundedLayer (.grounded .hypermath [.ordinatics])
  [.formative, .compositional]
  "A derived reference implementation of non-well-founded set theory using APGs, bisimulation, and constructive membership under AFA."
  "d7cb4372f65a8da2fe0817e6af7e975ce8f866b0"

-- L4DEL: title: The complete initial catalogue
-- L4DEL: intuition: List order is presentation order only and carries no hidden hierarchy.
/-- The complete initial catalogue, with no inference from list order. -/
def registry : List Entry := [
  hyperchaos, hyperorder, hyperemergence, hyperobjectivity, hypersubjectivity,
  hyperreality, hypertime, hyperspace, hypergeometry, hypertopology,
  hyperstructure, hyperdynamics, hypermechanics, hypergrammar, hyperlogic,
  hypermath, hyperphysics, hyperethics, hyperchemistry, hyperbiology,
  hyperprobability, hyperstratum, hyperorganization, ordinatics,
  metamathethicology, metaMorphoscriptedOrigination, groundedHypercalculi,
  groundedHypersetTheory
]

-- L4DEL: title: Source-shape failures
-- L4DEL: intuition: Invalid source-state and coordinate combinations remain explicit instead of being dropped.
/-- All entries whose public-source shape is internally valid. -/
def sourceShapeFailures : List Entry := registry.filter (fun entry => !entry.sourceShapeValid)

-- L4DEL: title: Owner review queue
-- L4DEL: intuition: This list is the operative semantic review backlog for the initial catalogue.
/-- Every initial explanation still awaits Tyler's semantic review. -/
def ownerReviewQueue : List Entry := registry.filter Entry.awaitingOwnerReview

-- L4DEL: title: The initial registry has twenty-eight entries
-- L4DEL: intuition: The list is explicit, so Lean can reduce its length exactly.
-- L4DEL: step: Unfold the registry.
-- L4DEL: step: Compute the list length.
theorem registry_has_28_entries : registry.length = 28 := by
  decide

-- L4DEL: title: Every source coordinate has the expected shape
-- L4DEL: intuition: Public-main entries carry a nonempty repository URL, a forty-character revision, and the main branch; unpublished or no-main entries carry no false pin.
-- L4DEL: step: Unfold the registry and source-shape checker.
-- L4DEL: step: Compute every finite case.
theorem registry_sources_are_well_shaped : sourceShapeFailures = [] := by
  decide

-- L4DEL: title: No explanation is silently owner-reviewed
-- L4DEL: intuition: The initial catalogue remains visibly pending Tyler's review even though Lean checks its structure.
-- L4DEL: step: Filter the registry by its review state.
-- L4DEL: step: Verify that every entry remains in the review queue.
theorem initial_registry_awaits_owner_review : ownerReviewQueue.length = registry.length := by
  decide

end Hyperfields
