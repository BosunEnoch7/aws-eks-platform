import argparse
from pathlib import Path

import yaml


def main() -> None:
    parser = argparse.ArgumentParser(description="Parse YAML files under one or more paths.")
    parser.add_argument("paths", nargs="+", help="Files or directories to validate.")
    args = parser.parse_args()

    files: list[Path] = []
    for raw_path in args.paths:
        path = Path(raw_path)
        if path.is_dir():
            files.extend(sorted(path.rglob("*.yaml")))
            files.extend(sorted(path.rglob("*.yml")))
        elif path.is_file():
            files.append(path)

    for file_path in files:
        with file_path.open(encoding="utf-8") as handle:
            list(yaml.safe_load_all(handle))

    print(f"parsed {len(files)} yaml files")


if __name__ == "__main__":
    main()
