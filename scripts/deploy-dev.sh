#!/usr/bin/env bash
set -euo pipefail

repo_root="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
apex_dir="${1:-$repo_root/apex}"
sqlcl_bin="${SQLCL_BIN:-$repo_root/sqlcl/bin/sql}"
connection_name="${SQLCL_CONNECTION_NAME:-}"
target_app_id="${APEX_TARGET_APP_ID:-}"

if [[ "${DEPLOY_CONFIRM:-}" != "YES" ]]; then
  echo "Import annulé. Relancez avec DEPLOY_CONFIRM=YES après contrôle de la cible DEV." >&2
  exit 2
fi

if [[ -z "$connection_name" ]]; then
  echo "Définissez SQLCL_CONNECTION_NAME avec une connexion SQLcl locale nommée. Aucun secret ne doit être placé dans Git." >&2
  exit 1
fi

if [[ -z "$target_app_id" || ! "$target_app_id" =~ ^[0-9]+$ ]]; then
  echo "Définissez APEX_TARGET_APP_ID avec un nouvel ID numérique libre (différent de 102)." >&2
  exit 1
fi

if [[ ! -x "$sqlcl_bin" ]]; then
  sqlcl_bin="$(command -v sql || true)"
fi

if [[ -z "$sqlcl_bin" || ! -f "$apex_dir/application.apx" ]]; then
  echo "SQLcl ou baseline APEXlang indisponible." >&2
  exit 1
fi

echo "Cible SQLcl : $connection_name"
echo "Application cible : $target_app_id / TESTCL / DEMANDE-INTERNE-TESTCL"
echo "Source APEXlang : $apex_dir"
"$sqlcl_bin" -name "$connection_name" \
  -execute "show user" \
  -execute "apex import -input \"$apex_dir\" -id $target_app_id -schema TESTCL -name \"Demande Interne TESTCL\" -alias DEMANDE-INTERNE-TESTCL"
