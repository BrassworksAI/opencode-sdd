#!/bin/sh
set -e

# Agent Extensions Installer (macOS/Linux)
# Downloads and installs the Spec-Driven Development process for OpenCode and/or Augment

REPO_OWNER="BrassworksAI"
REPO_NAME="agent-extensions"
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

# Install files from payload to target
# Arguments: $1 = payload dir, $2 = target root, $3 = label
install_files() {
  PAYLOAD_DIR="$1"
  TARGET_ROOT="$2"
  LABEL="$3"

  if [ ! -d "$PAYLOAD_DIR" ]; then
    warn "Payload directory '$PAYLOAD_DIR' not found, skipping $LABEL"
    return 1
  fi

  info "Installing $LABEL to: $TARGET_ROOT"

  # Build file list and detect conflicts
  CONFLICTS=""
  CONFLICT_COUNT=0

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
    warn "Found $CONFLICT_COUNT conflicting file(s) for $LABEL:"
    echo ""
    printf "$CONFLICTS" | head -20
    if [ $CONFLICT_COUNT -gt 20 ]; then
      echo "  ... and $((CONFLICT_COUNT - 20)) more"
    fi
    echo ""
    if ! confirm "Overwrite conflicting files for $LABEL?"; then
      warn "Skipping $LABEL install"
      return 1
    fi
    echo ""
  fi

  # Copy files
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

  success "Installed $LABEL to: $TARGET_ROOT"
  return 0
}

# Main
main() {
  echo ""
  echo "  Agent Extensions Installer"
  echo "  ==========================="
  echo ""

  # Choose tool
  echo "Which tool(s) would you like to install extensions for?"
  echo "  1) OpenCode"
  echo "  2) Augment (Auggie)"
  echo "  3) Both"
  echo ""
  printf "Enter choice [1/2/3]: "
  read -r tool_choice

  INSTALL_OPENCODE=""
  INSTALL_AUGMENT=""

  case "$tool_choice" in
    1)
      INSTALL_OPENCODE="yes"
      ;;
    2)
      INSTALL_AUGMENT="yes"
      ;;
    3)
      INSTALL_OPENCODE="yes"
      INSTALL_AUGMENT="yes"
      ;;
    *)
      error "Invalid choice. Please enter 1, 2, or 3."
      ;;
  esac

  # Choose install mode
  echo ""
  echo "Where would you like to install?"
  echo "  1) Global (user config directory)"
  echo "  2) Local (current repo)"
  echo ""
  printf "Enter choice [1/2]: "
  read -r scope_choice

  case "$scope_choice" in
    1)
      INSTALL_MODE="global"
      ;;
    2)
      INSTALL_MODE="local"
      GIT_ROOT="$(find_git_root)" || error "Not inside a git repository. Cannot determine repo root for local install."
      ;;
    *)
      error "Invalid choice. Please enter 1 or 2."
      ;;
  esac

  # Set target directories based on choices
  if [ "$INSTALL_MODE" = "global" ]; then
    OPENCODE_TARGET="$HOME/.config/opencode"
    AUGMENT_TARGET="$HOME/.augment"
  else
    OPENCODE_TARGET="$GIT_ROOT/.opencode"
    AUGMENT_TARGET="$GIT_ROOT/.augment"
  fi

  echo ""
  info "Install mode: $INSTALL_MODE"
  [ -n "$INSTALL_OPENCODE" ] && info "OpenCode target: $OPENCODE_TARGET"
  [ -n "$INSTALL_AUGMENT" ] && info "Augment target: $AUGMENT_TARGET"
  echo ""

  # Create temp directory
  TMP_DIR="$(mktemp -d)"
  info "Downloading archive..."

  # Download and extract
  curl -fsSL "$ARCHIVE_URL" -o "$TMP_DIR/repo.tar.gz" || error "Failed to download archive"
  tar -xzf "$TMP_DIR/repo.tar.gz" -C "$TMP_DIR" || error "Failed to extract archive"

  # Find extracted directory (GitHub names it <repo>-<branch>)
  EXTRACTED_DIR="$TMP_DIR/${REPO_NAME}-${BRANCH}"

  success "Downloaded and extracted"
  echo ""

  INSTALLED_COUNT=0

  # Install OpenCode if requested
  if [ -n "$INSTALL_OPENCODE" ]; then
    OPENCODE_PAYLOAD="$EXTRACTED_DIR/opencode"
    if install_files "$OPENCODE_PAYLOAD" "$OPENCODE_TARGET" "OpenCode"; then
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    fi
    echo ""
  fi

  # Install Augment if requested
  if [ -n "$INSTALL_AUGMENT" ]; then
    AUGMENT_PAYLOAD="$EXTRACTED_DIR/augment"
    if install_files "$AUGMENT_PAYLOAD" "$AUGMENT_TARGET" "Augment"; then
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    fi
    echo ""
  fi

  if [ $INSTALLED_COUNT -eq 0 ]; then
    error "No installations completed"
  fi

  success "Installation complete!"
  echo ""

  if [ "$INSTALL_MODE" = "global" ]; then
    echo "SDD commands are now available globally."
  else
    echo "SDD commands are now available for this repository."
  fi
  echo ""
}

main "$@"
