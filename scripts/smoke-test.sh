#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${APP_URL:-}" ]]; then
  echo "Définissez APP_URL avec l'URL publique de la copie DEV." >&2
  exit 1
fi

status="$(curl -sS -o /dev/null -w '%{http_code}' "$APP_URL")"
echo "HTTP $status - $APP_URL"

if [[ "$status" -lt 200 || "$status" -ge 400 ]]; then
  exit 1
fi
