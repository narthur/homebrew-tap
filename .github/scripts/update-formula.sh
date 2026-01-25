#!/bin/bash
set -euo pipefail

FORMULA_DIR="Formula"
UPDATED_FORMULAS=()
LATEST_VERSIONS=()

# Function to extract GitHub URL from formula file
extract_github_url() {
  local formula_file="$1"
  # Extract homepage URL, handling both quoted formats
  grep -oP 'homepage\s+"\K[^"]+' "$formula_file" | head -1 || echo ""
}

# Function to update a single formula
update_formula() {
  local formula_file="$1"
  local formula_name=$(basename "$formula_file" .rb)
  
  echo "Processing $formula_file..."
  
  # Extract GitHub URL from homepage
  local homepage_url=$(extract_github_url "$formula_file")
  
  if [ -z "$homepage_url" ]; then
    echo "  Warning: Could not extract homepage URL from $formula_file, skipping..."
    return 1
  fi
  
  # Extract repo URL (handle both github.com URLs and other formats)
  local repo_url=""
  if [[ "$homepage_url" =~ ^https://github.com/ ]]; then
    repo_url="$homepage_url"
  else
    echo "  Warning: Homepage URL is not a GitHub URL: $homepage_url, skipping..."
    return 1
  fi
  
  # Build GitHub API URL for latest release
  local owner=""
  local repo=""
  if [[ "$repo_url" =~ ^https://github\.com/([^/]+)/([^/]+) ]]; then
    owner="${BASH_REMATCH[1]}"
    repo="${BASH_REMATCH[2]}"
  else
    echo "  Warning: Could not parse GitHub owner/repo from URL: $repo_url, skipping..."
    return 1
  fi
  local api_url="https://api.github.com/repos/${owner}/${repo}/releases/latest"
  
  # Get latest release tag
  local latest=$(curl -s "$api_url" | jq -r .tag_name 2>/dev/null || echo "")
  
  if [ -z "$latest" ] || [ "$latest" == "null" ]; then
    echo "  Warning: Could not fetch latest release for $repo_url, skipping..."
    return 1
  fi
  
  # Get current version from formula
  local current=$(grep -oP 'url.*tags/\K[^/]+(?=\.tar\.gz)' "$formula_file" || echo "none")
  
  # Exit early if no update is needed
  if [ "$latest" == "$current" ]; then
    echo "  No update needed. Current version: $current, Latest version: $latest"
    return 0
  fi
  
  echo "  Updating from $current to $latest"
  
  # Calculate SHA256 for the new version
  local archive_url="${repo_url}/archive/refs/tags/${latest}.tar.gz"
  local sha256=$(curl -sL "$archive_url" | shasum -a 256 | cut -d ' ' -f 1)
  
  if [ -z "$sha256" ]; then
    echo "  Error: Could not calculate SHA256 for $archive_url"
    return 1
  fi
  
  # Update the formula file using sed to preserve structure
  # Update the url line
  sed -i.bak "s|url \".*\"|url \"$archive_url\"|" "$formula_file"
  # Update the sha256 line
  sed -i.bak "s|sha256 \".*\"|sha256 \"$sha256\"|" "$formula_file"
  # Remove backup file
  rm -f "${formula_file}.bak"
  
  echo "  Formula updated successfully to version $latest"
  UPDATED_FORMULAS+=("$formula_name")
  LATEST_VERSIONS+=("$formula_name=$latest")
  return 0
}

# Main loop: process all .rb files in Formula directory
if [ ! -d "$FORMULA_DIR" ]; then
  echo "Error: Formula directory not found: $FORMULA_DIR"
  exit 1
fi

any_updated=false
for formula_file in "$FORMULA_DIR"/*.rb; do
  if [ -f "$formula_file" ]; then
    update_formula "$formula_file"
    echo ""
  fi
done

# Check if any formulas were updated
if [ ${#UPDATED_FORMULAS[@]} -gt 0 ]; then
  any_updated=true
fi

# Export values for GitHub Actions (if running in that environment)
if [ -n "${GITHUB_OUTPUT:-}" ]; then
  if [ "$any_updated" = true ]; then
    echo "updated=true" >> "$GITHUB_OUTPUT"
    # Export comma-separated list of updated formulas
    OLD_IFS="$IFS"
    IFS=','
    echo "formulas=${UPDATED_FORMULAS[*]}" >> "$GITHUB_OUTPUT"
    echo "versions=${LATEST_VERSIONS[*]}" >> "$GITHUB_OUTPUT"
    IFS="$OLD_IFS"
  else
    echo "updated=false" >> "$GITHUB_OUTPUT"
    echo "formulas=" >> "$GITHUB_OUTPUT"
    echo "versions=" >> "$GITHUB_OUTPUT"
  fi
fi

if [ "$any_updated" = true ]; then
  echo "Summary: Updated ${#UPDATED_FORMULAS[@]} formula(s): ${UPDATED_FORMULAS[*]}"
  exit 0
else
  echo "Summary: No formulas needed updates"
  exit 0
fi
