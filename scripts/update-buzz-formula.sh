#!/bin/bash
set -euo pipefail

# Get latest release from public buzz repo
LATEST=$(curl -s https://api.github.com/repos/PinePeakDigital/buzz/releases/latest | jq -r .tag_name)

# Get current version from formula
CURRENT=$(grep -oP 'url.*tags/\K[^/]+(?=\.tar\.gz)' Formula/buzz.rb || echo "none")

# Export values for GitHub Actions (if running in that environment)
if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "latest=$LATEST" >> "$GITHUB_OUTPUT"
fi

# Exit early if no update is needed
if [ "$LATEST" == "$CURRENT" ]; then
  echo "No update needed. Current version: $CURRENT, Latest version: $LATEST"
  if [ -n "${GITHUB_OUTPUT:-}" ]; then
    echo "updated=false" >> "$GITHUB_OUTPUT"
  fi
  exit 0
fi

# Mark as updated
if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "updated=true" >> "$GITHUB_OUTPUT"
fi

echo "Updating from $CURRENT to $LATEST"

# Calculate SHA256 for the new version
URL="https://github.com/PinePeakDigital/buzz/archive/refs/tags/${LATEST}.tar.gz"
SHA256=$(curl -sL "$URL" | shasum -a 256 | cut -d ' ' -f 1)

# Update the formula
cat > Formula/buzz.rb << EOF
class Buzz < Formula
  desc "Terminal user interface for Beeminder"
  homepage "https://github.com/PinePeakDigital/buzz"
  url "${URL}"
  sha256 "${SHA256}"
  license "MIT"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w")
  end

  test do
    assert_match "buzz", shell_output("#{bin}/buzz --help 2>&1", 1)
  end
end
EOF

echo "Formula updated successfully to version $LATEST"
