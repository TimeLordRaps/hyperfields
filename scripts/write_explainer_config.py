"""Write a release config bound to one exact hyperfields revision."""

from __future__ import annotations

import argparse
import re
from pathlib import Path


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--revision", required=True)
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()

    revision = args.revision.strip().lower()
    if not re.fullmatch(r"[0-9a-f]{40}", revision):
        parser.error("--revision must be a full 40-character lowercase Git SHA")

    text = f'''title = "Hyperfields"
description = "A Lean 4-checked, source-pinned explainer of the TimeLordRaps hyperfield ecosystem."
source_url = "https://github.com/TimeLordRaps/hyperfields/blob/{{ref}}/{{path}}#L{{line}}"
source_ref = "{revision}"
source_links = "declaration"
site_url = "https://timelordraps.github.io/hyperfields/"
project_url = "https://github.com/TimeLordRaps/hyperfields"
report_url = "https://github.com/TimeLordRaps/hyperfields/issues/new"
byte_budget = 100000000
'''
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(text, encoding="utf-8", newline="\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
