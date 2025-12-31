#!/bin/sh
set -e

# OpenCode SDD Uninstaller (macOS/Linux)
# Removes the Spec-Driven Development process for OpenCode

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

# Find git root by walking up directories
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

# Remove SDD files from a target directory
remove_sdd_files() {
  target="$1"
  removed=0

  # SDD agent directories and files
  for path in \
    "$target/agent/sdd" \
    "$target/agent/search" \
    "$target/agent/librarian.md" \
    "$target/agent/archimedes.md" \
    "$target/command/sdd" \
    "$target/skill/sdd-delta-format" \
    "$target/skill/sdd-loop-ledger-format" \
    "$target/skill/sdd-plan-format" \
    "$target/skill/sdd-quick-task-format" \
    "$target/skill/sdd-task-format"
  do
    if [ -e "$path" ] || [ -L "$path" ]; then
      rm -rf "$path"
      removed=$((removed + 1))
    fi
  done

  echo "$removed"
}

# Main
main() {
  echo ""
  echo "  OpenCode SDD Uninstaller"
  echo "  ========================"
  echo ""

  # Check what installations exist
  GLOBAL_ROOT="$HOME/.config/opencode"
  LOCAL_ROOT=""
  
  if GIT_ROOT="$(find_git_root 2>/dev/null)"; then
    LOCAL_ROOT="$GIT_ROOT/.opencode"
  fi

  GLOBAL_EXISTS=false
  LOCAL_EXISTS=false

  if [ -d "$GLOBAL_ROOT/agent/sdd" ] || [ -d "$GLOBAL_ROOT/command/sdd" ]; then
    GLOBAL_EXISTS=true
  fi

  if [ -n "$LOCAL_ROOT" ] && { [ -d "$LOCAL_ROOT/agent/sdd" ] || [ -d "$LOCAL_ROOT/command/sdd" ]; }; then
    LOCAL_EXISTS=true
  fi

  if [ "$GLOBAL_EXISTS" = false ] && [ "$LOCAL_EXISTS" = false ]; then
    echo "No SDD installation found."
    echo ""
    echo "Checked:"
    echo "  - Global: $GLOBAL_ROOT"
    if [ -n "$LOCAL_ROOT" ]; then
      echo "  - Local:  $LOCAL_ROOT"
    else
      echo "  - Local:  (not in a git repository)"
    fi
    echo ""
    exit 0
  fi

  echo "Found SDD installation(s):"
  echo ""
  if [ "$GLOBAL_EXISTS" = true ]; then
    echo "  1) Global ($GLOBAL_ROOT)"
  fi
  if [ "$LOCAL_EXISTS" = true ]; then
    echo "  2) Local ($LOCAL_ROOT)"
  fi
  echo ""

  # Determine what to uninstall
  if [ "$GLOBAL_EXISTS" = true ] && [ "$LOCAL_EXISTS" = true ]; then
    echo "What would you like to uninstall?"
    echo "  1) Global only"
    echo "  2) Local only"
    echo "  3) Both"
    echo ""
    printf "Enter choice [1/2/3]: "
    read -r choice
    case "$choice" in
      1) UNINSTALL_GLOBAL=true; UNINSTALL_LOCAL=false ;;
      2) UNINSTALL_GLOBAL=false; UNINSTALL_LOCAL=true ;;
      3) UNINSTALL_GLOBAL=true; UNINSTALL_LOCAL=true ;;
      *) error "Invalid choice" ;;
    esac
  elif [ "$GLOBAL_EXISTS" = true ]; then
    UNINSTALL_GLOBAL=true
    UNINSTALL_LOCAL=false
  else
    UNINSTALL_GLOBAL=false
    UNINSTALL_LOCAL=true
  fi

  echo ""
  warn "This will remove SDD agents, commands, and skills."
  warn "Your project files (changes/, docs/specs/, etc.) will NOT be affected."
  echo ""

  if ! confirm "Proceed with uninstall?"; then
    echo "Aborted."
    exit 0
  fi

  echo ""

  # Perform uninstall
  if [ "$UNINSTALL_GLOBAL" = true ]; then
    info "Removing global installation..."
    count=$(remove_sdd_files "$GLOBAL_ROOT")
    success "Removed $count items from $GLOBAL_ROOT"
  fi

  if [ "$UNINSTALL_LOCAL" = true ]; then
    info "Removing local installation..."
    count=$(remove_sdd_files "$LOCAL_ROOT")
    success "Removed $count items from $LOCAL_ROOT"
  fi

  echo ""
  success "SDD uninstalled successfully!"
  echo ""
}

main "$@"
