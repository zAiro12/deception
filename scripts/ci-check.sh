#!/usr/bin/env bash
set -euo pipefail

echo "Running production build check..."
npm run build
echo "Check completed successfully."
