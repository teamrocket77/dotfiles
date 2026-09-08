#!/usr/bin/env bash
# Pull only the CRD schemas your manifests actually use from datreeio/CRDs-catalog
# into a local, offline cache that lua/plugins/yaml-crds.lua resolves against.
#
# Scans the given paths (default: cwd) for every apiVersion/kind, then downloads
# the matching <group>/<kind>_<version>.json from the catalog. Core kinds (v1,
# apps/v1, ...) aren't in the catalog and 404 out harmlessly.
#
#   ./gen-crd-schemas.sh                    # scan cwd
#   ./gen-crd-schemas.sh ~/code/k8s .       # scan multiple trees
#   SCHEMA_CACHE_DIR=/tmp/crds ./gen-crd-schemas.sh ~/code/k8s
set -euo pipefail

# Matches nvim's stdpath("cache")/yaml-crds — regenerable data, not in the repo.
CACHE_DIR="${SCHEMA_CACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/nvim/yaml-crds}"
CATALOG="https://raw.githubusercontent.com/datreeio/CRDs-catalog/main"

command -v yq >/dev/null || { echo "yq (mikefarah v4) is required" >&2; exit 1; }

mkdir -p "$CACHE_DIR"
scan=("$@"); [[ ${#scan[@]} -eq 0 ]] && scan=(".")

# Unique "apiVersion kind" across every doc in every yaml (multi-doc safe; a
# single malformed file is skipped, not fatal).
gvks="$(
	while IFS= read -r -d '' f; do
		yq ea 'select(.apiVersion != null and .kind != null)
		       | .apiVersion + " " + .kind' "$f" 2>/dev/null
	done < <(find "${scan[@]}" -type f \( -name '*.yaml' -o -name '*.yml' \) -print0) \
	| sort -u
)"

found=0 missing=0
while read -r apiVersion kind; do
	[[ -z "$apiVersion" ]] && continue
	[[ "$apiVersion" != */* ]] && continue          # core group (e.g. v1): not a CRD

	group="${apiVersion%/*}"
	version="${apiVersion##*/}"
	rel="${group}/${kind,,}_${version}.json"        # ${kind,,} = lowercase
	dest="$CACHE_DIR/$rel"

	[[ -f "$dest" ]] && { echo "· cached  $rel"; continue; }
	mkdir -p "$(dirname "$dest")"
	if curl -fsSL "$CATALOG/$rel" -o "$dest"; then
		echo "✓ pulled $rel"; found=$((found + 1))
	else
		rm -f "$dest"
		echo "✗ absent $rel"; missing=$((missing + 1))
	fi
done <<< "$gvks"

echo "---"
echo "cache:  $CACHE_DIR"
echo "pulled $found, not-in-catalog $missing"
