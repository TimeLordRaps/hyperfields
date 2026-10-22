"""Fail closed on the generated Hyperfields proofsite's release contract."""

from __future__ import annotations

import argparse
import json
import re
import subprocess
from pathlib import Path


REQUIRED = (
    "index.html",
    "ecosystem.json",
    "trust.html",
    "trust.json",
    "glossary.html",
    "learning-path.html",
    "map.html",
    "Hyperfields/Core.lean.html",
    "Hyperfields/Registry.lean.html",
    "Hyperfields/AllFields.lean.html",
)

EXPECTED_ROLE_COUNTS = {
    "hyperfield": 21,
    "grounded-layer": 2,
    "structural-hub": 2,
    "ordinal-infrastructure": 1,
    "meta-framework": 2,
}


def pinned_toolchain(root: Path) -> str:
    """The Lean version this repository is pinned to, read from its own pin.

    The release gate holds the proofsite to the toolchain the sources were
    built with, so the expected version is read rather than written here: a
    toolchain bump must not be able to leave the gate asserting a version
    nobody builds with.
    """
    text = (root / "lean-toolchain").read_text(encoding="utf-8").strip()
    match = re.search(r"v(\d+\.\d+\.\d+)", text)
    if not match:
        raise ValueError(f"lean-toolchain does not name a version: {text!r}")
    return match.group(1)


def check(site: Path, revision: str, expected_lean: str) -> list[str]:
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
    if f"version {expected_lean}" not in str(trust.get("toolchain", "")):
        errors.append(f"trust.json does not identify Lean {expected_lean}")
    if not isinstance(total, int) or total <= 0 or checked != total:
        errors.append(f"not every declaration is positively kernel checked: {checked}/{total}")
    for key in ("sorry", "extra axioms", "unknown"):
        if declarations.get(key) != 0:
            errors.append(f"declarations.{key} is {declarations.get(key)!r}, expected 0")
    for key in ("failed", "unavailable"):
        if files.get(key) != 0:
            errors.append(f"files.{key} is {files.get(key)!r}, expected 0")

    try:
        ecosystem = json.loads((site / "ecosystem.json").read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        return [f"ecosystem.json is unreadable: {exc}"]
    entries = ecosystem.get("entries")
    if ecosystem.get("schemaVersion") != 1 or not isinstance(entries, list):
        return ["ecosystem.json must have schemaVersion 1 and an entries list"]
    if ecosystem.get("portalRevision") != revision:
        errors.append("ecosystem.json is not bound to the requested portal revision")
    if ecosystem.get("reviewState") != "source-derived-unreviewed":
        errors.append("ecosystem.json does not preserve the unreviewed explanation boundary")
    if len(entries) != 28:
        errors.append(f"ecosystem.json has {len(entries)} entries, expected 28")

    slugs = [entry.get("slug") for entry in entries]
    modules = [entry.get("module") for entry in entries]
    if len(slugs) != len(set(slugs)):
        errors.append("ecosystem.json contains duplicate slugs")
    if len(modules) != len(set(modules)):
        errors.append("ecosystem.json contains duplicate module names")
    role_counts = {
        role: sum(entry.get("role") == role for entry in entries)
        for role in EXPECTED_ROLE_COUNTS
    }
    if role_counts != EXPECTED_ROLE_COUNTS:
        errors.append(f"ecosystem role counts are {role_counts!r}, expected {EXPECTED_ROLE_COUNTS!r}")
    public_count = sum(str(entry.get("sourceState", "")).startswith("public-") for entry in entries)
    candidate_count = sum(entry.get("sourceState") == "local-candidate-unpublished" for entry in entries)
    if (public_count, candidate_count) != (23, 5):
        errors.append(f"source-state counts are public={public_count}, candidates={candidate_count}; expected 23 and 5")

    landing = (site / "index.html").read_text(encoding="utf-8")
    registry = (site / "Hyperfields" / "Registry.lean.html").read_text(encoding="utf-8")
    if "https://timelordraps.github.io/hyperfields/" not in landing:
        errors.append("landing page lacks the canonical public URL")
    if revision not in registry:
        errors.append("rendered source links are not bound to the requested revision")
    if "28</strong><span>hosted sections" not in landing:
        errors.append("landing page does not state the complete 28-section coverage")
    for entry in entries:
        slug = entry.get("slug")
        module = entry.get("module")
        display_name = entry.get("displayName")
        if not all(isinstance(value, str) and value for value in (slug, module, display_name)):
            errors.append(f"entry lacks a valid slug, module, or displayName: {entry!r}")
            continue
        hosted = site / "fields" / slug / "index.html"
        lean_page = site / "Hyperfields" / "Fields" / f"{module}.lean.html"
        if not hosted.is_file():
            errors.append(f"missing first-class hosted page fields/{slug}/index.html")
            continue
        if not lean_page.is_file():
            errors.append(f"missing checked field page Hyperfields/Fields/{module}.lean.html")
            continue
        expected_card = f'href="fields/{slug}/"'
        if display_name not in landing or expected_card not in landing:
            errors.append(f"landing page does not expose {display_name} as a first-class card")
        hosted_text = hosted.read_text(encoding="utf-8")
        if display_name not in hosted_text or revision[:12] not in hosted_text:
            errors.append(f"hosted page for {display_name} lacks its name or portal coordinate")
        expected_module_link = f"../../Hyperfields/Fields/{module}.lean.html"
        if expected_module_link not in hosted_text:
            errors.append(f"hosted page for {display_name} does not link to its checked Lean entry")
        lean_text = lean_page.read_text(encoding="utf-8")
        if display_name not in lean_text:
            errors.append(f"checked field page for {display_name} lacks its field identity")
        source_state = entry.get("sourceState")
        source_revision = entry.get("revision")
        repository = entry.get("repository")
        if source_state == "public-main-pinned":
            if not isinstance(source_revision, str) or not re.fullmatch(r"[0-9a-f]{40}", source_revision):
                errors.append(f"{display_name} lacks a valid pinned source revision")
            elif source_revision not in registry or source_revision not in hosted_text:
                errors.append(f"{display_name} source pin is not visible in both registry and hosted page")
            if not isinstance(repository, str) or not repository.startswith("https://github.com/TimeLordRaps/"):
                errors.append(f"{display_name} lacks an expected public repository URL")
        elif source_state == "public-without-main":
            if not isinstance(repository, str) or source_revision is not None:
                errors.append(f"{display_name} public-without-main state is malformed")
        elif source_state == "local-candidate-unpublished":
            if repository is not None or source_revision is not None:
                errors.append(f"{display_name} unpublished candidate invents a public coordinate")
        else:
            errors.append(f"{display_name} has unknown source state {source_state!r}")

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


def remote_serves(repository: str, revision: str, timeout: float = 30.0) -> tuple[bool, str]:
    """Report whether the public remote advertises ``revision``.

    The portal publishes each public entry's exact source coordinate. A pin
    that no remote advertises is a false coordinate, and the portal's central
    "source-pinned" claim fails for that entry. The check is separate from the
    filesystem contract because it needs the network, so the release gate
    calls it only when asked.
    """
    try:
        result = subprocess.run(
            ["git", "ls-remote", repository],
            capture_output=True,
            text=True,
            timeout=timeout,
        )
    except (OSError, subprocess.SubprocessError) as exc:
        return False, f"remote query failed: {type(exc).__name__}"
    if result.returncode != 0:
        return False, f"remote query failed: {result.stderr.strip()[:200]}"
    if revision in result.stdout:
        return True, ""
    return False, "the remote does not advertise this revision"


def check_pins_resolve(entries: list[dict]) -> list[str]:
    """Check every published source pin against its public remote."""
    errors: list[str] = []
    for entry in entries:
        if entry.get("sourceState") != "public-main-pinned":
            continue
        slug = entry.get("slug")
        revision = entry.get("revision")
        repository = entry.get("repository")
        if not isinstance(revision, str) or not isinstance(repository, str):
            continue
        served, reason = remote_serves(repository, revision)
        if not served:
            errors.append(f"{slug} source pin {revision[:12]} is not served by {repository}: {reason}")
    return errors


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--site", required=True, type=Path)
    parser.add_argument("--revision", required=True)
    parser.add_argument(
        "--lean-root",
        type=Path,
        default=Path(__file__).resolve().parents[1],
        help="the repository whose lean-toolchain names the expected Lean version",
    )
    parser.add_argument(
        "--check-pins",
        action="store_true",
        help="also check every published source pin against its public remote (needs the network)",
    )
    args = parser.parse_args()
    revision = args.revision.strip().lower()
    if not re.fullmatch(r"[0-9a-f]{40}", revision):
        parser.error("--revision must be a full 40-character lowercase Git SHA")
    try:
        expected_lean = pinned_toolchain(args.lean_root.resolve())
    except (OSError, ValueError) as exc:
        parser.error(f"cannot read the pinned Lean version: {exc}")
    errors = check(args.site.resolve(), revision, expected_lean)
    if args.check_pins and not errors:
        try:
            entries = json.loads(
                (args.site.resolve() / "ecosystem.json").read_text(encoding="utf-8")
            )["entries"]
        except (OSError, KeyError, json.JSONDecodeError) as exc:
            errors.append(f"ecosystem.json is unreadable: {exc}")
        else:
            errors.extend(check_pins_resolve(entries))
    if errors:
        for error in errors:
            print(f"error: {error}")
        return 1
    print("Hyperfields proofsite release contract: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
