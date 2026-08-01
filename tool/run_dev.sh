#!/usr/bin/env bash
# Golfie dev runner — selects .env.<env> and passes ENV + values to Flutter.
#
# Usage:
#   tool/run_dev.sh                    # development (default)
#   tool/run_dev.sh staging            # staging
#   tool/run_dev.sh production         # production
#   tool/run_dev.sh -d emulator-5554   # dev + device flag
#   tool/run_dev.sh --release          # dev + release build
#
# Requires: .env.<env> at repo root. Values are passed via --dart-define
# because flutter_dotenv cannot read files at runtime (assets are bundled
# at compile time).

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_NAME="${1:-development}"
ENV_FILE="$ROOT/.env.$ENV_NAME"

if [[ "$1" =~ ^- ]]; then
  ENV_NAME="development"
  ENV_FILE="$ROOT/.env.development"
fi

if [[ ! -f "$ENV_FILE" ]]; then
  echo "⚠ Missing $ENV_FILE — create it (copy .env.example and fill values)." >&2
  exit 1
fi

DEFINES=("--dart-define=ENV=$ENV_NAME")
while IFS='=' read -r key value; do
  [[ -z "$key" || "$key" == \#* ]] && continue
  DEFINES+=("--dart-define=$key=$value")
done < "$ENV_FILE"

cd "$ROOT"
echo "▶ Running Golfie ($ENV_NAME)"
exec flutter run "${DEFINES[@]}" "$@"
