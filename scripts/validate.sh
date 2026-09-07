#!/usr/bin/env bash
set -euo pipefail

repo_root="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
apex_dir="${1:-$repo_root/apex}"
sqlcl_bin="${SQLCL_BIN:-$repo_root/sqlcl/bin/sql}"

if [[ ! -x "$sqlcl_bin" ]]; then
  sqlcl_bin="$(command -v sql || true)"
fi

if [[ -z "$sqlcl_bin" ]]; then
  echo "SQLcl introuvable. Définissez SQLCL_BIN ou installez sql dans PATH." >&2
  exit 1
fi

if [[ ! -f "$apex_dir/application.apx" ]]; then
  echo "Baseline APEXlang absente : $apex_dir/application.apx" >&2
  exit 1
fi

"$sqlcl_bin" /nolog -execute "apex validate -input \"$apex_dir\""
