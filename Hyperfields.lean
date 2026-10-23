import Hyperfields.Core
import Hyperfields.Registry
import Hyperfields.AllFields
import Hyperfields.Bridges
import Hyperfields.Manifest

/-!
# Hyperfields

This root module exposes the typed ecosystem vocabulary, source-pinned registry,
and every first-class ecosystem explainer section. Building it checks the
catalogue's internal shape and that every section elaborates; it does not
silently promote the scientific or metaphysical claims made by the repositories
that the catalogue describes.

`Hyperfields.Bridges` and `Hyperfields.Manifest` are imported here as well as
being reachable through the `hyperfields-manifest` executable. The reason is
that `lake build` builds `defaultTargets`, which is the library, and an
executable's root module is not part of it: `Hyperfields/Manifest.olean` was
therefore never produced by a plain build. The explainer's Lean probe asks the
kernel about every declaration, and a module with no object file answers
"Lean has no constant by this name" for all twelve of its declarations. The
site gate refuses that, correctly, so the two modules are imported here and the
object files exist after any build.
-/
