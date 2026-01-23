#!/bin/sh
set -e

# Agent Extensions Install (macOS/Linux)
# Creates global installs and local copies of the repo's folders
# Codex global uses copies (no symlinks). Local installs are not supported for Codex.

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

# Get template variables for a given tool and mode
# Sets: SKILL_INSTALL_PATH, SKILL_LOCAL_PATH, SKILL_GLOBAL_PATH
set_template_vars() {
  TOOL="$1"
  MODE="$2"

  case "$TOOL:$MODE" in
    opencode:global)
      SKILL_INSTALL_PATH='$HOME/.config/opencode/skill'
      SKILL_LOCAL_PATH='.opencode/skill'
      SKILL_GLOBAL_PATH='~/.config/opencode/skill'
      ;;
    opencode:local)
      SKILL_INSTALL_PATH='./.opencode/skill'
      SKILL_LOCAL_PATH='.opencode/skill'
      SKILL_GLOBAL_PATH='~/.config/opencode/skill'
      ;;
    codex:global)
      SKILL_INSTALL_PATH='$HOME/.codex/skills'
      SKILL_LOCAL_PATH='.codex/skills'
      SKILL_GLOBAL_PATH='~/.codex/skills'
      ;;
    codex:local)
      SKILL_INSTALL_PATH='./.codex/skills'
      SKILL_LOCAL_PATH='.codex/skills'
      SKILL_GLOBAL_PATH='~/.codex/skills'
      ;;
    *)
      error "Unknown tool/mode combination: $TOOL:$MODE"
      ;;
  esac
}

# Render a single .tmpl.md file to a destination
# Arguments: $1 = source file, $2 = destination file
render_template() {
  SRC_FILE="$1"
  DEST_FILE="$2"

  DEST_DIR="$(dirname "$DEST_FILE")"
  if [ ! -d "$DEST_DIR" ]; then
    mkdir -p "$DEST_DIR"
  fi

  sed -e "s|{{{SKILL_INSTALL_PATH}}}|$SKILL_INSTALL_PATH|g" \
      -e "s|{{{SKILL_LOCAL_PATH}}}|$SKILL_LOCAL_PATH|g" \
      -e "s|{{{SKILL_GLOBAL_PATH}}}|$SKILL_GLOBAL_PATH|g" \
      "$SRC_FILE" > "$DEST_FILE"
}

# Install skills with template-aware symlink/copy strategy
# Arguments: $1 = target dir, $2 = skills source dir, $3 = cache dir, $4 = tool, $5 = mode, $6 = label, $7 = "symlink" or "copy"
install_skills() {
  TARGET_DIR="$1"
  SKILLS_SRC="$2"
  CACHE_DIR="$3"
  TOOL="$4"
  MODE="$5"
  LABEL="$6"
  INSTALL_TYPE="$7"

  if [ ! -d "$SKILLS_SRC" ]; then
    warn "Skills directory '$SKILLS_SRC' not found, skipping $LABEL"
    return 1
  fi

  info "Installing $LABEL to: $TARGET_DIR"

  # Set template variables for this tool/mode
  set_template_vars "$TOOL" "$MODE"

  # Clear and recreate cache directory for this tool
  TOOL_CACHE="$CACHE_DIR/$TOOL"
  rm -rf "$TOOL_CACHE"
  mkdir -p "$TOOL_CACHE"

  # Process each skill directory
  for skill_dir in "$SKILLS_SRC"/*/; do
    [ -d "$skill_dir" ] || continue
    skill_name="$(basename "$skill_dir")"
    skill_target="$TARGET_DIR/$skill_name"
    skill_override=""

    if [ "$TOOL" = "codex" ]; then
      if [ -f "$skill_dir/SKILL.codex.tmpl.md" ]; then
        skill_override="SKILL.codex.tmpl.md"
      elif [ -f "$skill_dir/SKILL.codex.md" ]; then
        skill_override="SKILL.codex.md"
      fi
    fi

    # Check for conflict: both SKILL.md and SKILL.tmpl.md
    if [ -f "$skill_dir/SKILL.md" ] && [ -f "$skill_dir/SKILL.tmpl.md" ]; then
      error "Conflict: both SKILL.md and SKILL.tmpl.md exist in $skill_dir"
    fi

    # Determine if this skill uses templates
    HAS_TEMPLATES=""
    if [ -f "$skill_dir/SKILL.tmpl.md" ]; then
      HAS_TEMPLATES="yes"
    else
      # Check for any .tmpl.md files in subdirectories
      if find "$skill_dir" -name "*.tmpl.md" -type f 2>/dev/null | grep -q .; then
        HAS_TEMPLATES="yes"
      fi
    fi

    if [ -n "$HAS_TEMPLATES" ]; then
      # Skill has templates - render to cache, then symlink/copy from cache
      skill_cache="$TOOL_CACHE/$skill_name"
      mkdir -p "$skill_cache"

      # Process all files in the skill directory using find with -exec
      find "$skill_dir" \( -name '.DS_Store' -o -name 'Thumbs.db' \) -prune -o -type f -print | while IFS= read -r src_file; do
        # Get relative path from skill_dir
        file="${src_file#$skill_dir}"
        # Remove leading slash if present
        file="${file#/}"
        [ -z "$file" ] && continue

        if [ -n "$skill_override" ]; then
          case "$file" in
            "SKILL.codex.tmpl.md")
              dest_file_rel="SKILL.md"
              render_template "$src_file" "$skill_cache/$dest_file_rel"
              continue
              ;;
            "SKILL.codex.md")
              dest_file_rel="SKILL.md"
              dest_dir="$(dirname "$skill_cache/$dest_file_rel")"
              [ -d "$dest_dir" ] || mkdir -p "$dest_dir"
              cp -p "$src_file" "$skill_cache/$dest_file_rel"
              continue
              ;;
            "SKILL.tmpl.md"|"SKILL.md")
              continue
              ;;
          esac
        fi

        # Determine destination filename (strip .tmpl if present)
        case "$file" in
          *.tmpl.md)
            dest_file_rel="${file%.tmpl.md}.md"
            # Render template
            render_template "$src_file" "$skill_cache/$dest_file_rel"
            ;;
          *)
            # Non-template file - copy to cache as-is
            dest_dir="$(dirname "$skill_cache/$file")"
            [ -d "$dest_dir" ] || mkdir -p "$dest_dir"
            cp -p "$src_file" "$skill_cache/$file"
            ;;
        esac
      done

      # Now symlink/copy from cache to target
      mkdir -p "$skill_target"
      find "$skill_cache" \( -name '.DS_Store' -o -name 'Thumbs.db' \) -prune -o -type f -print | while IFS= read -r cache_file; do
        # Get relative path from skill_cache
        file="${cache_file#$skill_cache}"
        file="${file#/}"
        [ -z "$file" ] && continue

        target_file="$skill_target/$file"
        target_file_dir="$(dirname "$target_file")"

        [ -d "$target_file_dir" ] || mkdir -p "$target_file_dir"

        # Remove existing
        [ -e "$target_file" ] || [ -L "$target_file" ] && rm -f "$target_file"

        if [ "$INSTALL_TYPE" = "symlink" ]; then
          ln -s "$cache_file" "$target_file"
        else
          cp -p "$cache_file" "$target_file"
        fi
      done
    else
      # No templates - symlink/copy directly from source
      mkdir -p "$skill_target"
      find "$skill_dir" \( -name '.DS_Store' -o -name 'Thumbs.db' \) -prune -o -type f -print | while IFS= read -r src_file; do
        # Get relative path from skill_dir
        file="${src_file#$skill_dir}"
        file="${file#/}"
        [ -z "$file" ] && continue

        if [ -n "$skill_override" ]; then
          case "$file" in
            "SKILL.codex.md")
              target_file="$skill_target/SKILL.md"
              target_file_dir="$(dirname "$target_file")"
              [ -d "$target_file_dir" ] || mkdir -p "$target_file_dir"
              [ -e "$target_file" ] || [ -L "$target_file" ] && rm -f "$target_file"
              if [ "$INSTALL_TYPE" = "symlink" ]; then
                ln -s "$src_file" "$target_file"
              else
                cp -p "$src_file" "$target_file"
              fi
              continue
              ;;
            "SKILL.md")
              continue
              ;;
          esac
        fi

        target_file="$skill_target/$file"
        target_file_dir="$(dirname "$target_file")"

        [ -d "$target_file_dir" ] || mkdir -p "$target_file_dir"

        # Remove existing
        [ -e "$target_file" ] || [ -L "$target_file" ] && rm -f "$target_file"

        if [ "$INSTALL_TYPE" = "symlink" ]; then
          ln -s "$src_file" "$target_file"
        else
          cp -p "$src_file" "$target_file"
        fi
      done
    fi
  done

  success "Skills installed for $LABEL at: $TARGET_DIR"
  return 0
}

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

# Install symlinks to a target directory
# Arguments: $1 = target root, $2 = payload dir, $3 = label for messages
install_symlinks() {
  TARGET_ROOT="$1"
  PAYLOAD_DIR="$2"
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
  FILES="$(find . \( -name '.DS_Store' -o -name 'Thumbs.db' \) -prune -o -type f -print | sed 's|^\./||')"
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
    warn "Found $CONFLICT_COUNT conflicting file(s)/symlink(s) for $LABEL:"
    echo ""
    printf "$CONFLICTS" | head -20
    if [ $CONFLICT_COUNT -gt 20 ]; then
      echo "  ... and $((CONFLICT_COUNT - 20)) more"
    fi
    echo ""
    warn "These will be replaced with symlinks to the repo."
    echo ""
    if ! confirm "Replace ALL conflicting files with symlinks for $LABEL?"; then
      warn "Skipping $LABEL install"
      return 1
    fi
    echo ""
  fi

  # Create symlinks
  info "Creating symlinks for $LABEL..."

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

  success "Symlinks created for $LABEL at: $TARGET_ROOT"
  return 0
}

# Install copies to a target directory
# Arguments: $1 = target root, $2 = payload dir, $3 = label for messages
install_copies() {
  TARGET_ROOT="$1"
  PAYLOAD_DIR="$2"
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
  FILES="$(find . \( -name '.DS_Store' -o -name 'Thumbs.db' \) -prune -o -type f -print | sed 's|^\./||')"
  cd - > /dev/null

  for file in $FILES; do
    dest="$TARGET_ROOT/$file"
    if [ -e "$dest" ] || [ -L "$dest" ]; then
      CONFLICTS="$CONFLICTS$file\n"
      CONFLICT_COUNT=$((CONFLICT_COUNT + 1))
    fi
  done

  if [ "$CONFLICT_COUNT" -gt 0 ]; then
    warn "Found $CONFLICT_COUNT existing file(s) that will be overwritten:"
    printf "%b" "$CONFLICTS"
    echo ""
    if ! confirm "Continue and overwrite these files?"; then
      warn "Installation cancelled."
      return 1
    fi
  fi

  # Create copies
  info "Copying files for $LABEL..."

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

    # Copy file
    cp -p "$src" "$dest" || error "Failed to copy $file"
  done

  success "Files copied for $LABEL at: $TARGET_ROOT"
  return 0
}

# Main
main() {
  echo ""
  echo "  Agent Extensions Install"
  echo "  ========================"
  echo ""

  # Determine script location to find repo root
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

  info "Source directory: $SCRIPT_DIR"
  echo ""

  # Choose tool
  echo "Which tool would you like to install extensions for?"
  echo "  1) OpenCode"
  echo "  2) Augment (Auggie)"
  echo "  3) Codex"
  echo ""
  printf "Enter choice [1/2/3]: "
  read -r tool_choice

  INSTALL_OPENCODE=""
  INSTALL_AUGMENT=""
  INSTALL_CODEX=""

  case "$tool_choice" in
    1)
      INSTALL_OPENCODE="yes"
      ;;
    2)
      INSTALL_AUGMENT="yes"
      ;;
    3)
      INSTALL_CODEX="yes"
      ;;
    *)
      error "Invalid choice. Please enter 1, 2, or 3."
      ;;
  esac

  INSTALL_GLOBAL=""
  INSTALL_LOCAL=""
  INSTALL_CODEX_GLOBAL=""

  if [ -n "$INSTALL_OPENCODE" ] || [ -n "$INSTALL_AUGMENT" ]; then
    echo ""
    echo "Where would you like to install?"
    echo "  1) Global (user config directory)"
    echo "  2) Local (current repo)"
    echo "  3) Both global and local"
    echo ""
    printf "Enter choice [1/2/3]: "
    read -r scope_choice

    case "$scope_choice" in
      1)
        INSTALL_GLOBAL="yes"
        ;;
      2)
        INSTALL_LOCAL="yes"
        ;;
      3)
        INSTALL_GLOBAL="yes"
        INSTALL_LOCAL="yes"
        ;;
      *)
        error "Invalid choice. Please enter 1, 2, or 3."
        ;;
    esac
  else
    INSTALL_CODEX_GLOBAL="yes"
  fi

  # Validate local install is possible
  if [ -n "$INSTALL_LOCAL" ]; then
    GIT_ROOT="$(find_git_root)" || error "Not inside a git repository. Cannot determine repo root for local install."
  fi

  echo ""

  INSTALLED_COUNT=0

  # Install OpenCode globally if requested
  if [ -n "$INSTALL_OPENCODE" ] && [ -n "$INSTALL_GLOBAL" ]; then
    OPENCODE_PAYLOAD="$SCRIPT_DIR/opencode"
    OPENCODE_TARGET="$HOME/.config/opencode"
    if install_symlinks "$OPENCODE_TARGET" "$OPENCODE_PAYLOAD" "OpenCode (global)"; then
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    fi

    OPENCODE_SKILLS_SRC="$SCRIPT_DIR/skills"
    OPENCODE_SKILLS_TARGET="$OPENCODE_TARGET/skill"
    OPENCODE_CACHE="$SCRIPT_DIR/.cache/skills-rendered"
    if install_skills "$OPENCODE_SKILLS_TARGET" "$OPENCODE_SKILLS_SRC" "$OPENCODE_CACHE" "opencode" "global" "OpenCode skills (global)" "symlink"; then
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    fi
    echo ""
  fi

  # Install OpenCode locally if requested (copy)
  if [ -n "$INSTALL_OPENCODE" ] && [ -n "$INSTALL_LOCAL" ]; then
    OPENCODE_PAYLOAD="$SCRIPT_DIR/opencode"
    OPENCODE_TARGET="$GIT_ROOT/.opencode"
    if install_copies "$OPENCODE_TARGET" "$OPENCODE_PAYLOAD" "OpenCode (local)"; then
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    fi

    OPENCODE_SKILLS_SRC="$SCRIPT_DIR/skills"
    OPENCODE_SKILLS_TARGET="$OPENCODE_TARGET/skill"
    OPENCODE_CACHE="$SCRIPT_DIR/.cache/skills-rendered"
    if install_skills "$OPENCODE_SKILLS_TARGET" "$OPENCODE_SKILLS_SRC" "$OPENCODE_CACHE" "opencode" "local" "OpenCode skills (local)" "copy"; then
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    fi
    echo ""
  fi

  # Install Augment globally if requested
  if [ -n "$INSTALL_AUGMENT" ] && [ -n "$INSTALL_GLOBAL" ]; then
    AUGMENT_PAYLOAD="$SCRIPT_DIR/augment"
    AUGMENT_TARGET="$HOME/.augment"
    if install_symlinks "$AUGMENT_TARGET" "$AUGMENT_PAYLOAD" "Augment (global)"; then
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    fi
    echo ""
  fi

  # Install Augment locally if requested (copy)
  if [ -n "$INSTALL_AUGMENT" ] && [ -n "$INSTALL_LOCAL" ]; then
    AUGMENT_PAYLOAD="$SCRIPT_DIR/augment"
    AUGMENT_TARGET="$GIT_ROOT/.augment"
    if install_copies "$AUGMENT_TARGET" "$AUGMENT_PAYLOAD" "Augment (local)"; then
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    fi
    echo ""
  fi

  # Install Codex globally if requested (copy, no symlinks)
  if [ -n "$INSTALL_CODEX_GLOBAL" ]; then
    CODEX_PAYLOAD="$SCRIPT_DIR/codex"
    CODEX_TARGET="$HOME/.codex"
    if install_copies "$CODEX_TARGET" "$CODEX_PAYLOAD" "Codex (global)"; then
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    fi

    CODEX_SKILLS_SRC="$SCRIPT_DIR/skills"
    CODEX_SKILLS_TARGET="$CODEX_TARGET/skills"
    CODEX_CACHE="$SCRIPT_DIR/.cache/skills-rendered"
    if install_skills "$CODEX_SKILLS_TARGET" "$CODEX_SKILLS_SRC" "$CODEX_CACHE" "codex" "global" "Codex skills (global)" "copy"; then
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    fi
    echo ""
  fi

  # Install Codex locally if requested (copy)
  if [ -n "$INSTALL_CODEX" ] && [ -n "$INSTALL_LOCAL" ]; then
    CODEX_PAYLOAD="$SCRIPT_DIR/codex"
    CODEX_TARGET="$GIT_ROOT/.codex"
    if install_copies "$CODEX_TARGET" "$CODEX_PAYLOAD" "Codex (local)"; then
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    fi

    CODEX_SKILLS_SRC="$SCRIPT_DIR/skills"
    CODEX_SKILLS_TARGET="$CODEX_TARGET/skills"
    CODEX_CACHE="$SCRIPT_DIR/.cache/skills-rendered"
    if install_skills "$CODEX_SKILLS_TARGET" "$CODEX_SKILLS_SRC" "$CODEX_CACHE" "codex" "local" "Codex skills (local)" "copy"; then
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    fi
    echo ""
  fi

  if [ $INSTALLED_COUNT -eq 0 ]; then
    error "No installations completed"
  fi

  success "Install complete!"
  echo ""
  info "Source files at: $SCRIPT_DIR"
  echo ""
  echo "Global installs use symlinks to the repo (except Codex, which uses copies)."
  echo "Local installs copy files into the repo (Codex local installs are not supported)."
  echo ""
}

main "$@"
