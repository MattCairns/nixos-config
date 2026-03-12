{pkgs}:
pkgs.writeShellScriptBin "install-desktop" ''
      set -euo pipefail

      # ── colours ──────────────────────────────────────────────────────────────
      RED='\033[0;31m'
      GREEN='\033[0;32m'
      YELLOW='\033[1;33m'
      CYAN='\033[0;36m'
      BOLD='\033[1m'
      NC='\033[0m'

      info()    { echo -e "$CYAN==>$NC $BOLD$*$NC"; }
      success() { echo -e "$GREEN ✓$NC $*"; }
      warn()    { echo -e "$YELLOW  !$NC $*"; }
      die()     { echo -e "$RED ERR$NC $*" >&2; exit 1; }
      ask()     { echo -e -n "$BOLD$*$NC "; }

      banner() {
        echo ""
        echo -e "$CYAN$BOLD━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$NC"
        echo -e "$CYAN$BOLD  $*$NC"
        echo -e "$CYAN$BOLD━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$NC"
        echo ""
      }

  confirm() {
    ask "$* [y/N]"
    read -r reply
    reply=$(echo "$reply" | tr '[:upper:]' '[:lower:]')
    [[ "$reply" == "y" ]]
  }

  prompt_password() {
    local user=$1
    local password1
    local password2

    while true; do
      ask "Set password for $user:"
      read -rs password1
      echo ""
      ask "Confirm password for $user:"
      read -rs password2
      echo ""

      if [[ -z "$password1" ]]; then
        warn "Password cannot be empty"
      elif [[ "$password1" != "$password2" ]]; then
        warn "Passwords did not match"
      else
        PASSWORD_VALUE=$password1
        return 0
      fi
    done
  }

      # ── sanity checks ─────────────────────────────────────────────────────────
      banner "NixOS Desktop Installer"

      if [[ $EUID -ne 0 ]]; then
        die "Run this script as root (e.g. sudo install-desktop)"
      fi

    export NIX_CONFIG="''${NIX_CONFIG-}
  experimental-features = nix-command flakes"

      # Enable nix-command and flakes for this session if not already configured.
      # The NixOS installer ISO ships with them disabled by default.
      if ! ${pkgs.nix}/bin/nix flake --help &>/dev/null 2>&1; then
        info "Enabling nix-command and flakes for this session..."
        mkdir -p /etc/nix
        if ! grep -q "experimental-features" /etc/nix/nix.conf 2>/dev/null; then
          echo "experimental-features = nix-command flakes" >> /etc/nix/nix.conf
          success "nix-command and flakes enabled in /etc/nix/nix.conf"
        fi
      fi

      # ── step 1: clone the repo ────────────────────────────────────────────────
      banner "Step 1 of 5 — Clone nixos-config"

  REPO_DIR=/tmp/nixos-config
  FLAKE_REF="path:$REPO_DIR#desktop"

      if [[ -d "$REPO_DIR/.git" ]]; then
        warn "Repo already exists at $REPO_DIR — pulling latest..."
        ${pkgs.git}/bin/git -C "$REPO_DIR" pull --ff-only
      else
        info "Cloning MattCairns/nixos-config from GitHub..."
        ${pkgs.git}/bin/git clone https://github.com/MattCairns/nixos-config "$REPO_DIR"
      fi

      success "Repo ready at $REPO_DIR"

      # ── step 2: pick a disk ───────────────────────────────────────────────────
      banner "Step 2 of 5 — Choose installation disk"

      info "Block devices on this machine:"
      echo ""
      ${pkgs.util-linux}/bin/lsblk -o NAME,SIZE,TYPE,MODEL,TRAN
      echo ""
  info "Stable disk IDs (recommended — use one of these):"
  echo ""
  ls -1 /dev/disk/by-id/ \
    | grep -v -- "-part" \
    | sed 's|^|  /dev/disk/by-id/|'
  echo ""

  DEFAULT_DISK=$(${pkgs.gnugrep}/bin/grep -oP 'disk = "\K[^"]+' "$REPO_DIR/machines/desktop/configuration.nix" | head -1 || true)
  if [[ "$DEFAULT_DISK" == "/dev/disk/by-id/PLACEHOLDER" ]]; then
    DEFAULT_DISK=""
  fi

  DISK_ID=""

  if [[ -n "$DEFAULT_DISK" ]]; then
    info "Suggested disk from repo config: $DEFAULT_DISK"
    if confirm "Use this disk?"; then
      if [[ -b "$DEFAULT_DISK" ]]; then
        DISK_ID="$DEFAULT_DISK"
      else
        warn "Suggested disk '$DEFAULT_DISK' is not present on this machine"
      fi
    fi
  fi

  if [[ -z "$DISK_ID" ]]; then
    while true; do
      ask "Enter full disk path (e.g. /dev/disk/by-id/nvme-...):"
      read -r DISK_ID
      if [[ -b "$DISK_ID" ]]; then
        break
      else
        warn "'$DISK_ID' is not a valid block device, try again"
      fi
    done
  fi

      success "Selected: $DISK_ID"
      echo ""
      warn "ALL DATA ON $DISK_ID WILL BE PERMANENTLY DESTROYED."
      echo ""
      confirm "Are you absolutely sure you want to continue?" || die "Aborted."

      # ── step 3: swap size ─────────────────────────────────────────────────────
      banner "Step 3 of 5 — Swap / hibernate"

      TOTAL_RAM_GB=$(${pkgs.gawk}/bin/awk '/MemTotal/ { printf "%.0f", $2/1024/1024 }' /proc/meminfo)
      HIBERNATE_GB=$(echo "$TOTAL_RAM_GB * 3 / 2" | ${pkgs.bc}/bin/bc)
      info "Detected RAM: ~$TOTAL_RAM_GB GB"
      echo ""
      echo "  Swap size guide:"
      echo "    No hibernate  → equal to RAM  : ''${TOTAL_RAM_GB}G"
      echo "    With hibernate → 1.5× RAM     : ''${HIBERNATE_GB}G"
      echo ""

      SWAP_SIZE=""
      while true; do
        ask "Enter swap size (e.g. 32G) [default: ''${TOTAL_RAM_GB}G]:"
        read -r SWAP_SIZE
        SWAP_SIZE="''${SWAP_SIZE:-''${TOTAL_RAM_GB}G}"
        if [[ "$SWAP_SIZE" =~ ^[0-9]+[GgMm]$ ]]; then
          break
        else
          warn "Invalid format '$SWAP_SIZE' — use a number followed by G or M (e.g. 32G)"
        fi
      done

      success "Swap size: $SWAP_SIZE"

      # ── step 4: patch configuration.nix ──────────────────────────────────────
      banner "Step 4 of 5 — Patch desktop configuration"

      DESKTOP_CFG="$REPO_DIR/machines/desktop/configuration.nix"

      info "Setting disk path..."
      ${pkgs.gnused}/bin/sed -i \
        "s|disk = \"/dev/disk/by-id/PLACEHOLDER\";|disk = \"$DISK_ID\";|" \
        "$DESKTOP_CFG"

      info "Setting swap size..."
      ${pkgs.gnused}/bin/sed -i \
        "s|swapSize = \"32G\";|swapSize = \"$SWAP_SIZE\";|" \
        "$DESKTOP_CFG"

      info "Detecting kernel modules for this hardware..."
      TMPROOT=$(mktemp -d)
      trap 'rm -rf "$TMPROOT"' EXIT
      ${pkgs.nixos-install-tools}/bin/nixos-generate-config \
        --root "$TMPROOT" --no-filesystems 2>/dev/null || true
      HW_CFG="$TMPROOT/etc/nixos/hardware-configuration.nix"

      if [[ -f "$HW_CFG" ]]; then
        AVAIL=$(grep -oP 'availableKernelModules = \[.*?\]' "$HW_CFG" || true)
        KMODS=$(grep -oP 'kernelModules = \[.*?\]' "$HW_CFG" | head -1 || true)

        if [[ -n "$AVAIL" ]]; then
          info "  initrd.$AVAIL"
          ${pkgs.gnused}/bin/sed -i \
            "s|boot.initrd.availableKernelModules = \[\];|boot.initrd.$AVAIL;|" \
            "$DESKTOP_CFG"
        fi
        if [[ -n "$KMODS" ]]; then
          info "  $KMODS"
          ${pkgs.gnused}/bin/sed -i \
            "s|boot.kernelModules = \[\];|boot.$KMODS;|" \
            "$DESKTOP_CFG"
        fi
        success "Kernel modules patched"
      else
        warn "Could not auto-detect kernel modules."
        warn "Fill in boot.initrd.availableKernelModules in $DESKTOP_CFG after install."
      fi

      echo ""
      info "Final desktop configuration:"
      echo ""
      ${pkgs.bat}/bin/bat --language nix --style plain "$DESKTOP_CFG" 2>/dev/null \
        || cat "$DESKTOP_CFG"
      echo ""

      confirm "Looks good? Proceed to format and install?" \
        || die "Aborted — edit $DESKTOP_CFG and re-run."

      # ── step 5: disko + nixos-install ─────────────────────────────────────────
      banner "Step 5 of 5 — Format disks and install NixOS"

  info "Running disko (partition, encrypt, format, mount)..."
  echo ""
  ${pkgs.nix}/bin/nix \
    --extra-experimental-features "nix-command flakes" \
    run github:nix-community/disko -- \
    --mode destroy,format,mount \
    --flake "$FLAKE_REF"
  echo ""
  success "Disks partitioned and mounted at /mnt"

  info "Creating persistent password files..."
  mkdir -p /mnt/persist/passwords
  chmod 700 /mnt/persist/passwords

  prompt_password root
  ${pkgs.openssl}/bin/openssl passwd -6 -stdin <<< "$PASSWORD_VALUE" > /mnt/persist/passwords/root

  prompt_password matthew
  ${pkgs.openssl}/bin/openssl passwd -6 -stdin <<< "$PASSWORD_VALUE" > /mnt/persist/passwords/matthew

  chmod 600 /mnt/persist/passwords/root /mnt/persist/passwords/matthew
  success "Persistent password files written to /mnt/persist/passwords"

  info "Running nixos-install..."
  echo ""
  ${pkgs.nixos-install-tools}/bin/nixos-install \
    --option experimental-features "nix-command flakes" \
    --flake "$FLAKE_REF" \
    --no-root-password
      echo ""

  success "Installation complete!"
  echo ""
  echo -e "$BOLD  Next steps:$NC"
  echo "    1. Reboot            :  reboot"
  echo "    2. Log in as matthew with the password you set above"
  echo ""
  warn "Store your LUKS passphrase somewhere safe before rebooting!"
      echo ""
''
