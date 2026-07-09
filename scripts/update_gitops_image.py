import argparse
from pathlib import Path
from typing import Any

import yaml


def set_helm_parameter(parameters: list[dict[str, Any]], name: str, value: str) -> None:
    for parameter in parameters:
        if parameter.get("name") == name:
            parameter["value"] = value
            return

    parameters.append({"name": name, "value": value})


def main() -> None:
    parser = argparse.ArgumentParser(description="Update Argo CD Helm image parameters.")
    parser.add_argument("--file", required=True, help="Argo CD Application YAML file.")
    parser.add_argument("--repository", required=True, help="Container image repository.")
    parser.add_argument("--tag", required=True, help="Container image tag.")
    args = parser.parse_args()

    application_path = Path(args.file)
    document = yaml.safe_load(application_path.read_text(encoding="utf-8"))

    helm = document.setdefault("spec", {}).setdefault("source", {}).setdefault("helm", {})
    parameters = helm.setdefault("parameters", [])

    set_helm_parameter(parameters, "image.repository", args.repository)
    set_helm_parameter(parameters, "image.tag", args.tag)

    application_path.write_text(
        yaml.safe_dump(document, sort_keys=False, indent=2),
        encoding="utf-8",
    )


if __name__ == "__main__":
    main()
