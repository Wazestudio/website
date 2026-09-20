#!/usr/bin/env bash
# One-line installer for VPS Control.
#
# This is the exact file to host on install.vpscontrol.wazestudio.com
# (a plain static file served as text — see HOSTING.md in this same repo
# for hosting instructions).
#
# Usage for the end user:
#   curl -fsSL https://install.vpscontrol.wazestudio.com | sudo bash
#
# The install script (scripts/install.sh, in the panel's repo) then asks
# its own questions: domain or IP for HTTPS access, and whether to enable
# automatic updates. For a fully non-interactive install, everything can
# also be driven through environment variables:
#   curl -fsSL https://install.vpscontrol.wazestudio.com \
#     | sudo VPSCONTROL_DOMAIN=panel.example.com VPSCONTROL_AUTO_UPDATE=yes bash
set -euo pipefail

REPO_URL="${VPSCONTROL_REPO_URL:-https://github.com/VPSControl/vps-control.git}"
BRANCH="${VPSCONTROL_BRANCH:-main}"

if [ "$(id -u)" -ne 0 ]; then
  echo "This installation must be run as root, for example:" >&2
  echo "  curl -fsSL https://install.vpscontrol.wazestudio.com | sudo bash" >&2
  exit 1
fi

echo "=================================================================="
echo " VPS Control — installation"
echo "=================================================================="

if ! command -v git >/dev/null 2>&1; then
  echo "==> Installing git..."
  apt-get update -y
  apt-get install -y git ca-certificates curl
fi

CLONE_DIR="/opt/vpscontrol-src"
if [ -d "$CLONE_DIR/.git" ]; then
  echo "==> Updating the existing source code in $CLONE_DIR..."
  git -C "$CLONE_DIR" fetch --depth 1 origin "$BRANCH"
  git -C "$CLONE_DIR" checkout "$BRANCH"
  git -C "$CLONE_DIR" reset --hard "origin/$BRANCH"
else
  echo "==> Fetching the source code into $CLONE_DIR..."
  rm -rf "$CLONE_DIR"
  git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$CLONE_DIR"
fi

cd "$CLONE_DIR"
exec bash scripts/install.sh
