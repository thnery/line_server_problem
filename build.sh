#!/usr/bin/env bash

# build.sh - Automated bundle install script with error handling

set -euo pipefail # Enable strict mode

# Configuration
RUBY_VERSION="3.1.2"                                  # Set your required Ruby version
BUNDLE_ARGS="--jobs=4 --retry=3 --path=vendor/bundle" # Optimized bundle settings

# Check for required commands
for cmd in ruby bundle; do
  if ! command -v $cmd &>/dev/null; then
    echo "Error: $cmd not found. Please install it first."
    exit 1
  fi
done

# Run bundle install with progress
echo "Installing dependencies..."
if bundle install $BUNDLE_ARGS; then
  echo -e "\n Bundle installed successfully"
  bundle list | head -n 10 # Show first 10 gems as verification
else
  echo -e "\n Bundle install failed"
  exit 1
fi
