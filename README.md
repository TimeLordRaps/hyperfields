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
- that a public repository without a resolvable `main` commit carries the repository
  alone and never an invented pin;
- that no initial explanation is silently represented as owner-reviewed;
- that each of the three declared cross-field bridges is well-shaped, targets a
  non-`FORM` endpoint, and remains `OPEN`;
- the finite structure and stated properties of the five unpublished field
  candidates and of Hyperorganization's phase, protection, and authority results.

Lean does **not** thereby prove that an individual repository's science, metaphysics,
physical interpretation, or external validation is correct. Those are separate proof
obligations.

## One source of truth

The Lean registry is the catalogue. `ecosystem.json` and `src/hyperfields/bridges.json`
are *rendered from it*, not maintained alongside it:

```bash
lake build
python scripts/check_manifest.py            # gate: committed records match Lean
python scripts/check_manifest.py --write    # regenerate the committed records
```

The gate compares the committed files to the Lean renderings field for field and
entry for entry. A mismatch fails; it is never silently rewritten. This matters
because a hand-maintained manifest can disagree with the registry it claims to
describe, and the disagreement is invisible until someone checks.

The Python package reads those same rendered records. It does not restate them.
An earlier draft of `hyperfields.registry` carried its own role, mode, summary, and
display-name tables, and they had already drifted from the Lean registry before
they were removed.

## The Python package

`hyperfields` is installable and typed:

```bash
python -m pip install -e ".[test]"
python -m pytest
```

It exposes three surfaces:

| Module | What it holds |
|---|---|
| `hyperfields.registry` | the 28 ecosystem entries, loaded from the Lean-rendered manifest |
| `hyperfields.bridges` | the three declared cross-field bridges, with their `OPEN` status preserved |
| `hyperfields.candidates` | the five unpublished candidates and the Lean module that checks each |

The loader is strict. A missing, unreadable, or inconsistent manifest raises
`ManifestError` rather than falling back to a default, because a registry that
silently drops an entry is worse than one that refuses to load.

## The field ports

The five unpublished candidates each have a Python reference implementation and now
a Lean port that checks the same finite structure. Each port is marked `[FRAME]`
and carries the same classification as its Python source: a finite consistency
result is not a foundation.

| Candidate | Lean module | What it checks |
|---|---|---|
| Hypertopology | `Hyperfields/Fields/Hypertopology.lean` | opens closed under union and intersection; closure, interior, boundary, continuity |
| Hypergeometry | `Hyperfields/Fields/Hypergeometry.lean` | metric separation, symmetry, triangle inequality over exact rationals; chart isometries and path transport |
| Hyperstructure | `Hyperfields/Fields/Hyperstructure.lean` | kind assignment over a required kind set; acyclic containment; component binding |
| Hyperdynamics | `Hyperfields/Fields/Hyperdynamics.lean` | step endpoints, per-state kind assignment, reachability, path lifting |
| Hypermechanics | `Hyperfields/Fields/Hypermechanics.lean` | guarded rewrites under an exact conservation invariant; rule independence |

`Hyperfields/Fields/Hyperorganization.lean` additionally ports Hyperorganization's
ordinal phase computation, the weakest-link protection function, and authority
height.

`scripts/check_candidate_ports.py` runs every port against its Python source of
truth and fails on any disagreement. That check is what makes the ports evidence
rather than assertions: it was what caught two wrong theorems in the first
Hypertopology port, which had claimed a closure and a boundary that the Python
source does not produce.

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
- [`Hyperfields/Bridges.lean`](Hyperfields/Bridges.lean) declares the three cross-field
  bridges and the refusals that keep them declarations.
- [`Hyperfields/Finite.lean`](Hyperfields/Finite.lean) and
  [`Hyperfields/Exact.lean`](Hyperfields/Exact.lean) carry the shared finite-set and
  exact-rational machinery the field ports use.
- [`Hyperfields/Manifest.lean`](Hyperfields/Manifest.lean) renders the published JSON
  records from the registry.
- [`Hyperfields/AllFields.lean`](Hyperfields/AllFields.lean) imports every dedicated
  first-class field module.
- [`ecosystem.json`](ecosystem.json) is the portal manifest, rendered from the registry.
- [`src/hyperfields/`](src/hyperfields) is the typed Python package.
- [`ANNOTATION_POLICY.md`](ANNOTATION_POLICY.md) records how explanations and sources
  are kept distinct.

## The bridges

Hyperstratum's integration registry declares three cross-field bridges. They are
recorded here as typed Lean structures, and their `OPEN` status is part of the
record rather than an inference, so a reader can see at a glance that no
correspondence has been established.

Three refusals are preserved exactly, because losing any of them would turn a
declaration into a claim:

1. a bridge whose target is classified `FORM` cannot be certified here;
2. a bridge cannot self-certify — its status is `OPEN` or `UNKNOWN` and nothing
   promotes it;
3. a bridge needs explicit content — every mapping carries a meaning, and the
   preserves, excludes, and obligations lists are nonempty.

## Build

The explainer catalogue is pinned to Lean `v4.35.0`, matching the currently validated
`lean4-explainer` pipeline. Hypermath and Ordinatics are pinned to the same
version, so their theorem imports need no compatibility bridge: a cross-repo
`require` is now a versioned dependency like any other.

```bash
lake build
python -m pip install -e ".[test]"
python -m pytest
python scripts/check_manifest.py
python scripts/check_candidate_ports.py
```

The explanatory source uses Lean4 Domain Explanation Language (`L4DEL`) comments. With
a checkout of [`lean4-explainer`](https://github.com/TimeLordRaps/lean4-explainer):

```bash
lean4-explainer check --lean-root .
lean4-explainer build --lean-root . --out site
```

The repository's Pages workflow pins the explainer implementation, checks every L4DEL
annotation, verifies that the committed JSON records still match the Lean
declarations, runs the Python test suite, requires every rendered declaration to be
positively kernel-checked with no `sorry`, extra axioms, or `UNKNOWN` trust result,
binds source links to the exact repository revision being deployed, and fails if any
one of the 28 cards, hosted pages, checked modules, source pins, or manifest records
is absent or inconsistent.

## Current boundary

This version pins public `main` commits inspected on 2026-10-13. It does not
promote candidate branches, dirty worktrees, dated test receipts, or generated prose
into stronger claims. Cross-repository theorem imports and scientific validation are
future gates, not implied by the catalogue compiling.

The five candidate ports are finite consistency results over chosen finite models.
They do not establish that those models are the intended ones, and they assert nothing
physical or metaphysical. The three bridges remain declarations.

Licensed under Apache-2.0.
