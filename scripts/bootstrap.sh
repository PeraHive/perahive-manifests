#!/usr/bin/env bash
set -euo pipefail

# Workspace root (change if you prefer)
ROOT="${HOME}/perahive"
WS="${ROOT}/ws"
SRC="${WS}/src"
MANIFESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/manifests"

# Choose project (first arg), e.g. ./scripts/bootstrap.sh falcon
PROJECT="${1:-}"
if [[ -z "${PROJECT}" ]]; then
  echo "Usage: $0 <project-name>"
  echo "Example: $0 falcon"
  exit 1
fi

mkdir -p "${SRC}"

# Always import core first
vcs import "${SRC}" < "${MANIFESTS_DIR}/perahive-core.repos"

# Then import the selected project
PROJ_FILE="${MANIFESTS_DIR}/project-${PROJECT}.repos"
if [[ ! -f "${PROJ_FILE}" ]]; then
  echo "Project manifest not found: ${PROJ_FILE}"
  echo "Available:"
  ls -1 ${MANIFESTS_DIR}/project-*.repos || true
  exit 1
fi
vcs import "${SRC}" < "${PROJ_FILE}"

echo ">> Updating repos (pull)…"
vcs pull "${SRC}"

echo ">> Exporting current manifests (human-readable & exact SHAs)…"
mkdir -p "${MANIFESTS_DIR}/locks"
vcs export "${SRC}" > "${MANIFESTS_DIR}/locks/${PROJECT}.current.repos"
vcs export --exact "${SRC}" > "${MANIFESTS_DIR}/locks/${PROJECT}.lock.repos"

echo ">> Done. Your workspace is at: ${WS}"
echo "To build (ROS/colcon example):"
echo "  cd ${WS} && colcon build"
