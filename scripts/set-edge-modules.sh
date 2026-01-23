#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 -h <hub-name> -d <device-id> -c <path to deployment.json>" >&2
  exit 1
}

HUB=""
DEVICE=""
CONTENT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--hub)
      HUB="$2"; shift 2 ;;
    -d|--device)
      DEVICE="$2"; shift 2 ;;
    -c|--content)
      CONTENT="$2"; shift 2 ;;
    -h?|--help)
      usage ;;
    *)
      echo "Unknown argument: $1" >&2
      usage ;;
  esac
done

[[ -z "$HUB" || -z "$DEVICE" || -z "$CONTENT" ]] && usage
[[ ! -f "$CONTENT" ]] && { echo "Deployment content file not found: $CONTENT" >&2; exit 1; }

echo "Ensuring Azure IoT extension is installed..."
az extension add --name azure-iot --yes >/dev/null

echo "Setting modules for Edge device '$DEVICE' in hub '$HUB'..."
az iot edge set-modules --hub-name "$HUB" --device-id "$DEVICE" --content "$CONTENT"

echo "Done."
