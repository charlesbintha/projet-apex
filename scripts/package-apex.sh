#!/usr/bin/env bash
set -euo pipefail

repo_root="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
apex_dir="$repo_root/apex"
dist_dir="$repo_root/dist"
package="$dist_dir/demande-interne-testcl.zip"

if [[ ! -f "$apex_dir/application.apx" ]]; then
  echo "Baseline APEXlang absente : $apex_dir/application.apx" >&2
  exit 1
fi

"$repo_root/scripts/validate.sh"
mkdir -p "$dist_dir"

files=(.apex application.apx deployments page-groups.apx pages shared-components)
if [[ -d "$apex_dir/supporting-objects" ]]; then
  files+=(supporting-objects)
fi

(
  cd "$apex_dir"
  zip -q -FS -r "$package" "${files[@]}" \
    -x '*/.gitkeep' 'deployments/source-app-102.json'
)

echo "Package APEXlang prêt : $package"
