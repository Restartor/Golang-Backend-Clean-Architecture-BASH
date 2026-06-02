#!/bin/bash

# ─────────────────────────────────────────────
#  install.sh — register go-clean-arch as a global command
#  Run once: bash install.sh
# ─────────────────────────────────────────────

SCRIPT_DIR="$HOME/.local/bin"
SCRIPT_NAME="go-clean-arch"
SCRIPT_SRC="$(cd "$(dirname "$0")" && pwd)/go-clean-arch.sh"

# 1. Make sure ~/.local/bin exists
mkdir -p "$SCRIPT_DIR"

# 2. Copy the script
cp "$SCRIPT_SRC" "$SCRIPT_DIR/$SCRIPT_NAME"
chmod +x "$SCRIPT_DIR/$SCRIPT_NAME"

# 3. Add ~/.local/bin to PATH if not already there
SHELL_RC=""
if [ -n "$ZSH_VERSION" ] || [ "$SHELL" = "/bin/zsh" ]; then
  SHELL_RC="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ] || [ "$SHELL" = "/bin/bash" ]; then
  SHELL_RC="$HOME/.bashrc"
fi

if [ -n "$SHELL_RC" ]; then
  if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$SHELL_RC" 2>/dev/null; then
    echo '' >> "$SHELL_RC"
    echo '# go-clean-arch and other local scripts' >> "$SHELL_RC"
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_RC"
    echo "✅  Added ~/.local/bin to PATH in $SHELL_RC"
  else
    echo "ℹ️   ~/.local/bin already in PATH"
  fi
fi

echo ""
echo "✅  Installed! Restart your terminal or run:"
echo "    source $SHELL_RC"
echo ""
echo "Then use:"
echo "    go-clean-arch <project-name> [module-path]"
echo "    go-clean-arch my-api github.com/rafi/my-api"
