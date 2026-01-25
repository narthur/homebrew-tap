#!/bin/bash
set -euo pipefail

git config user.name "github-actions[bot]"
git config user.email "github-actions[bot]@users.noreply.github.com"
git add Formula/*.rb

# Build commit message from updated formulas (values passed via environment)
FORMULAS="${FORMULAS:-}"
VERSIONS="${VERSIONS:-}"

# Parse comma-separated values and build commit message
if [ -n "$FORMULAS" ] && [ -n "$VERSIONS" ]; then
# Convert to arrays (handle spaces in GitHub Actions)
OLD_IFS="$IFS"
IFS=',' read -ra FORMULA_ARRAY <<< "$FORMULAS"
IFS=',' read -ra VERSION_ARRAY <<< "$VERSIONS"
IFS="$OLD_IFS"

# Build commit message
COMMIT_PARTS=()
for i in "${!FORMULA_ARRAY[@]}"; do
    FORMULA="${FORMULA_ARRAY[$i]}"
    VERSION="${VERSION_ARRAY[$i]}"
    # Extract version from "formula=version" format
    VERSION_ONLY="${VERSION#*=}"
    COMMIT_PARTS+=("${FORMULA} ${VERSION_ONLY}")
done

if [ ${#COMMIT_PARTS[@]} -eq 1 ]; then
    COMMIT_MSG="${COMMIT_PARTS[0]}"
else
    COMMIT_MSG="Update formulas: $(IFS=', '; echo "${COMMIT_PARTS[*]}")"
fi
else
# Fallback if parsing fails
COMMIT_MSG="Update formulas"
fi

git diff --cached --quiet || git commit -m "$COMMIT_MSG"
git push
