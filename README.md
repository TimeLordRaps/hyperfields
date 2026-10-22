# Hyperfields

[![Lean explainer and Pages](https://github.com/TimeLordRaps/hyperfields/actions/workflows/pages.yml/badge.svg)](https://github.com/TimeLordRaps/hyperfields/actions/workflows/pages.yml)

**Proofsite:** <https://timelordraps.github.io/hyperfields/>

`hyperfields` is the public, Lean 4–checked explainer and unified portal for the
TimeLordRaps hyperfield ecosystem. It hosts one first-class explainer section for
every registered public repository and every explicitly marked unpublished field
candidate—not merely one registry page about them.

The portal currently exposes **28 sections**: **23 public repositories** and **5
unpublished candidates**. Every landing-page card opens a dedicated field page,
which in turn links to that field's checked Lean entry and exact public source
coordinate when one exists.

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

## What “hosted together” means

The Pages release is an atlas, following the multi-corpus shape used by
`lean4-explainer`:

- the landing page exposes every repository or candidate as a visible card;
- `fields/<slug>/` is the stable hosted explainer page for that field;
- `Hyperfields/Fields/<Name>.lean.html` is its dedicated Lean-rendered page;
- `ecosystem.json` is the machine-readable public manifest;
- public sources are linked at exact commits rather than copied and silently
  detached from their provenance.

Most ecosystem repositories currently contain prose or executable reference
implementations rather than Lean source, so they are hosted as source-pinned
explainer sections rather than misrepresented as Lean corpora. Hypermath is the
exception: its public repository contains Lean sources. Importing that external
corpus into this portal is now a question of a versioned dependency rather than
of a toolchain bridge: the whole ecosystem, this catalogue included, is pinned
to Lean `v4.35.0`.

## Read the Lean

- [`Hyperfields/Core.lean`](Hyperfields/Core.lean) defines the ecosystem vocabulary.
- [`Hyperfields/Registry.lean`](Hyperfields/Registry.lean) contains the source-pinned
  catalogue and its finite consistency theorems.
- [`Hyperfields/AllFields.lean`](Hyperfields/AllFields.lean) imports every dedicated
  first-class field module.
- [`ecosystem.json`](ecosystem.json) is the portal manifest used by the release gate.
- [`ANNOTATION_POLICY.md`](ANNOTATION_POLICY.md) records how explanations and sources
  are kept distinct.

## Build

The explainer catalogue is pinned to Lean `v4.35.0`, matching the currently validated
`lean4-explainer` pipeline. Hypermath and Ordinatics are pinned to the same
version, so their theorem imports need no compatibility bridge: a cross-repo
`require` is now a versioned dependency like any other.

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
no `sorry`, extra axioms, or `UNKNOWN` trust result, binds source links to the exact
repository revision being deployed, and fails if any one of the 28 cards, hosted
pages, checked modules, source pins, or manifest records is absent or inconsistent.

## Current boundary

This initial version pins public `main` commits inspected on 2026-10-13. It does not
promote candidate branches, dirty worktrees, dated test receipts, or generated prose
into stronger claims. Cross-repository theorem imports and scientific validation are
future gates, not implied by the catalogue compiling.

Licensed under Apache-2.0.
