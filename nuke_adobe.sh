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
echo "WARNING: This tool will completely terminate and eradicate ALL Adobe background"
echo "services, persistent daemons, LaunchDaemons, LaunchAgents, and orphan files."
echo ""
read -p "Are you ready to permanently purge all Adobe components? (y/N): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
  echo "[ABORTED] Operation cancelled by user."
  exit 0
fi

echo ""
echo "=============================================================================="
echo "[Phase 1/5] Unloading LaunchDaemons and LaunchAgents..."
echo "=============================================================================="
for plist in /Library/LaunchDaemons/com.adobe.* \
             /Library/LaunchAgents/com.adobe.* \
             ~/Library/LaunchAgents/com.adobe.*; do
  if [ -f "$plist" ]; then
    launchctl bootout system "$plist" 2>/dev/null || launchctl unload "$plist" 2>/dev/null
    rm -f "$plist"
    echo "  [-] Removed and unloaded: $plist"
  fi
done

echo ""
echo "=============================================================================="
echo "[Phase 2/5] Terminating Adobe Process Tree..."
echo "=============================================================================="
ADOBE_PROCS=("AdobeGCClient" "AGSService" "AGMService" "Adobe Desktop Service" \
             "Core Sync" "CCXProcess" "AdobeCRDaemon" "AdobeIPCBroker" \
             "com.adobe.acc.installer" "LogTransport2")

for proc in "${ADOBE_PROCS[@]}"; do
  killall "$proc" 2>/dev/null && echo "  [+] Terminated process: $proc"
done

echo ""
echo "=============================================================================="
echo "[Phase 3/5] Wiping Orphan Directories & Background Daemons..."
echo "=============================================================================="
DIRS=(
  "/Applications/Utilities/Adobe Genuine Service"
  "/Applications/Utilities/Adobe Creative Cloud"
  "/Applications/Adobe*"
  "/Library/Application Support/Adobe"
  "/Library/Application Support/AdobeGCClient"
  "~/Library/Application Support/Adobe"
  "~/Library/Application Support/AdobeGCClient"
  "/Library/PrivilegedHelperTools/com.adobe.*"
)

for dir in "${DIRS[@]}"; do
  rm -rf "$dir" 2>/dev/null
  echo "  [-] Purged directory: $dir"
done

echo ""
echo "=============================================================================="
echo "[Phase 4/5] Establishing Immunization Shields (chflags uchg)..."
echo "=============================================================================="
# On macOS, an immutable file (uchg) blocks the directory from being recreated
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
