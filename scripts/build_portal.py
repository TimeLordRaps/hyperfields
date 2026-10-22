"""Build the first-class multi-repository Hyperfields portal around the Lean proofsite."""

from __future__ import annotations

import argparse
import json
import re
from html import escape
from pathlib import Path
from urllib.parse import quote

SITE_URL = "https://timelordraps.github.io/hyperfields/"
PROJECT_URL = "https://github.com/TimeLordRaps/hyperfields"
ROLE_ORDER = (
    "hyperfield",
    "grounded-layer",
    "structural-hub",
    "ordinal-infrastructure",
    "meta-framework",
)
ROLE_LABELS = {
    "hyperfield": "Hyperfields",
    "grounded-layer": "Grounded layers",
    "structural-hub": "Structural hubs",
    "ordinal-infrastructure": "Ordinal infrastructure",
    "meta-framework": "Meta-frameworks",
}
ROLE_DESCRIPTIONS = {
    "hyperfield": "Field-level accounts of recurring formative structure, including communicative fields.",
    "grounded-layer": "Derived structures that explicitly depend on Hypermath or other non-lowest-level concepts.",
    "structural-hub": "Integrative accounts that organize structures and relations across fields.",
    "ordinal-infrastructure": "Ordinal-first formal infrastructure that supports, but is not silently relabelled as, a hyperfield.",
    "meta-framework": "Reflective and cross-field frameworks whose authority remains separate from their sources.",
}
ROLE_ACCENTS = {
    "hyperfield": "#6941c6",
    "grounded-layer": "#067647",
    "structural-hub": "#175cd3",
    "ordinal-infrastructure": "#b54708",
    "meta-framework": "#c11574",
}


def _load_manifest(path: Path) -> dict:
    data = json.loads(path.read_text(encoding="utf-8"))
    if data.get("schemaVersion") != 1 or not isinstance(data.get("entries"), list):
        raise ValueError("ecosystem manifest must have schemaVersion 1 and an entries list")
    return data


def _source_link(entry: dict) -> tuple[str, str] | None:
    repository = entry.get("repository")
    revision = entry.get("revision")
    if repository and revision:
        return f"{repository}/tree/{revision}", f"Source at {revision[:12]}"
    if repository:
        return repository, "Public repository"
    return None


def _state_label(state: str) -> str:
    return {
        "public-main-pinned": "public source pinned",
        "public-without-main": "public repository; no main ref pinned",
        "local-candidate-unpublished": "local candidate; unpublished",
    }[state]


def _head(title: str, description: str, canonical: str, css: str) -> str:
    structured = json.dumps(
        {
            "@context": "https://schema.org",
            "@type": "WebPage",
            "name": title,
            "url": canonical,
            "description": description,
            "isPartOf": {"@type": "WebSite", "name": "Hyperfields", "url": SITE_URL},
        },
        ensure_ascii=False,
        separators=(",", ":"),
    ).replace("<", "\\u003c")
    return "\n".join(
        (
            "<!doctype html>",
            '<html lang="en">',
            "<head>",
            '<meta charset="utf-8">',
            '<meta name="viewport" content="width=device-width, initial-scale=1">',
            f"<title>{escape(title)}</title>",
            f'<meta name="description" content="{escape(description, quote=True)}">',
            f'<meta property="og:title" content="{escape(title, quote=True)}">',
            f'<meta property="og:description" content="{escape(description, quote=True)}">',
            '<meta property="og:site_name" content="Hyperfields">',
            '<meta property="og:type" content="website">',
            '<meta name="twitter:card" content="summary">',
            f'<link rel="canonical" href="{escape(canonical, quote=True)}">',
            f'<meta property="og:url" content="{escape(canonical, quote=True)}">',
            f'<script type="application/ld+json">{structured}</script>',
            f'<link rel="stylesheet" href="{escape(css, quote=True)}">',
            "</head>",
            "<body>",
            '<a class="skip-link" href="#content">Skip to content</a>',
        )
    )


def _card(entry: dict) -> str:
    slug = escape(entry["slug"], quote=True)
    name = escape(entry["displayName"])
    summary = escape(entry["summary"])
    grounding = escape(entry["grounding"])
    state = escape(_state_label(entry["sourceState"]))
    modes = " · ".join(escape(mode) for mode in entry["modes"])
    source = _source_link(entry)
    source_html = (
        f'<a href="{escape(source[0], quote=True)}">{escape(source[1])}</a>'
        if source
        else "No public source coordinate"
    )
    return "\n".join(
        (
            f'<article class="field-card" data-search="{escape((entry["displayName"] + " " + entry["slug"] + " " + entry["summary"] + " " + entry["grounding"]).lower(), quote=True)}">',
            f'<div class="card-top"><span class="state">{state}</span><span class="modes">{modes}</span></div>',
            f'<h3><a href="fields/{slug}/">{name}</a></h3>',
            f"<p>{summary}</p>",
            f'<p class="grounding"><strong>Grounding:</strong> {grounding}</p>',
            f'<nav class="card-links" aria-label="{name} links"><a href="fields/{slug}/">Hosted explainer</a><span aria-hidden="true">·</span>{source_html}</nav>',
            "</article>",
        )
    )


def _landing(manifest: dict, trust: dict, revision: str) -> str:
    entries = manifest["entries"]
    public = sum(entry["sourceState"].startswith("public-") for entry in entries)
    candidates = sum(entry["sourceState"] == "local-candidate-unpublished" for entry in entries)
    declarations = trust.get("declarations", {})
    checked = declarations.get("kernel_checked", "UNKNOWN")
    total = declarations.get("total", "UNKNOWN")
    groups = []
    for role in ROLE_ORDER:
        members = [entry for entry in entries if entry["role"] == role]
        cards = "\n".join(_card(entry) for entry in members)
        groups.append(
            "\n".join(
                (
                    f'<section class="field-group" id="{role}" style="--accent:{ROLE_ACCENTS[role]}">',
                    f'<header><p class="eyebrow">{len(members)} sections</p><h2>{ROLE_LABELS[role]}</h2><p>{ROLE_DESCRIPTIONS[role]}</p></header>',
                    f'<div class="card-grid">{cards}</div>',
                    "</section>",
                )
            )
        )
    title = "Hyperfields — the unified ecosystem explainer"
    description = "A Lean 4-checked, source-pinned portal for every public repository and registered candidate in the Hyperfields ecosystem."
    return "\n".join(
        (
            _head(title, description, SITE_URL, "_assets/portal.css"),
            '<header class="masthead"><div class="shell">',
            '<p class="brand"><a href="index.html">HYPERFIELDS</a></p>',
            '<nav aria-label="Primary"><a href="#ecosystem">Ecosystem</a><a href="learning-path.html">Learning path</a><a href="map.html">Map</a><a href="trust.html">Trust</a><a href="glossary.html">Glossary</a></nav>',
            "</div></header>",
            '<main id="content" tabindex="-1">',
            '<section class="hero"><div class="shell">',
            '<p class="eyebrow">One portal · every registered field</p>',
            "<h1>The formative foundations,<br>held in one place.</h1>",
            "<p class=\"lede\">Hyperfields hosts a first-class explainer section for every public ecosystem repository and every explicitly marked unpublished candidate. Each section keeps checked Lean structure, source authority, and explanatory review status separate.</p>",
            '<div class="metrics" aria-label="Portal coverage">',
            f'<div><strong>{len(entries)}</strong><span>hosted sections</span></div>',
            f'<div><strong>{public}</strong><span>public repositories</span></div>',
            f'<div><strong>{candidates}</strong><span>unpublished candidates</span></div>',
            f'<div><strong>{checked}/{total}</strong><span>kernel-checked declarations</span></div>',
            "</div>",
            '<div class="hero-actions"><a class="button primary" href="#ecosystem">Explore all fields</a><a class="button" href="ecosystem.json">Machine-readable registry</a></div>',
            "</div></section>",
            '<section class="disclosure"><div class="shell"><strong>Evidence boundary.</strong> The portal revision is '
            + escape(revision[:12])
            + ". All explanations are <code>source-derived-unreviewed</code>. Lean checks the registry and section definitions; it does not by itself validate scientific or metaphysical claims.</div></section>",
            '<section class="directory shell" id="ecosystem">',
            '<div class="directory-head"><div><p class="eyebrow">Complete directory</p><h2>All ecosystem sections</h2></div><label>Filter fields<input id="field-filter" type="search" placeholder="Name, concept, or grounding…" autocomplete="off"></label></div>',
            *groups,
            '<p id="no-results" class="no-results" hidden>No ecosystem sections match that filter.</p>',
            "</section>",
            "</main>",
            '<footer><div class="shell"><p>Built from source-pinned explanations and Lean-checked catalogue structure.</p><nav><a href="Hyperfields/Registry.lean.html">Checked registry</a><a href="trust.html">Trust report</a><a href="' + PROJECT_URL + '">Repository</a></nav></div></footer>',
            '<script>const q=document.querySelector("#field-filter"),cards=[...document.querySelectorAll(".field-card")],empty=document.querySelector("#no-results");q.addEventListener("input",()=>{const v=q.value.trim().toLowerCase();let n=0;for(const c of cards){const show=!v||c.dataset.search.includes(v);c.hidden=!show;if(show)n++}empty.hidden=n!==0});</script>',
            "</body>",
            "</html>",
            "",
        )
    )


def _field_page(entry: dict, previous: dict, following: dict, revision: str) -> str:
    slug = entry["slug"]
    name = entry["displayName"]
    description = entry["summary"]
    canonical = f"{SITE_URL}fields/{quote(slug)}/"
    module_page = f"../../Hyperfields/Fields/{quote(entry['module'])}.lean.html"
    source = _source_link(entry)
    if source:
        source_action = f'<a class="button" href="{escape(source[0], quote=True)}">{escape(source[1])}</a>'
    else:
        source_action = '<span class="button disabled" aria-disabled="true">No public source coordinate</span>'
    modes = "".join(f"<li>{escape(mode)}</li>" for mode in entry["modes"])
    public_note = {
        "public-main-pinned": "The explanatory record is bound to the exact public main commit linked above.",
        "public-without-main": "A public repository was observed, but no public main ref was available to pin at inspection time.",
        "local-candidate-unpublished": "This is an explicitly registered local candidate. The portal does not invent a public repository or source pin for it.",
    }[entry["sourceState"]]
    accent = ROLE_ACCENTS[entry["role"]]
    return "\n".join(
        (
            _head(f"{name} — Hyperfields", description, canonical, "../../_assets/portal.css"),
            f'<header class="masthead" style="--accent:{accent}"><div class="shell"><p class="brand"><a href="../../index.html">HYPERFIELDS</a></p><nav aria-label="Primary"><a href="../../index.html#ecosystem">All fields</a><a href="../../trust.html">Trust</a><a href="../../glossary.html">Glossary</a></nav></div></header>',
            '<main id="content" class="field-page" tabindex="-1">',
            '<section class="field-hero" style="--accent:' + accent + '"><div class="shell">',
            f'<p class="eyebrow">{escape(ROLE_LABELS[entry["role"]])} · {escape(_state_label(entry["sourceState"]))}</p>',
            f"<h1>{escape(name)}</h1>",
            f'<p class="lede">{escape(description)}</p>',
            f'<div class="hero-actions"><a class="button primary" href="{module_page}">Open checked Lean entry</a>{source_action}</div>',
            "</div></section>",
            '<section class="field-body shell">',
            '<div class="facts">',
            f'<div><span>Grounding</span><strong>{escape(entry["grounding"])}</strong></div>',
            f'<div><span>Operating modes</span><ul class="mode-list">{modes}</ul></div>',
            '<div><span>Explanation review</span><strong>source-derived, unreviewed</strong></div>',
            f'<div><span>Portal coordinate</span><strong>{escape(revision[:12])}</strong></div>',
            "</div>",
            '<div class="prose-grid">',
            '<article><p class="eyebrow">What is hosted here</p><h2>A first-class ecosystem section</h2><p>This page, its dedicated Lean module, its source coordinate, and its place in the complete ecosystem directory are published together. It is not merely a row hidden inside a registry.</p></article>',
            '<article><p class="eyebrow">What Lean checks</p><h2>Identity and catalogue integration</h2><p>The dedicated module elaborates an <code>Entry</code> that resolves directly to the canonical registry definition. The release gate also requires this page, its generated Lean page, and its manifest record to agree.</p></article>',
            '<article><p class="eyebrow">Source boundary</p><h2>Provenance without authority transfer</h2><p>' + escape(public_note) + ' Source provenance establishes what was inspected; it does not establish the truth of every external claim.</p></article>',
            '<article><p class="eyebrow">Semantic boundary</p><h2>Awaiting owner review</h2><p>The current explanation remains visibly unreviewed by Tyler. Compilation cannot silently promote source-derived prose to owner-reviewed doctrine.</p></article>',
            "</div>",
            f'<nav class="pager" aria-label="Adjacent ecosystem sections"><a href="../{escape(previous["slug"], quote=True)}/">← {escape(previous["displayName"])}</a><a href="../../index.html#ecosystem">All sections</a><a href="../{escape(following["slug"], quote=True)}/">{escape(following["displayName"])} →</a></nav>',
            "</section>",
            "</main>",
            '<footer><div class="shell"><p>Part of the unified Hyperfields ecosystem explainer.</p><nav><a href="../../Hyperfields/Registry.lean.html">Checked registry</a><a href="../../ecosystem.json">Registry JSON</a><a href="' + PROJECT_URL + '">Repository</a></nav></div></footer>',
            "</body>",
            "</html>",
            "",
        )
    )


PORTAL_CSS = r"""
:root{--ink:#17151f;--muted:#666170;--paper:#fbfaf7;--panel:#fff;--line:#ded9e3;--violet:#6941c6;--soft:#f3effb;font-family:Inter,ui-sans-serif,system-ui,-apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif;color:var(--ink);background:var(--paper);font-synthesis:none}
*{box-sizing:border-box}html{scroll-behavior:smooth}body{margin:0;line-height:1.55}a{color:inherit;text-decoration-thickness:.08em;text-underline-offset:.18em}.shell{width:min(1160px,calc(100% - 40px));margin-inline:auto}.skip-link{position:absolute;left:-9999px;top:10px}.skip-link:focus{left:10px;z-index:10;background:#fff;padding:10px;border:2px solid var(--violet)}
.masthead{border-bottom:1px solid var(--line);background:rgba(251,250,247,.95);position:sticky;top:0;z-index:5;backdrop-filter:blur(12px)}.masthead .shell{display:flex;align-items:center;justify-content:space-between;min-height:68px;gap:24px}.brand{font:800 .8rem/1 ui-monospace,SFMono-Regular,Menlo,monospace;letter-spacing:.16em;margin:0}.brand a{text-decoration:none}.masthead nav,.site-footer nav,footer nav{display:flex;gap:18px;flex-wrap:wrap}.masthead nav a{text-decoration:none;color:var(--muted);font-size:.92rem}.masthead nav a:hover{color:var(--ink)}
.hero,.field-hero{padding:clamp(68px,9vw,128px) 0;background:radial-gradient(circle at 80% 10%,#e8ddff 0,transparent 33%),linear-gradient(135deg,#fbfaf7,#f4efff)}.eyebrow{text-transform:uppercase;letter-spacing:.13em;font:750 .72rem/1.4 ui-monospace,SFMono-Regular,Menlo,monospace;color:var(--accent,var(--violet));margin:0 0 12px}.hero h1,.field-hero h1{font-family:Georgia,"Times New Roman",serif;font-weight:500;font-size:clamp(3rem,7vw,6.8rem);line-height:.93;letter-spacing:-.055em;margin:0;max-width:1000px}.field-hero h1{font-size:clamp(3rem,6vw,5.8rem)}.lede{font-size:clamp(1.06rem,2vw,1.35rem);max-width:780px;color:#4d4756;margin:30px 0}.metrics{display:grid;grid-template-columns:repeat(4,1fr);gap:1px;background:var(--line);border:1px solid var(--line);margin-top:46px;max-width:920px}.metrics div{display:flex;flex-direction:column;background:rgba(255,255,255,.74);padding:22px}.metrics strong{font:600 1.8rem/1 Georgia,serif}.metrics span{color:var(--muted);font-size:.82rem;margin-top:7px}.hero-actions{display:flex;gap:12px;flex-wrap:wrap;margin-top:30px}.button{display:inline-flex;align-items:center;justify-content:center;min-height:44px;padding:10px 16px;border:1px solid #98919f;border-radius:999px;text-decoration:none;background:#fff}.button.primary{background:var(--ink);color:#fff;border-color:var(--ink)}.button.disabled{color:var(--muted);background:#eee;cursor:not-allowed}.disclosure{border-block:1px solid var(--line);background:#fff;padding:18px 0;color:var(--muted);font-size:.92rem}.disclosure strong{color:var(--ink)}
.directory{padding-block:72px 100px}.directory-head{display:flex;justify-content:space-between;align-items:end;gap:30px;margin-bottom:50px}.directory h2,.field-body h2{font:500 clamp(2rem,4vw,3.5rem)/1.05 Georgia,serif;letter-spacing:-.035em;margin:0}.directory-head label{font-size:.78rem;color:var(--muted);display:grid;gap:6px;min-width:min(360px,100%)}input[type=search]{font:inherit;color:var(--ink);background:#fff;border:1px solid #a9a2af;border-radius:8px;padding:11px 13px;width:100%}.field-group{padding:54px 0;border-top:3px solid var(--accent)}.field-group>header{max-width:780px;margin-bottom:25px}.field-group>header h2{font-size:clamp(2rem,4vw,3rem)}.field-group>header>p:last-child{color:var(--muted);font-size:1.02rem}.card-grid{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:16px}.field-card{display:flex;flex-direction:column;min-height:285px;background:var(--panel);border:1px solid var(--line);border-radius:14px;padding:22px;box-shadow:0 8px 24px rgba(37,28,48,.04)}.field-card[hidden]{display:none}.card-top{display:flex;gap:8px;justify-content:space-between;align-items:start;color:var(--muted);font-size:.7rem;text-transform:uppercase;letter-spacing:.06em}.modes{text-align:right}.field-card h3{font:600 1.55rem/1.15 Georgia,serif;margin:28px 0 10px}.field-card>p{color:#4d4756;margin:0 0 12px}.field-card .grounding{font-size:.84rem}.card-links{display:flex;gap:8px;flex-wrap:wrap;margin-top:auto;padding-top:16px;font-size:.84rem}.card-links a:first-child{font-weight:700}.no-results{padding:40px;border:1px dashed var(--line)}
.field-body{padding-block:56px 100px}.facts{display:grid;grid-template-columns:repeat(4,1fr);border:1px solid var(--line);background:var(--line);gap:1px;margin-bottom:58px}.facts>div{background:#fff;padding:22px;display:flex;flex-direction:column;gap:9px}.facts span{font-size:.75rem;text-transform:uppercase;letter-spacing:.09em;color:var(--muted)}.facts strong{font-size:.95rem}.mode-list{list-style:none;padding:0;margin:0;display:flex;gap:7px;flex-wrap:wrap}.mode-list li{font-size:.8rem;background:var(--soft);padding:3px 8px;border-radius:999px}.prose-grid{display:grid;grid-template-columns:repeat(2,1fr);gap:52px 64px}.prose-grid article{border-top:2px solid var(--line);padding-top:22px}.prose-grid h2{font-size:2rem;margin-bottom:16px}.prose-grid p:last-child{color:#4d4756}.pager{display:grid;grid-template-columns:1fr auto 1fr;gap:12px;border-top:1px solid var(--line);margin-top:70px;padding-top:24px}.pager a:last-child{text-align:right}
footer{background:#1f1b26;color:#e8e3ec;padding:34px 0}footer .shell{display:flex;justify-content:space-between;align-items:center;gap:24px}footer p{margin:0;color:#bbb4c2}footer a{color:#fff}
@media(max-width:900px){.card-grid{grid-template-columns:repeat(2,minmax(0,1fr))}.metrics,.facts{grid-template-columns:repeat(2,1fr)}}
@media(max-width:620px){.shell{width:min(100% - 26px,1160px)}.masthead .shell{align-items:flex-start;padding-block:16px;flex-direction:column}.hero,.field-hero{padding:58px 0}.metrics,.facts,.card-grid,.prose-grid{grid-template-columns:1fr}.directory-head,footer .shell{align-items:flex-start;flex-direction:column}.pager{grid-template-columns:1fr}.pager a:last-child{text-align:left}.field-card{min-height:0}}
@media(prefers-reduced-motion:reduce){html{scroll-behavior:auto}}
""".strip() + "\n"


def build(site: Path, manifest_path: Path, revision: str) -> None:
    manifest = _load_manifest(manifest_path)
    trust_path = site / "trust.json"
    trust = json.loads(trust_path.read_text(encoding="utf-8"))
    entries = manifest["entries"]

    assets = site / "_assets"
    assets.mkdir(parents=True, exist_ok=True)
    (assets / "portal.css").write_text(PORTAL_CSS, encoding="utf-8", newline="\n")
    (site / "index.html").write_text(_landing(manifest, trust, revision), encoding="utf-8", newline="\n")

    for index, entry in enumerate(entries):
        target = site / "fields" / entry["slug"] / "index.html"
        target.parent.mkdir(parents=True, exist_ok=True)
        previous = entries[(index - 1) % len(entries)]
        following = entries[(index + 1) % len(entries)]
        target.write_text(_field_page(entry, previous, following, revision), encoding="utf-8", newline="\n")

    public_manifest = dict(manifest)
    public_manifest["portalRevision"] = revision
    public_manifest["portalRepository"] = PROJECT_URL
    (site / "ecosystem.json").write_text(
        json.dumps(public_manifest, indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8",
        newline="\n",
    )

    pages = sorted(path.relative_to(site).as_posix() for path in site.rglob("*.html") if path.name != "404.html")
    urls = "".join(f"<url><loc>{escape(SITE_URL + quote(page, safe='/'))}</loc></url>" for page in pages)
    sitemap = '<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">' + urls + "</urlset>\n"
    (site / "sitemap.xml").write_text(sitemap, encoding="utf-8", newline="\n")
    (site / "robots.txt").write_text(f"User-agent: *\nAllow: /\nSitemap: {SITE_URL}sitemap.xml\n", encoding="utf-8", newline="\n")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--site", required=True, type=Path)
    parser.add_argument("--manifest", required=True, type=Path)
    parser.add_argument("--revision", required=True)
    args = parser.parse_args()
    revision = args.revision.strip().lower()
    if not re.fullmatch(r"[0-9a-f]{40}", revision):
        parser.error("--revision must be a full 40-character lowercase Git SHA")
    build(args.site.resolve(), args.manifest.resolve(), revision)
    print("Hyperfields multi-repository portal: BUILT")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

