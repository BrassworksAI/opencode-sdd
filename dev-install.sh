#!/bin/sh
set -e

# OpenCode SDD Dev Install (macOS/Linux only)
# Creates symlinks from ~/.config/opencode to the local repo's opencode/ folder
# This allows you to edit files and push changes back to the repo

# Colors (if terminal supports them)
if [ -t 1 ]; then
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[0;33m'
  BLUE='\033[0;34m'
  NC='\033[0m'
else
  RED=''
  GREEN=''
  YELLOW=''
  BLUE=''
  NC=''
fi

info() { printf "${BLUE}[INFO]${NC} %s\n" "$1"; }
success() { printf "${GREEN}[OK]${NC} %s\n" "$1"; }
warn() { printf "${YELLOW}[WARN]${NC} %s\n" "$1"; }
error() { printf "${RED}[ERROR]${NC} %s\n" "$1"; exit 1; }

# Prompt for yes/no
confirm() {
  printf "%s [y/N] " "$1"
  read -r answer
  case "$answer" in
    [Yy]|[Yy][Ee][Ss]) return 0 ;;
    *) return 1 ;;
  esac
}

# Main
main() {
  echo ""
  echo "  OpenCode SDD Dev Install (Symlink Mode)"
  echo "  ========================================"
  echo ""

  # Determine script location to find repo root
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
  PAYLOAD_DIR="$SCRIPT_DIR/opencode"

  if [ ! -d "$PAYLOAD_DIR" ]; then
    error "Cannot find 'opencode/' directory at $SCRIPT_DIR"
  fi

  TARGET_ROOT="$HOME/.config/opencode"

  info "Source: $PAYLOAD_DIR"
  info "Target: $TARGET_ROOT (symlinks)"
  echo ""

  # Build file list and detect conflicts
  info "Scanning for conflicts..."
  CONFLICTS=""
  CONFLICT_COUNT=0

  cd "$PAYLOAD_DIR"
  FILES="$(find . -type f | sed 's|^\./||')"
  cd - > /dev/null

  for file in $FILES; do
    dest="$TARGET_ROOT/$file"
    if [ -e "$dest" ] || [ -L "$dest" ]; then
      # Check if it's already a symlink to our source
      src="$PAYLOAD_DIR/$file"
      if [ -L "$dest" ]; then
        existing_target="$(readlink "$dest")"
        if [ "$existing_target" = "$src" ]; then
          # Already linked to us, not a conflict
          continue
        fi
      fi
      CONFLICTS="$CONFLICTS$file\n"
      CONFLICT_COUNT=$((CONFLICT_COUNT + 1))
    fi
  done

  # Handle conflicts
  if [ $CONFLICT_COUNT -gt 0 ]; then
    echo ""
    warn "Found $CONFLICT_COUNT conflicting file(s)/symlink(s):"
    echo ""
    printf "$CONFLICTS" | head -20
    if [ $CONFLICT_COUNT -gt 20 ]; then
      echo "  ... and $((CONFLICT_COUNT - 20)) more"
    fi
    echo ""
    warn "These will be replaced with symlinks to the repo."
    echo ""
    if ! confirm "Replace ALL conflicting files with symlinks?"; then
      error "Installation aborted by user"
    fi
    echo ""
  else
    success "No conflicts detected"
  fi

  # Create symlinks
  info "Creating symlinks..."

  for file in $FILES; do
    src="$PAYLOAD_DIR/$file"
    dest="$TARGET_ROOT/$file"
    dest_dir="$(dirname "$dest")"

    # Create parent directories if needed
    if [ ! -d "$dest_dir" ]; then
      mkdir -p "$dest_dir"
    fi

    # Remove existing file/symlink if present
    if [ -e "$dest" ] || [ -L "$dest" ]; then
      rm "$dest"
    fi

    # Create symlink
    ln -s "$src" "$dest" || error "Failed to create symlink for $file"
  done

  echo ""
  success "Dev install complete!"
  echo ""
  info "Symlinks created at: $TARGET_ROOT"
  info "Source files at: $PAYLOAD_DIR"
  echo ""
  echo "Any edits you make in ~/.config/opencode will modify the repo files."
  echo "You can commit and push changes directly."
  echo ""
}

main "$@"
