"""Fail closed on the generated Hyperfields proofsite's release contract."""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path


REQUIRED = (
    "index.html",
    "trust.html",
    "trust.json",
    "glossary.html",
    "learning-path.html",
    "map.html",
    "Hyperfields/Core.lean.html",
    "Hyperfields/Registry.lean.html",
)


def check(site: Path, revision: str) -> list[str]:
    errors: list[str] = []
    for relative in REQUIRED:
        if not (site / relative).is_file():
            errors.append(f"missing {relative}")
    if errors:
        return errors

    try:
        trust = json.loads((site / "trust.json").read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        return [f"trust.json is unreadable: {exc}"]

    files = trust.get("files") if isinstance(trust.get("files"), dict) else {}
    declarations = trust.get("declarations") if isinstance(trust.get("declarations"), dict) else {}
    total = declarations.get("total")
    checked = declarations.get("kernel_checked")
    if trust.get("format") != 1 or trust.get("provenance") != "local-lean-run":
        errors.append("trust.json is not a local Lean run")
    if "version 4.34.1" not in str(trust.get("toolchain", "")):
        errors.append("trust.json does not identify Lean 4.34.1")
    if not isinstance(total, int) or total <= 0 or checked != total:
        errors.append(f"not every declaration is positively kernel checked: {checked}/{total}")
    for key in ("sorry", "extra axioms", "unknown"):
        if declarations.get(key) != 0:
            errors.append(f"declarations.{key} is {declarations.get(key)!r}, expected 0")
    for key in ("failed", "unavailable"):
        if files.get(key) != 0:
            errors.append(f"files.{key} is {files.get(key)!r}, expected 0")

    landing = (site / "index.html").read_text(encoding="utf-8")
    registry = (site / "Hyperfields" / "Registry.lean.html").read_text(encoding="utf-8")
    if "https://timelordraps.github.io/hyperfields/" not in landing:
        errors.append("landing page lacks the canonical public URL")
    if revision not in registry:
        errors.append("rendered source links are not bound to the requested revision")
    for expected in (
        "Hypermath",
        "Hyperphysics",
        "Grounded Hypercalculi",
        "Grounded Hyperset Theory",
        "Metamathethicology",
        "Meta-Morphoscripted-Origination",
    ):
        if expected not in registry:
            errors.append(f"registry page does not expose {expected}")

    private_patterns = (
        re.compile(r"[A-Za-z]:\\Users\\", re.IGNORECASE),
        re.compile(r"[A-Za-z]:\\(?:hyper|ordinatics|metamathethicology)", re.IGNORECASE),
    )
    for path in site.rglob("*"):
        if path.suffix.lower() not in {".html", ".json", ".js", ".css", ".xml", ".txt"}:
            continue
        text = path.read_text(encoding="utf-8", errors="replace")
        if any(pattern.search(text) for pattern in private_patterns):
            errors.append(f"private workstation path leaked into {path.relative_to(site).as_posix()}")
    return errors


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--site", required=True, type=Path)
    parser.add_argument("--revision", required=True)
    args = parser.parse_args()
    revision = args.revision.strip().lower()
    if not re.fullmatch(r"[0-9a-f]{40}", revision):
        parser.error("--revision must be a full 40-character lowercase Git SHA")
    errors = check(args.site.resolve(), revision)
    if errors:
        for error in errors:
            print(f"error: {error}")
        return 1
    print("Hyperfields proofsite release contract: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
