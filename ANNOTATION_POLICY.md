# Annotation and provenance policy

The repository uses the Lean4 Domain Explanation Language (L4DEL) implemented by
[`lean4-explainer`](https://github.com/TimeLordRaps/lean4-explainer).

Annotations live immediately above the Lean declaration they explain and may contain:

- `title`: the reader-facing name;
- `intuition`: a bounded explanation of what the declaration expresses;
- `step`: ordered proof or construction steps;
- `prereq` and `see`: links between Lean declarations;
- `term` and `acronym`: explicit glossary entries;
- `source`: an immutable HTTPS source, normally a full Git commit;
- `quote`: exact source language, distinguished from explanatory prose.

The repository keeps three kinds of authority separate:

1. **Lean authority** — the kernel checks the declarations and proofs in this repository.
2. **Source authority** — exact commit links establish what a source repository said at
   a coordinate; they do not establish that its claims are true.
3. **Explanation authority** — every initial catalogue entry is
   `sourceDerivedUnreviewed`. Only an identified owner review may change it to
   `ownerReviewed`.

The registry does not infer mathematics or science from repository names. Source text
may be condensed, but stronger interpretations remain unresolved until the owner or
the relevant formal evidence supplies them.

Generated pages must visibly preserve these distinctions. Candidate branches and local
dirty worktrees require their own pinned manifest before their content may replace a
public-main explanation.
