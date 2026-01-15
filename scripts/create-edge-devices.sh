#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 -h <hub-name> -f <device-list-file> [--print-connection-strings] [--prune]" >&2
  exit 1
}

HUB=""
FILE="devices.txt"
PRINT_CONN=false
PRUNE=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--hub)
      HUB="$2"; shift 2 ;;
    -f|--file)
      FILE="$2"; shift 2 ;;
    --print-connection-strings)
      PRINT_CONN=true; shift ;;
    --prune)
      PRUNE=true; shift ;;
    -h?|--help)
      usage ;;
    *)
      echo "Unknown argument: $1" >&2
      usage ;;
  esac
done

[[ -z "$HUB" ]] && usage
[[ ! -f "$FILE" ]] && { echo "Device list file not found: $FILE" >&2; exit 1; }

mapfile -t IDS < <(grep -v "^#" "$FILE" | sed '/^\s*$/d' | sed 's/^\s*//;s/\s*$//')
if [[ ${#IDS[@]} -eq 0 ]]; then
  echo "No device IDs found in $FILE" >&2
  exit 1
fi

echo "Ensuring Azure IoT extension is installed..."
az extension add --name azure-iot --yes >/dev/null

echo "Fetching existing Edge devices..."
mapfile -t EXISTING < <(az iot hub device-identity list --hub-name "$HUB" --query "[?capabilities.iotEdge==`true`].deviceId" -o tsv)

for id in "${IDS[@]}"; do
  echo "Creating/updating Edge device '$id' in hub '$HUB'..."
  az iot hub device-identity create --device-id "$id" --hub-name "$HUB" --edge-enabled --output none
  if $PRINT_CONN; then
    conn=$(az iot hub device-identity connection-string show --device-id "$id" --hub-name "$HUB" --query connectionString -o tsv)
    echo "$id: $conn"
  fi
done

if $PRUNE; then
  for eid in "${EXISTING[@]}"; do
    keep=false
    for nid in "${IDS[@]}"; do
      if [[ "$eid" == "$nid" ]]; then
        keep=true; break
      fi
    done
    if ! $keep; then
      echo "Deleting Edge device '$eid' (not in list)..."
      az iot hub device-identity delete --device-id "$eid" --hub-name "$HUB" --yes --output none
    fi
  done
fi

echo "Done."
