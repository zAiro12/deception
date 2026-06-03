#!/usr/bin/env bash
set -euo pipefail

echo "Running publish guard checks..."
npm ci
npm run ci:check
echo "Publish guard passed."
