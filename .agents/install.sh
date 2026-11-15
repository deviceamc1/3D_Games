#!/usr/bin/env bash
set -euo pipefail

GODOT_VERSION="4.7.2-stable"
GODOT_BIN_NAME="Godot_v${GODOT_VERSION}_linux.x86_64"
GODOT_URL="https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}/${GODOT_BIN_NAME}.zip"
GODOT_DIR="$HOME/.local/opt/godot-4.7.2"

BLENDER_MAJOR_MINOR="5.3"
BLENDER_VERSION="5.3.0"
BLENDER_URL="https://download.blender.org/release/Blender${BLENDER_MAJOR_MINOR}/blender-${BLENDER_VERSION}-linux-x64.tar.xz"
BLENDER_DIR="$HOME/.local/opt/blender-${BLENDER_VERSION}"

mkdir -p "$HOME/.local/opt" "$HOME/.local/bin"

TMP_DIR="$(mktemp -d)"
cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

if [ ! -x "$GODOT_DIR/$GODOT_BIN_NAME" ]; then
  echo "Installing Godot ${GODOT_VERSION}..."
  curl -fsSL --retry 3 -o "$TMP_DIR/godot.zip" "$GODOT_URL"
  mkdir -p "$TMP_DIR/godot"
  unzip -oq "$TMP_DIR/godot.zip" -d "$TMP_DIR/godot"
  chmod +x "$TMP_DIR/godot/$GODOT_BIN_NAME"
  rm -rf "$GODOT_DIR"
  mv "$TMP_DIR/godot" "$GODOT_DIR"
fi

ln -sfn "$GODOT_DIR/$GODOT_BIN_NAME" "$HOME/.local/bin/godot"
ln -sfn "$GODOT_DIR/$GODOT_BIN_NAME" "$HOME/.local/bin/godot4"

if [ ! -x "$BLENDER_DIR/blender" ]; then
  echo "Installing Blender ${BLENDER_VERSION}..."
  curl -fsSL --retry 3 -o "$TMP_DIR/blender.tar.xz" "$BLENDER_URL"
  mkdir -p "$TMP_DIR/blender"
  tar -xJf "$TMP_DIR/blender.tar.xz" -C "$TMP_DIR/blender" --strip-components=1
  rm -rf "$BLENDER_DIR"
  mv "$TMP_DIR/blender" "$BLENDER_DIR"
fi

ln -sfn "$BLENDER_DIR/blender" "$HOME/.local/bin/blender"

touch "$HOME/.bashrc"
sed -i '/case \$- in/,/esac/d' "$HOME/.bashrc" 2>/dev/null || true
PATH_LINE='export PATH="$HOME/.local/bin:$PATH"'
grep -qxF "$PATH_LINE" "$HOME/.bashrc" || echo "$PATH_LINE" >> "$HOME/.bashrc"

export PATH="$HOME/.local/bin:$PATH"
godot --version
blender --version
