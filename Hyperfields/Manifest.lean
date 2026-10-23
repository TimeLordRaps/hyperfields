import Std
import Hyperfields.Core
import Hyperfields.Registry
import Hyperfields.Bridges

/-!
# The ecosystem manifest, emitted from the Lean registry

`ecosystem.json` used to be a hand-maintained file that had to be kept in
step with `Hyperfields.Registry` by hand, and the release gate could only
check that the two agreed on the entries that the gate happened to look at.
This module removes the duplication: the Lean registry IS the record, and
this module renders it.

Running

```
lake env lean --run Hyperfields.Manifest > ecosystem.json
```

writes the manifest the portal consumes. The Python side reads the same
file, so there is one record of the ecosystem and one place it can be wrong.

The emitted JSON is deliberately plain: one object per entry, with the same
field names the portal already used. The renderer is total, so every entry in
the registry appears in the output, and the release gate's one-to-one
correspondence check now holds by construction rather than by review.
-/

namespace Hyperfields.Manifest

open Hyperfields

-- L4DEL: title: Escape a string as a JSON string literal
-- L4DEL: intuition: A summary may contain quotes and backslashes, so the renderer must escape them rather than emit invalid JSON.
/--
Escape a string as a JSON string literal, including the quotes.

Only the characters JSON actually requires to be escaped are escaped.  A
summary that contained a raw control character would produce invalid JSON,
so the five structural escapes are handled and everything else is emitted
verbatim.
-/
def jsonString (value : String) : String :=
  let body := value.foldl (fun acc character =>
    if character == '"' then acc ++ "\\\"" else
    if character == '\\' then acc ++ "\\\\" else
    if character == '\n' then acc ++ "\\n" else
    if character == '\r' then acc ++ "\\r" else
    if character == '\t' then acc ++ "\\t" else
    acc ++ character.toString) ""
  "\"" ++ body ++ "\""

-- L4DEL: title: Render a role as the manifest's role string
-- L4DEL: intuition: The manifest's vocabulary is fixed and public, so each role maps to exactly one published string.
/-- Render a role as the manifest's role string. -/
def roleString : EcosystemRole → String
  | .hyperfield => "hyperfield"
  | .groundedLayer => "grounded-layer"
  | .structuralHub => "structural-hub"
  | .ordinalInfrastructure => "ordinal-infrastructure"
  | .metaFramework => "meta-framework"

-- L4DEL: title: Render a grounding as the manifest's grounding string
-- L4DEL: intuition: The manifest publishes the same readable grounding the catalogue states, so the renderer delegates to the one place that decides it.
/-- Render a grounding as the manifest's grounding string. -/
def groundingString (grounding : Grounding) : String :=
  grounding.display

-- L4DEL: title: Render one operating mode as the manifest's mode string
-- L4DEL: intuition: The manifest's vocabulary is fixed and public, so each mode maps to exactly one published string.
/-- Render one operating mode as the manifest's mode string. -/
def modeString : OperatingMode → String
  | .formative => "formative"
  | .communicative => "communicative"
  | .compositional => "compositional"
  | .integrative => "integrative"
  | .reflective => "reflective"

-- L4DEL: title: Render a source state as the manifest's source-state string
-- L4DEL: intuition: The manifest's vocabulary is fixed and public, so each source state maps to exactly one published string.
/-- Render a source state as the manifest's source-state string. -/
def sourceStateString : SourceState → String
  | .publicMainPinned => "public-main-pinned"
  | .publicWithoutMain => "public-without-main"
  | .localCandidateUnpublished => "local-candidate-unpublished"

-- L4DEL: title: Render a review state as the manifest's review-state string
-- L4DEL: intuition: The manifest's vocabulary is fixed and public, so each review state maps to exactly one published string.
/-- Render a review state as the manifest's review-state string. -/
def reviewString : ReviewState → String
  | .sourceDerivedUnreviewed => "source-derived-unreviewed"
  | .ownerReviewed => "owner-reviewed"

-- L4DEL: title: Render the kind of a grounding as a closed tag
-- L4DEL: intuition: A consumer must be able to tell the three grounding kinds apart without parsing prose, so the kind is published as its own closed value.
/-- Render the kind of a grounding as a closed tag. -/
def groundingKindString : Grounding → String
  | .fieldPrimitive => "field-primitive"
  | .grounded _ _ => "grounded"
  | .unresolved => "unresolved"

-- L4DEL: title: Render the bases a grounded entry stands on
-- L4DEL: intuition: A grounded entry names its upstream fields as data, so a consumer can reason about the dependency without parsing the prose form.
/-- Render the bases a grounded entry stands on, primary first. -/
def groundingBases (grounding : Grounding) : List String :=
  match grounding with
  | .grounded primary additional => primary.displayName :: additional.map RepoId.displayName
  | _ => []

-- L4DEL: title: Render one entry as a JSON object
-- L4DEL: intuition: Every entry publishes the same thirteen fields, so a field cannot appear for one repository and be missing for another.
/--
Render one entry as a JSON object.

The field set is fixed.  A coordinate that does not exist is published as
`null` rather than omitted, so a consumer can tell "there is no repository"
apart from "this manifest does not say".

The grounding is published twice on purpose.  `grounding` is the prose the
portal prints, and `groundingKind` plus `groundingBases` are the structured
form.  A consumer that wants to branch on the kind of grounding must not
have to parse the prose, and a consumer that wants to print the prose must
not have to reconstruct the list-joining rules.
-/
def renderEntry (entry : Entry) : String :=
  let fields : List (String × String) := [
    ("slug", jsonString entry.slug),
    ("displayName", jsonString entry.displayName),
    ("module", jsonString entry.id.moduleName),
    ("role", jsonString (roleString entry.role)),
    ("grounding", jsonString (groundingString entry.grounding)),
    ("groundingKind", jsonString (groundingKindString entry.grounding)),
    ("groundingBases", "[" ++ String.intercalate ", "
      ((groundingBases entry.grounding).map (fun name => jsonString name)) ++ "]"),
    ("modes", "[" ++ String.intercalate ", " (entry.modes.map (fun mode => jsonString (modeString mode))) ++ "]"),
    ("summary", jsonString entry.summary),
    ("sourceState", jsonString (sourceStateString entry.sourceState)),
    ("reviewState", jsonString (reviewString entry.review)),
    ("repository", match entry.source with
      | some coordinate => jsonString coordinate.repository
      | none => "null"),
    ("revision", match entry.source with
      | some coordinate => match coordinate.revision with
        | some revision => jsonString revision
        | none => "null"
      | none => "null")
  ]
  "{" ++ String.intercalate ", " (fields.map (fun (key, value) => jsonString key ++ ": " ++ value)) ++ "}"

-- L4DEL: title: Render the whole manifest
-- L4DEL: intuition: The manifest carries the portal revision it was built for, so a published copy can be bound to the commit that produced it.
/-- Render the whole manifest. -/
def render (entries : List Entry) (portalRevision : String) : String :=
  "{\n" ++
  "  \"schemaVersion\": 1,\n" ++
  "  \"portalRevision\": " ++ jsonString portalRevision ++ ",\n" ++
  "  \"reviewState\": \"source-derived-unreviewed\",\n" ++
  "  \"entries\": [\n" ++
  String.intercalate ",\n" (entries.map (fun entry => "    " ++ renderEntry entry)) ++
  "\n  ]\n}"

-- L4DEL: title: Every entry the registry holds
-- L4DEL: intuition: The manifest renders the registry's own list, so a second copy here could disagree about which entries exist and in what order.
/--
Every entry the registry holds, in the order the portal lists them.

This is the registry's own list, not a second list.  A hand-maintained copy
here could disagree with `Hyperfields.registry` about which entries exist and
in what order, and the disagreement would only show up as a portal that
publishes a different sequence than the one Lean checks.
-/
def allEntries : List Entry := Hyperfields.registry

end Hyperfields.Manifest

/-!
# Emitting the manifest

`lake env lean --run Hyperfields.Manifest` prints the manifest to standard
output. The portal revision is taken from the `PORTAL_REVISION` environment
variable when it is set, so a release build binds the manifest to the commit
it was generated from.

`lake env lean --run Hyperfields.Manifest --bridges` prints the bridge
record instead. The bridge record is emitted from `Hyperfields.Bridges`, so
the Python side reads the same declarations Lean checks.
-/
-- L4DEL: title: The manifest emitter
-- L4DEL: intuition: The emitter renders the Lean registry as JSON, so the published record is a build product rather than a second copy of the declarations.
-- L4DEL: prereq: Hyperfields.Manifest.render
def main (args : List String) : IO Unit := do
  if args.contains "--bridges" then
    IO.println Hyperfields.Bridges.renderBridges
  else
    let revision ← IO.getEnv "PORTAL_REVISION"
    let revision := match revision with
      | some value => value
      | none => "unbound"
    IO.println (Hyperfields.Manifest.render Hyperfields.Manifest.allEntries revision)

