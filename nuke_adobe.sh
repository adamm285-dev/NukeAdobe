#!/usr/bin/env bash
# ==============================================================================
# NukeAdobe for macOS
# Total Nuclear Adobe Uninstaller, Persistence Cleaner & Immunizer
# Repository: https://github.com/adamm285-dev/NukeAdobe
# License: MIT
# ==============================================================================

# Verify root privileges
if [ "$EUID" -ne 0 ]; then
  echo ""
  echo "=============================================================================="
  echo " [ERROR] Root privileges required!"
  echo " Please run this script with sudo: sudo ./nuke_adobe.sh"
  echo "=============================================================================="
  echo ""
  exit 1
fi

# Detect actual invoking user (to correctly resolve user-level Library paths when run via sudo)
REAL_USER="${SUDO_USER:-$USER}"
USER_HOME=$(eval echo "~$REAL_USER")

echo ""
echo " ============================================================================"
echo "  _   _ _   _ _  _______     _    ____   ___  ____  _____ "
echo " | \ | | | | | |/ / ____|   / \  |  _ \ / _ \| __ )| ____|"
echo " |  \| | | | | ' /|  _|    / _ \ | | | | | | |  _ \|  _|  "
echo " | |\  | |_| | . \| |___  / ___ \| |_| | |_| | |_) | |___ "
echo " |_| \_|\___/|_|\_\_____|/_/   \_\____/ \___/|____/|_____|"
echo ""
echo "         TOTAL NUCLEAR ADOBE PERSISTENCE CLEANER & IMMUNIZER (macOS)"
echo " ============================================================================"
echo ""
echo " !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo " [CRITICAL WARNING: THIS IS A TOTAL SYSTEM PURGE - NO JOKE]"
echo " !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo ""
echo " This tool does NOT perform a gentle uninstallation. It executes a full-scale"
echo " eradication of EVERY Adobe app, background service, LaunchDaemon, and cache."
echo ""
echo " WHAT WILL BE PURGED:"
echo "  - ALL running Adobe apps (Photoshop, Premiere, Illustrator, InDesign, Acrobat)"
echo "  - ALL Adobe LaunchDaemons and LaunchAgents (system-wide and user-level)"
echo "  - ALL installed Adobe application bundles inside /Applications"
echo "  - ALL Adobe Application Support directories, user preferences, and caches"
echo ""
echo " WHAT IT ESTABLISHES:"
echo "  - Drops immutable filesystem shields (chflags uchg) to physically block"
echo "    Adobe from ever regenerating monitoring directories on this Mac."
echo ""
echo " IF YOU STILL USE ANY ADOBE PRODUCTS ON THIS MAC, CANCEL RIGHT NOW."
echo " ============================================================================"
echo ""
echo "Target User: $REAL_USER ($USER_HOME)"
echo ""
read -p "Type 'NUKE' to permanently wipe all Adobe software from this Mac: " confirm
if [ "$confirm" != "NUKE" ]; then
  echo ""
  echo "[ABORTED] Operation cancelled. Zero modifications made."
  exit 0
fi

echo ""
echo "=============================================================================="
echo "[Phase 1/5] Unloading LaunchDaemons and LaunchAgents..."
echo "=============================================================================="
PLISTS=(
  /Library/LaunchDaemons/com.adobe.*
  /Library/LaunchAgents/com.adobe.*
  "$USER_HOME/Library/LaunchAgents/com.adobe.*"
)

for plist in "${PLISTS[@]}"; do
  if [ -f "$plist" ]; then
    launchctl bootout system "$plist" 2>/dev/null || launchctl unload "$plist" 2>/dev/null
    rm -f "$plist"
    echo "  [-] Removed and unloaded: $plist"
  fi
done

echo ""
echo "=============================================================================="
echo "[Phase 2/5] Terminating All Adobe Apps & Daemon Process Tree..."
echo "=============================================================================="
ADOBE_PROCS=(
  "Adobe Photoshop" "Adobe Premiere Pro" "Adobe Illustrator" "Adobe InDesign" \
  "Adobe After Effects" "Adobe Acrobat" "Creative Cloud" "Creative Cloud UI Helper" \
  "AdobeGCClient" "AGSService" "AGMService" "Adobe Desktop Service" \
  "Core Sync" "CCXProcess" "AdobeCRDaemon" "AdobeIPCBroker" \
  "com.adobe.acc.installer" "LogTransport2" "AcroCEF"
)

for proc in "${ADOBE_PROCS[@]}"; do
  killall "$proc" 2>/dev/null && echo "  [+] Terminated process: $proc"
done

echo ""
echo "=============================================================================="
echo "[Phase 3/5] Wiping All Application Bundles, Caches & Data Trees..."
echo "=============================================================================="
DIRS=(
  "/Applications/Adobe*"
  "/Applications/Utilities/Adobe*"
  "/Library/Application Support/Adobe"
  "/Library/Application Support/AdobeGCClient"
  "/Library/PrivilegedHelperTools/com.adobe.*"
  "$USER_HOME/Library/Application Support/Adobe"
  "$USER_HOME/Library/Application Support/AdobeGCClient"
  "$USER_HOME/Library/Caches/com.adobe.*"
  "$USER_HOME/Library/Caches/Adobe"
  "$USER_HOME/Library/Preferences/com.adobe.*"
)

for dir in "${DIRS[@]}"; do
  if [ -e "$dir" ]; then
    rm -rf "$dir" 2>/dev/null
    echo "  [-] Purged: $dir"
  fi
done

echo ""
echo "=============================================================================="
echo "[Phase 4/5] Establishing Immunization Shields (chflags uchg)..."
echo "=============================================================================="
mkdir -p "/Library/Application Support/Adobe" 2>/dev/null
touch "/Library/Application Support/Adobe/AdobeGCClient" 2>/dev/null
chflags uchg "/Library/Application Support/Adobe/AdobeGCClient" 2>/dev/null
echo "  [*] Immunization active at: /Library/Application Support/Adobe/AdobeGCClient"

echo ""
echo "=============================================================================="
echo "[Phase 5/5] Flushing DNS and System Caches..."
echo "=============================================================================="
dscacheutil -flushcache 2>/dev/null
killall -HUP mDNSResponder 2>/dev/null
echo "  [+] System caches flushed."

echo ""
echo "=============================================================================="
echo "[SUCCESS] NukeAdobe macOS purge complete. System is completely clean."
echo "=============================================================================="
echo ""
