# Hyperfields

[![Lean explainer and Pages](https://github.com/TimeLordRaps/hyperfields/actions/workflows/pages.yml/badge.svg)](https://github.com/TimeLordRaps/hyperfields/actions/workflows/pages.yml)

**Proofsite:** <https://timelordraps.github.io/hyperfields/>

`hyperfields` is the public, Lean 4–checked explainer and map of the TimeLordRaps
hyperfield ecosystem.

A **hyperfield** is treated here as a field that exposes a formative foundation:
primitive vocabulary, formation rules, invariants, and open obligations intended to
state the field's irreducible structure. “Primitive” is field-relative in this first
version. It is not a claim that the structure has already been proved metaphysically
absolute.

Some hyperfields operate **communicatively**—they form or translate expressions and
relations—but communicative operation does not make them non-foundational. Conversely,
some repositories are **grounded layers**: they expose real structure while explicitly
depending on lower-level Hypermath or other field concepts.

## What Lean checks

Lean currently checks:

- the separation between ecosystem role, grounding, operating mode, source state, and
  explanation-review state;
- that a grounded entry names at least one upstream repository;
- that all 28 initial catalogue entries are present;
- that public-main records carry a nonempty repository URL, the `main` branch, and an
  exact 40-character revision;
- that no initial explanation is silently represented as owner-reviewed.

Lean does **not** thereby prove that an individual repository's science, metaphysics,
physical interpretation, or external validation is correct. Those are separate proof
obligations.

## Ecosystem layers

| Layer | Initial contents |
|---|---|
| Hyperfields | Hyperchaos, Hyperorder, Hyperemergence, Hyperobjectivity, Hypersubjectivity, Hyperreality, Hypertime, Hyperspace, Hypergeometry, Hypertopology, Hyperstructure, Hyperdynamics, Hypermechanics, Hypergrammar, Hyperlogic, Hypermath, Hyperphysics, Hyperethics, Hyperchemistry, Hyperbiology, Hyperprobability |
| Grounded layers | Grounded Hypercalculi, Grounded Hyperset Theory |
| Structural hubs | Hyperstratum, Hyperorganization |
| Ordinal infrastructure | Ordinatics |
| Meta-frameworks | Metamathethicology, Meta-Morphoscripted-Origination |

The layer assignment is an explanatory starting point, not an authority transfer from
one repository to another. Every entry begins as `sourceDerivedUnreviewed` pending
Tyler's semantic review.

Five hyperfield candidates—Hypergeometry, Hypertopology, Hyperstructure,
Hyperdynamics, and Hypermechanics—currently have no public repository coordinate and
are marked `localCandidateUnpublished`. Hyperbiology is public but had no public
`main` ref when this catalogue was inspected.

## Read the Lean

- [`Hyperfields/Core.lean`](Hyperfields/Core.lean) defines the ecosystem vocabulary.
- [`Hyperfields/Registry.lean`](Hyperfields/Registry.lean) contains the source-pinned
  catalogue and its finite consistency theorems.
- [`ANNOTATION_POLICY.md`](ANNOTATION_POLICY.md) records how explanations and sources
  are kept distinct.

## Build

The explainer catalogue is pinned to Lean `v4.34.1`, matching the currently validated
`lean4-explainer` pipeline. Hypermath and Ordinatics currently use Lean `v4.14.0`, so
their future theorem imports require an explicit compatibility bridge rather than an
implicit mixed-toolchain claim.

```bash
lake build
```

The explanatory source uses Lean4 Domain Explanation Language (`L4DEL`) comments. With
a checkout of [`lean4-explainer`](https://github.com/TimeLordRaps/lean4-explainer):

```bash
lean4-explainer check --lean-root .
lean4-explainer build --lean-root . --out site
```

The repository's Pages workflow pins the explainer implementation, checks every L4DEL
annotation, requires every rendered declaration to be positively kernel-checked with
no `sorry`, extra axioms, or `UNKNOWN` trust result, and binds source links to the exact
repository revision being deployed.

## Current boundary

This initial version pins public `main` commits inspected on 2026-10-13. It does not
promote candidate branches, dirty worktrees, dated test receipts, or generated prose
into stronger claims. Cross-repository theorem imports and scientific validation are
future gates, not implied by the catalogue compiling.

Licensed under Apache-2.0.
