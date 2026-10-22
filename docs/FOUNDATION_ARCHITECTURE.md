# The foundation architecture

**Status:** USER_DECLARED_FRAMEWORK, recorded 2026-10-22.
**Authority:** Tyler Roost, by direct declaration. This document records what was
declared; it does not assert that the declarations are proved.

## What this document is for

Between 2026-10-21 and 2026-10-22 the ecosystem's architecture was stated
directly. This file is the durable record of that statement, so that the
decisions do not have to be re-derived from conversation, and so that the
tools which consume the architecture have something to consume.

Every claim in here is marked with its epistemic status. Where a declaration
names a proposition that is not yet proved, the document says so and names the
obligation. This is the same discipline the rest of the ecosystem uses: a
named proposition is not a proved proposition.

## The four semantic axes

The ecosystem's fields are organised by what they answer.

| Axis | Question | Fields |
|---|---|---|
| **WHAT** | What is the structure? | `hypermath` |
| **HOW** | How does it come to exist / compose? | `hyperlogic` |
| **WHY** | Why is it there — creation, will, consciousness, consent? | `hyperethics` |
| **WHERE + WHEN** | Where and when — placement, index, physical application? | `hyperphysics`, `hyperspace`, `hypertime` |

**The axes are not an exclusive partition.** A field may occupy several. The
four named fields are the *canonical instance* of each axis, not the only
member of it. `metamathethicology` is the proof that this reading is right: it
is explicitly a **combination field** (`will_electrophysics` is a combination
of `hyperethics` and `hyperphysics`, and `oreality` is a combination of
`hyperprobability` and the declared realities). The family already thinks in
composites, so the axes are a lattice.

## The two periods, and why they are additive

`hypermath` closes its fundamental orbit at **two** steps (`ax-box`: `□□x`
relates back to `x`). `hyperlogic` closes its circuit at **three** steps
(`ax-triangle`: shape → matter → reading → shape). The difference is
*checkable*, not declared: `two_turn_return` fails in a structure satisfying
all four of hyperlogic's axioms, so the two-step reading is refuted outright.

**They are additive, not combative.** Neither is more fundamental. The
reconciliation is to turn the pair around and look from the self-kernel side,
as though closure-self were already represented. From that side, the two
periods are two *presentations* of one self-kernel, and the question "which is
real?" does not arise.

### The two filtrations

`hypermath` carries a **branched** filtration, and the branch matters:

| Rung | Relation | Status in hypermath |
|---|---|---|
| 1 | `~~` similar | L0 relation, weakest, widest scope |
| 2 | `=~` congruent | L0 relation, "substance" |
| 3 | `~=` abstraction | **not an L0 relation** — it is a transitive abstraction *layer* over the others |
| 4 | `==` simulation | L0 relation, strongest, narrowest scope, hardest to earn |

The filtration is a chain by strength, but it is *branched* because rung 3 is
an operation on rungs 1–2 rather than a peer of them. `QuadrilateralFiltration.lean`
already carries `AbstractedFrom`, `abstractedRefl`, `abstractedSymm`,
`abstractedTrans`, and `abstractedNotCongruentAtCycle`.

`hyperlogic` carries a **triangular** filtration: shape, matter, reading, with
`closure` as the irreducible where all three coincide.

`hyperlogic` records that this is *"the same three-plus-one shape as hypermath
Section III and hyperethics Section III"*, while flagging that same shape is
not same content (`GC-2`, `nd-shape-is-not-content`).

### The abstraction branch is the link

The abstraction deduction — going backwards against abstraction, readingding
information that was left out and removing information that was added — is a
*cycle off the filtration back onto the filtration*. That is the same shape as
`hyperlogic`'s circuit.

This is the load-bearing observation of this document: **the abstraction branch
of hypermath's branched filtration is the mechanism by which hyperlogic's
circuit and hypermath's cycle compose.**

## The self-kernel, and the pair that underpins everything

`hypermath` is the **what**: the self-kernel, `□` as ground, closure act, and
fixed point.

`hyperlogic` is the **how**: how the self-kernel can come into existence or
exist at all; what it means for it to exist; its function in compositionality.

**`hyperlogic` underpins the self-kernel in `hypermath`.** The two together
underpin everything else.

The relationship is **citation without import**, and it must stay that way.
`hyperlogic/DESIGN.md` and `nd-import-hypermath` set out the four-step
argument: hypermath's L0 Sections I–VII are written in a metalanguage
(`derive`, `close`, `axiom`, `discharge`, `graduation`); hypermath's own
Section VIII states that those words "appear constantly but were never defined
as formal L0 objects"; so the metalanguage is needed *by hypermath in order to
state hypermath*; therefore importing hypermath into hyperlogic would run
`hyperlogic → hypermath → hyperlogic`.

A foundation that needs another package in order to state its own ground is
not a foundation. So: `hyperlogic` **cites** `hypermath` by file, section, and
line, and imports nothing from it.

### The dependency direction

```
hyperlogic  ──cites──▶  hypermath
                              │
                              ▼
                    (everything else, by composition)
```

`hypermath` must not import from anything other than `hyperlogic` to resolve
the self-kernel. This is a constraint on *resolution*, not on the import
graph: `hypermath` currently requires `Ordinatics` for the transfinite
declarations, and that requirement stays because it is structural rather than
explanatory.

## Compositionality, and its consequences

The compositionality operation is `compose` on `DerivationPath`, already
declared in `hypermath/L2Operations.lean`:

```
axiom pathGround : DerivationPath              -- identity element
axiom compose : DerivationPath → DerivationPath → DerivationPath
axiom axComposeAssoc : ...                      -- associativity
axiom axComposeIdentity : ...                   -- identity
```

`compose` is sequential composition, governed by associativity and identity,
with `pathGround` as the unit. `NC-3` in that file's own words: *"compose is
well-defined with pathGround identity (axComposeAssoc + axComposeIdentity).
FORM."* That is a monoid, and it is already declared FORM.

**The consequence of compositionality is self-representation.** All internal
representations within the self-kernel that are compositional are yielded into
a **subspace / subuniverse**, such that the compositional subuniverse can be
completely represented — Gödelianly complete — because the external self-kernel
is itself definable and self-representational.

### Where this lives

**Compositional subuniverses go inside hypermath L4.** `hypermath` currently has
no L4; its Lean modules stop at `L3Ordinatics.lean`. L4 is where the
compositional subuniverse, the reflection operation, and the `derivable-in`
relation live.

**The congruency of paths of meaning and the congruency of forms of matter
compose.** `hypermath`'s `congruentPath` and `hyperlogic`'s `congruent` are
the same notion under different names, and composition allows a thing to
represent itself and its own components abstractly, as its own subuniverse
within the greater rules — and those greater rules themselves form a
composition, with its greater consequences.

## The two moves out of the grounded packages

### 1. Reflection moves into the self-kernel in `hypermath`

The reflection operation currently in `grounded-hypercalculi` is
`QuotationNode.self_quoting` — a reflexive quotation node `t = Quote(t)`, a
reflexive non-well-founded quotation graph under AFA.

- The **Language Calculus bits stay** in `grounded-hypercalculi`: grammars,
  production rules, the RPN proof checker, `MetamathDatabase`.
- The **reflection bits move** and become *grounded* in `hypermath`'s
  reflection and other forms.

### 2. `derivable-in` moves into `hypermath`

`derivable-in` is currently in `metamathethicology` as `Domain.METALOGIC`,
emitted by `reflect()`. It is one of the three independent statements of the
derivation relation that `hyperlogic` was extracted from.

**`metamathethicology` should only represent combination fields.** Metalogic
is a *subcomponent* of it, the way `will_electrophysics` is a combination of
`will` (from `hyperethics`) and electrical law (from `hyperphysics`) — and
`oreality` is a combination of `hyperprobability` and the declared realities.

## The derivation order

The order in which fields become available. This is an *availability* order
(what can be built on what), not an authority order.

| Stage | Fields | Basis |
|---|---|---|
| 0 | `hypermath`, `hyperlogic` | the self-kernel and its how; compose with each other |
| 1 | `hypertopology`, `hypergeometry` | via compositionality |
| 2 | `hyperorder`, `hyperchaos`, `hyperemergence` | also via compositionality |
| 3 | `hypertime`, `hyperspace`, `hyperdynamics`, `hypermechanics`, `hyperreality` | appear next after `hypergeometry` and `hypertopology` |
| 4 | `hyperphysics`, `hyperethics` | from those |
| 5 | `hyperobjectivity`, `hypersubjectivity` | `hyperethics` allows these |
| 6 | `hypergrammar`, `hyperorganization` | from all of those |
| 7 | `hyperchemistry`, `hyperbiology` | then these |
| 8 | `grounded-hypercalculi`, `grounded-hyperset-theory` | grounded in all the hyperfields; they allow closure |

**`grounded-hypercalculi` then presents a foundational set of calculi to
operationalize into novel forms of math** — about changes of hyperreality,
mechanics, and dynamics, as well as language, and other calculi such as a
**will calculus** and an **imagination calculus**.

## The two paired relations

| Pair | Relation |
|---|---|
| `hypergeometry` : `hyperspace` :: `hypertopology` : `hypertime` | geometry is the metamathematical structure that can *form* geometries; hyperspace is the *dimensionality* of structures. Both are "shape-ish", and the analogy carries across the pair. |
| `hypermath` + `hyperlogic` | the what and the how; together they make everything else |

## `hyperprobability`

**A foundational representation of the constraints that are actually
representative of residual dynamics present in our simulated existence, and
objectively definable.**

If probability is the frequency likelihood of an event, then **`hyperprobability`
is the ordinal representation of the infinite base-realities that count to form
the hyperset of base-realities** where that event is said to have occurred
guaranteedly — as the base-realities exist hyperdimensionally in a singular
object, such as a Bloch universe.

This is a *definition proposal* at the level of the user's declared framework.
It has not been formalized. It is recorded here so that later work on
`hyperprobability` has the intended target, and so the obligation is visible.

## Open obligations carried by this document

| ID | Obligation | Status |
|---|---|---|
| ARCH-01 | Close `hypermath`'s seven executive opaques — either internally or with `hyperlogic`. `hyperlogic` records this as **GC-4**, "not attempted here". | OPEN |
| ARCH-02 | Establish the *additivity* of the 2/4 filtration and the 3/3 circuit as a proposition, not an assertion. The abstraction branch is the proposed mechanism. | OPEN |
| ARCH-03 | State the compositional subuniverse in `hypermath` L4: closure under `compose`, contains `ground`, and every member is a derivation of `ground` (the Gödelian self-representation property). | OPEN |
| ARCH-04 | Move reflection out of `grounded-hypercalculi` and ground it in `hypermath`'s reflection. | OPEN |
| ARCH-05 | Move `derivable-in` out of `metamathethicology` into `hypermath`; reduce `metamathethicology` to combination fields. | OPEN |
| ARCH-06 | Give `hyperlogic` a declaration that the closure *comes to exist*, not merely that it returns after one turn. `ax-closure-self` is deliberately minimal and does not claim production. | OPEN |
| ARCH-07 | Formalize the `hyperprobability` definition as a proposition over the hyperset of base-realities. | OPEN |

## What this document does not do

It does not claim that any of the above is proved. It records a declared
architecture, names the obligations it creates, and marks them OPEN. The
ecosystem's own rule is unchanged: a named proposition is not a proved
proposition, and a declaration is not a derivation.
