#!/usr/bin/env python3
"""Run the existing HDL benches in isolated build directories."""
import argparse
import json
from pathlib import Path
import re
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
EXAMPLES = json.loads((ROOT / "scripts/examples.json").read_text())
FAILURE = re.compile(r"\b(?:error|fatal|failed|failure)\b|total errors:\s*[1-9]", re.I)


def command(args, directory, timeout):
    result = subprocess.run(args, cwd=directory, text=True,
                            stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                            timeout=timeout)
    print(result.stdout, end="")
    if result.returncode or FAILURE.search(result.stdout):
        raise RuntimeError("compiler or testbench reported a failure")


def run(name, timeout):
    spec = EXAMPLES[name]
    directory = ROOT / "build" / name
    directory.mkdir(parents=True, exist_ok=True)
    sources = [str(ROOT / path) for path in spec["sources"]]
    required = ["ghdl"] if spec["language"] == "vhdl" else ["iverilog", "vvp"]
    for tool in required:
        if not shutil.which(tool):
            raise RuntimeError(f"{tool} is missing from PATH")
    if spec["language"] == "vhdl":
        command(["ghdl", "-a", "--std=08", *sources], directory, timeout)
        command(["ghdl", "-e", "--std=08", spec["top"]], directory, timeout)
        command(["ghdl", "-r", "--std=08", spec["top"],
                 "--assert-level=error", f"--vcd={name}.vcd"], directory, timeout)
    else:
        command(["iverilog", "-g2012", "-s", spec["top"],
                 "-o", "sim.vvp", *sources], directory, timeout)
        command(["vvp", "sim.vvp"], directory, timeout)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("example", nargs="?", choices=["all", *EXAMPLES])
    parser.add_argument("--list", action="store_true", help="list available examples")
    parser.add_argument("--timeout", type=float, default=30,
                        help="wall-clock timeout per command in seconds (default: 30)")
    args = parser.parse_args()
    if args.timeout <= 0:
        parser.error("--timeout must be positive")
    if args.list:
        for name, spec in EXAMPLES.items():
            print(f"{name:18} {spec['language']:5} {spec['top']}")
        return 0
    if not args.example:
        parser.error("provide an example name, all, or --list")
    names = list(EXAMPLES) if args.example == "all" else [args.example]
    failed = []
    for name in names:
        print(f"\nRunning {name}", flush=True)
        try:
            run(name, args.timeout)
        except (RuntimeError, OSError, subprocess.TimeoutExpired) as exc:
            print(f"FAIL: {name}: {exc}")
            failed.append(name)
        else:
            print(f"OK: {name} (existing bench completed)")
    print(f"\n{len(names) - len(failed)}/{len(names)} benches completed without reported errors.")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
