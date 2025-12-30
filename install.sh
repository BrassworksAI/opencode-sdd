#!/bin/sh
set -e

# OpenCode SDD Installer (macOS/Linux)
# Downloads and installs the Spec-Driven Development process for OpenCode

REPO_OWNER="BrassworksAI"
REPO_NAME="opencode-sdd"
BRANCH="main"
ARCHIVE_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/archive/refs/heads/${BRANCH}.tar.gz"

# Colors (if terminal supports them)
if [ -t 1 ]; then
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[0;33m'
  BLUE='\033[0;34m'
  NC='\033[0m' # No Color
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

# Cleanup on exit
cleanup() {
  if [ -n "$TMP_DIR" ] && [ -d "$TMP_DIR" ]; then
    rm -rf "$TMP_DIR"
  fi
}
trap cleanup EXIT

# Find git root by walking up directories (no git required)
find_git_root() {
  dir="$PWD"
  while [ "$dir" != "/" ]; do
    if [ -d "$dir/.git" ] || [ -f "$dir/.git" ]; then
      echo "$dir"
      return 0
    fi
    dir="$(dirname "$dir")"
  done
  return 1
}

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
  echo "  OpenCode SDD Installer"
  echo "  ======================"
  echo ""

  # Choose install mode
  echo "Where would you like to install?"
  echo "  1) Global (~/.config/opencode)"
  echo "  2) Local (current repo's .opencode folder)"
  echo ""
  printf "Enter choice [1/2]: "
  read -r choice

  case "$choice" in
    1)
      INSTALL_MODE="global"
      TARGET_ROOT="$HOME/.config/opencode"
      ;;
    2)
      INSTALL_MODE="local"
      GIT_ROOT="$(find_git_root)" || error "Not inside a git repository. Cannot determine repo root for local install."
      TARGET_ROOT="$GIT_ROOT/.opencode"
      ;;
    *)
      error "Invalid choice. Please enter 1 or 2."
      ;;
  esac

  info "Install mode: $INSTALL_MODE"
  info "Target: $TARGET_ROOT"
  echo ""

  # Create temp directory
  TMP_DIR="$(mktemp -d)"
  info "Downloading archive..."

  # Download and extract
  curl -fsSL "$ARCHIVE_URL" -o "$TMP_DIR/repo.tar.gz" || error "Failed to download archive"
  tar -xzf "$TMP_DIR/repo.tar.gz" -C "$TMP_DIR" || error "Failed to extract archive"

  # Find extracted directory (GitHub names it <repo>-<branch>)
  EXTRACTED_DIR="$TMP_DIR/${REPO_NAME}-${BRANCH}"
  PAYLOAD_DIR="$EXTRACTED_DIR/opencode"

  if [ ! -d "$PAYLOAD_DIR" ]; then
    error "Payload directory 'opencode/' not found in archive"
  fi

  success "Downloaded and extracted"

  # Build file list and detect conflicts
  info "Scanning for conflicts..."
  CONFLICTS=""
  CONFLICT_COUNT=0

  # Use find to get all files in payload
  cd "$PAYLOAD_DIR"
  FILES="$(find . -type f | sed 's|^\./||')"
  cd - > /dev/null

  for file in $FILES; do
    dest="$TARGET_ROOT/$file"
    if [ -f "$dest" ]; then
      CONFLICTS="$CONFLICTS$file\n"
      CONFLICT_COUNT=$((CONFLICT_COUNT + 1))
    fi
  done

  # Handle conflicts
  if [ $CONFLICT_COUNT -gt 0 ]; then
    echo ""
    warn "Found $CONFLICT_COUNT conflicting file(s) that would be overwritten:"
    echo ""
    printf "$CONFLICTS" | head -20
    if [ $CONFLICT_COUNT -gt 20 ]; then
      echo "  ... and $((CONFLICT_COUNT - 20)) more"
    fi
    echo ""
    warn "Back up any files you want to keep before proceeding."
    echo ""
    if ! confirm "Overwrite ALL conflicting files?"; then
      error "Installation aborted by user"
    fi
    echo ""
  else
    success "No conflicts detected"
  fi

  # Copy files
  info "Installing files..."

  for file in $FILES; do
    src="$PAYLOAD_DIR/$file"
    dest="$TARGET_ROOT/$file"
    dest_dir="$(dirname "$dest")"

    # Create parent directories if needed
    if [ ! -d "$dest_dir" ]; then
      mkdir -p "$dest_dir"
    fi

    cp "$src" "$dest" || error "Failed to copy $file"
  done

  echo ""
  success "Installation complete!"
  echo ""
  info "Installed to: $TARGET_ROOT"
  echo ""

  if [ "$INSTALL_MODE" = "global" ]; then
    echo "SDD commands are now available globally in OpenCode."
  else
    echo "SDD commands are now available for this repository."
  fi
  echo ""
}

main "$@"
