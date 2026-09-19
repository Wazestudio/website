#!/usr/bin/env bash
# Installeur en une ligne pour VPS Control.
#
# Ce fichier est celui à héberger tel quel sur install.vpscontrol.wazestudio.com
# (simple fichier statique servi en texte brut — voir HOSTING.md dans ce même
# projet pour les instructions d'hébergement).
#
# Usage pour l'utilisateur final :
#   curl -fsSL https://install.vpscontrol.wazestudio.com | sudo bash
#
# Le script d'installation (scripts/install.sh, dans le dépôt du panel) pose
# ensuite ses propres questions : domaine ou IP pour l'accès HTTPS, et
# activation des mises à jour automatiques. Pour une installation entièrement
# non interactive, tout est aussi pilotable par variables d'environnement :
#   curl -fsSL https://install.vpscontrol.wazestudio.com \
#     | sudo VPSCONTROL_DOMAIN=panel.mondomaine.com VPSCONTROL_AUTO_UPDATE=yes bash
set -euo pipefail

REPO_URL="${VPSCONTROL_REPO_URL:-https://github.com/VPSControl/vps-control.git}"
BRANCH="${VPSCONTROL_BRANCH:-main}"

if [ "$(id -u)" -ne 0 ]; then
  echo "Cette installation doit être lancée en root, par exemple :" >&2
  echo "  curl -fsSL https://install.vpscontrol.wazestudio.com | sudo bash" >&2
  exit 1
fi

echo "=================================================================="
echo " VPS Control — installation"
echo "=================================================================="

if ! command -v git >/dev/null 2>&1; then
  echo "==> Installation de git..."
  apt-get update -y
  apt-get install -y git ca-certificates curl
fi

CLONE_DIR="/opt/vpscontrol-src"
if [ -d "$CLONE_DIR/.git" ]; then
  echo "==> Mise à jour du code source existant dans $CLONE_DIR..."
  git -C "$CLONE_DIR" fetch --depth 1 origin "$BRANCH"
  git -C "$CLONE_DIR" checkout "$BRANCH"
  git -C "$CLONE_DIR" reset --hard "origin/$BRANCH"
else
  echo "==> Récupération du code source dans $CLONE_DIR..."
  rm -rf "$CLONE_DIR"
  git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$CLONE_DIR"
fi

cd "$CLONE_DIR"
exec bash scripts/install.sh
