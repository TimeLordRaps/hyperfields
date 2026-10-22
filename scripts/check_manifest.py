#!/usr/bin/env python3
"""Check that the committed JSON records are exactly what Lean renders.

``ecosystem.json`` used to be hand-maintained and could drift from
``Hyperfields.Registry`` without anything failing. The Lean registry is now the
single source of truth and this module renders it, so the committed manifest is
a build product rather than a second copy of the record.

``src/hyperfields/bridges.json`` had the same problem in a worse form: it was
a copy of hyperstratum's integration registry, and the Python side read it
while the Lean side declared the same three bridges separately. The Lean
``Hyperfields.Bridges`` module now declares them, and the bridge record is
rendered from there.

This gate emits both records from Lean and compares them to the committed
files field for field, entry for entry. A mismatch is a failure, never a
silent rewrite: the committed records are what the portal published, so
changing them is a reviewable act, not a side effect of running a checker.

Usage
-----
::

    python scripts/check_manifest.py
    python scripts/check_manifest.py --write   # regenerate both JSON files

The ``--write`` mode is the only way the committed records change, and it
refuses to run if the Lean build is not clean.
"""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
from pathlib import Path
from typing import Any

REPO_ROOT = Path(__file__).resolve().parent.parent
MANIFEST_PATH = REPO_ROOT / "ecosystem.json"
BRIDGES_PATH = REPO_ROOT / "src" / "hyperfields" / "bridges.json"
LAKEFILE = REPO_ROOT / "lakefile.toml"

#: Fields the renderer emits, in the order the renderer emits them.
EXPECTED_FIELDS: tuple[str, ...] = (
    "slug",
    "displayName",
    "module",
    "role",
    "grounding",
    "groundingKind",
    "groundingBases",
    "modes",
    "summary",
    "sourceState",
    "reviewState",
    "repository",
    "revision",
)


def emit_manifest(root: Path, *extra_args: str) -> str:
    """Render a JSON record by running the Lean emitter.

    Returns the rendered JSON text exactly as the emitter produced it.

    Parameters
    ----------
    root
        The repository root.
    extra_args
        Extra arguments passed to the emitter. ``--bridges`` selects the
        bridge record instead of the ecosystem manifest.

    Raises
    ------
    RuntimeError
        If the Lean build or the emitter fails. The gate never continues on a
        failed build, because a stale or partial manifest is not evidence.
    """
    build = subprocess.run(
        ["lake", "build", "hyperfields-manifest"],
        cwd=root,
        capture_output=True,
        text=True,
        check=False,
    )
    if build.returncode != 0:
        raise RuntimeError(
            "lake build hyperfields-manifest failed:\n"
            + build.stdout
            + build.stderr
        )
    run = subprocess.run(
        ["lake", "exe", "hyperfields-manifest", *extra_args],
        cwd=root,
        capture_output=True,
        text=True,
        check=False,
    )
    if run.returncode != 0:
        raise RuntimeError(
            "lake exe hyperfields-manifest failed:\n" + run.stdout + run.stderr
        )
    return run.stdout


def normalise(entries: list[dict[str, Any]]) -> list[dict[str, Any]]:
    """Return the entries in a shape two renderings can be compared on.

    Key order is discarded because JSON objects are unordered, but every other
    field is compared verbatim. Unknown fields are preserved rather than
    dropped so that a renderer that grows a field is visible in the diff.
    """
    normalised: list[dict[str, Any]] = []
    for entry in entries:
        normalised.append({key: entry[key] for key in sorted(entry)})
    return normalised


def compare(committed: dict[str, Any], rendered: dict[str, Any]) -> list[str]:
    """Return every disagreement between the committed and rendered manifests.

    The comparison is field for field and entry for entry. Differences in
    ordering are reported separately from differences in content, because a
    reordering is a change to the published portal order and deserves its own
    line in the report.
    """
    errors: list[str] = []

    if committed.get("schemaVersion") != rendered.get("schemaVersion"):
        errors.append(
            "schemaVersion differs: "
            f"committed={committed.get('schemaVersion')!r} "
            f"rendered={rendered.get('schemaVersion')!r}"
        )
    if committed.get("reviewState") != rendered.get("reviewState"):
        errors.append(
            "top-level reviewState differs: "
            f"committed={committed.get('reviewState')!r} "
            f"rendered={rendered.get('reviewState')!r}"
        )

    committed_entries = committed.get("entries")
    rendered_entries = rendered.get("entries")
    if not isinstance(committed_entries, list) or not isinstance(rendered_entries, list):
        errors.append("both manifests must carry an 'entries' list")
        return errors

    committed_by_slug = {entry.get("slug"): entry for entry in committed_entries}
    rendered_by_slug = {entry.get("slug"): entry for entry in rendered_entries}

    missing = sorted(set(committed_by_slug) - set(rendered_by_slug))
    extra = sorted(set(rendered_by_slug) - set(committed_by_slug))
    for slug in missing:
        errors.append(f"committed entry {slug!r} is absent from the Lean registry")
    for slug in extra:
        errors.append(f"Lean registry entry {slug!r} is absent from the committed manifest")

    for slug in sorted(set(committed_by_slug) & set(rendered_by_slug)):
        left = committed_by_slug[slug]
        right = rendered_by_slug[slug]
        if set(left) != set(right):
            errors.append(
                f"entry {slug!r} has different fields: "
                f"committed-only={sorted(set(left) - set(right))} "
                f"rendered-only={sorted(set(right) - set(left))}"
            )
        for field in sorted(set(left) & set(right)):
            if left[field] != right[field]:
                errors.append(
                    f"entry {slug!r} field {field!r} differs: "
                    f"committed={left[field]!r} rendered={right[field]!r}"
                )

    committed_order = [entry.get("slug") for entry in committed_entries]
    rendered_order = [entry.get("slug") for entry in rendered_entries]
    if committed_order != rendered_order:
        errors.append(
            "entry order differs: the committed manifest publishes a different "
            "portal order than the Lean registry renders"
        )

    return errors


def compare_bridges(committed: dict[str, Any], rendered: dict[str, Any]) -> list[str]:
    """Return every disagreement between the committed and rendered bridge records.

    The comparison is field for field and bridge for bridge, and it also
    checks the two properties that matter most: every bridge must still be
    ``OPEN``, and no bridge may have a ``FORM`` target. A bridge that had
    silently become closed, or that had acquired a native target, would be a
    claim the declarations do not support.
    """
    errors: list[str] = []

    if committed.get("schema") != rendered.get("schema"):
        errors.append(
            f"bridge schema differs: committed={committed.get('schema')!r} "
            f"rendered={rendered.get('schema')!r}"
        )
    if committed.get("classification") != rendered.get("classification"):
        errors.append(
            f"bridge classification differs: committed={committed.get('classification')!r} "
            f"rendered={rendered.get('classification')!r}"
        )

    committed_bridges = committed.get("bridges")
    rendered_bridges = rendered.get("bridges")
    if not isinstance(committed_bridges, list) or not isinstance(rendered_bridges, list):
        errors.append("both bridge records must carry a 'bridges' list")
        return errors

    committed_by_key = {
        (bridge.get("source"), bridge.get("target")): bridge for bridge in committed_bridges
    }
    rendered_by_key = {
        (bridge.get("source"), bridge.get("target")): bridge for bridge in rendered_bridges
    }

    missing = sorted(set(committed_by_key) - set(rendered_by_key))
    extra = sorted(set(rendered_by_key) - set(committed_by_key))
    for key in missing:
        errors.append(f"committed bridge {key} is absent from the Lean declarations")
    for key in extra:
        errors.append(f"Lean bridge {key} is absent from the committed record")

    for key in sorted(set(committed_by_key) & set(rendered_by_key)):
        left = committed_by_key[key]
        right = rendered_by_key[key]
        if set(left) != set(right):
            errors.append(
                f"bridge {key} has different fields: "
                f"committed-only={sorted(set(left) - set(right))} "
                f"rendered-only={sorted(set(right) - set(left))}"
            )
        for field in sorted(set(left) & set(right)):
            if left[field] != right[field]:
                errors.append(
                    f"bridge {key} field {field!r} differs: "
                    f"committed={left[field]!r} rendered={right[field]!r}"
                )

    for bridge in committed_bridges:
        key = (bridge.get("source"), bridge.get("target"))
        if bridge.get("status") != "OPEN":
            errors.append(f"bridge {key} is not OPEN: {bridge.get('status')!r}")
        if bridge.get("target_class") == "FORM":
            errors.append(f"bridge {key} claims a FORM target, which a declaration cannot")

    return errors


def check(root: Path) -> list[str]:
    """Return every way the committed records fail to match the Lean declarations."""
    errors: list[str] = []

    if not MANIFEST_PATH.exists():
        return [f"{MANIFEST_PATH.name} is missing"]
    if not BRIDGES_PATH.exists():
        return [f"{BRIDGES_PATH.name} is missing"]

    try:
        committed = json.loads(MANIFEST_PATH.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        return [f"{MANIFEST_PATH.name} is unreadable: {exc}"]

    try:
        committed_bridges = json.loads(BRIDGES_PATH.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        return [f"{BRIDGES_PATH.name} is unreadable: {exc}"]

    if not LAKEFILE.exists():
        errors.append("lakefile.toml is missing, so the Lean registry cannot be built")
        return errors

    try:
        rendered_text = emit_manifest(root)
        rendered_bridges_text = emit_manifest(root, "--bridges")
    except RuntimeError as exc:
        errors.append(str(exc))
        return errors

    try:
        rendered = json.loads(rendered_text)
    except json.JSONDecodeError as exc:
        errors.append(f"the Lean renderer did not emit valid JSON: {exc}")
        return errors

    try:
        rendered_bridges = json.loads(rendered_bridges_text)
    except json.JSONDecodeError as exc:
        errors.append(f"the Lean renderer did not emit valid bridge JSON: {exc}")
        return errors

    errors.extend(compare(committed, rendered))
    errors.extend(compare_bridges(committed_bridges, rendered_bridges))

    for entry in committed.get("entries", []):
        missing = [field for field in EXPECTED_FIELDS if field not in entry]
        if missing:
            errors.append(f"entry {entry.get('slug')!r} lacks fields {missing}")

    return errors


def write(root: Path) -> int:
    """Regenerate the committed records from the Lean declarations."""
    try:
        rendered_text = emit_manifest(root)
        rendered_bridges_text = emit_manifest(root, "--bridges")
    except RuntimeError as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 1
    rendered = json.loads(rendered_text)
    manifest = {
        "schemaVersion": rendered.get("schemaVersion", 1),
        "reviewState": rendered.get("reviewState", "source-derived-unreviewed"),
        "entries": rendered.get("entries", []),
    }
    MANIFEST_PATH.write_text(
        json.dumps(manifest, indent=2, ensure_ascii=False) + "\n", encoding="utf-8"
    )
    print(f"wrote {MANIFEST_PATH} with {len(manifest['entries'])} entries")

    rendered_bridges = json.loads(rendered_bridges_text)
    BRIDGES_PATH.write_text(
        json.dumps(rendered_bridges, indent=2, ensure_ascii=False) + "\n", encoding="utf-8"
    )
    print(f"wrote {BRIDGES_PATH} with {len(rendered_bridges.get('bridges', []))} bridges")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--write",
        action="store_true",
        help="regenerate the committed JSON records from the Lean declarations",
    )
    args = parser.parse_args()

    if args.write:
        return write(REPO_ROOT)

    errors = check(REPO_ROOT)
    if errors:
        print("the committed JSON records do not match the Lean declarations:", file=sys.stderr)
        for error in errors:
            print(f"  - {error}", file=sys.stderr)
        print(
            "\nThe Lean declarations are the source of truth. If the change is "
            "intended, regenerate with: python scripts/check_manifest.py --write",
            file=sys.stderr,
        )
        return 1
    print("ecosystem.json and bridges.json match the Lean declarations")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
