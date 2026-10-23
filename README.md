# NukeAdobe 🚀

> **Total nuclear uninstaller, background persistence cleaner, and immunization tool for Windows & macOS.**

Permanently eradicates orphaned Adobe background services, telemetry brokers (`LogTransport2`, `AdobeIPCBroker`), updater daemons (`OOBE\PDApp`, `ARM`), LaunchDaemons, Task Scheduler hooks, and residual footprints—and installs **Immunization Shields** to prevent them from ever resurrecting.

---

```
 ============================================================================
  _   _ _   _ _  _______     _    ____   ___  ____  _____ 
 | \ | | | | | |/ / ____|   / \  |  _ \ / _ \| __ )| ____|
 |  \| | | | | ' /|  _|    / _ \ | | | | | | |  _ \|  _|  
 | |\  | |_| | . \| |___  / ___ \| |_| | |_| | |_) | |___ 
 |_| \_|\___/|_|\_\_____|/_/   \_\____/ \___/|____/|_____|

          TOTAL NUCLEAR ADOBE PERSISTENCE CLEANER & IMMUNIZER
 ============================================================================
```

---

## The Problem: The Adobe "Zombie" Architecture

Commercial software packages frequently fail to uninstall cleanly. Even after running standard uninstallers or third-party cleanup tools, Adobe products leave behind a multi-tiered background persistence network:

### Windows:
* **Task Scheduler:** `Adobe-Genuine-Software-Integrity-Scheduler`, `AdobeGCInvoker`
* **Background Services:** `AGMService.exe` and `AGSService.exe` (Local System privileges)
* **Autonomous OOBE Updaters:** `PDapp.exe`, `LogTransport2.exe`, `AdobeIPCBroker.exe`

### macOS:
* **LaunchDaemons & LaunchAgents:** `/Library/LaunchDaemons/com.adobe.*` and `~/Library/LaunchAgents/com.adobe.*`
* **Privileged Helpers:** `/Library/PrivilegedHelperTools/com.adobe.*`
* **Background daemons:** `AdobeGCClient`, `Adobe Desktop Service`, `Core Sync`, `CCXProcess`

When a user deletes the app or monitor, background triggers notice the missing binary and command the updater to silently reinstall and reinstate the service.

---

## The Solution: Eradication & Immunization

`NukeAdobe` breaks this resurrection loop completely:

1. **Process Tree Termination:** Force-kills all active and dormant Adobe executables, IPC brokers, telemetry monitors, and crash daemons.
2. **Service & Launch Daemon Deletion:** Deregisters and wipes Windows services (`sc delete`) and macOS LaunchDaemons/LaunchAgents (`launchctl bootout`).
3. **Trigger Purging:** Wipes Windows Task Scheduler hooks and macOS plist startup agents.
4. **Directory & Payload Nuke:** Wipes residual updater folders, payload caches, and broken application directories (`AdobeGCClient`, `OOBE`, `ARM`, `AdobeNotificationManager`, `CoreSyncExtension`).
5. **Immunization Shields:** In both Windows NTFS and macOS HFS+/APFS, a directory cannot be created if an immutable file with the identical name already occupies that path:
   * **Windows:** Creates dummy 0-byte files marked `+R +S +H` at `AdobeGCClient` and `ARM`.
   * **macOS:** Creates an immutable file flagged with `chflags uchg` at `AdobeGCClient`.
   * Any future background installer or script that attempts to `mkdir AdobeGCClient` crashes and fails to deploy.
6. **Registry & Cache Flush:** Scrubs orphan `Uninstall` display entries and clears root `Software\Adobe` branches on Windows, or flushes DNS/mDNSResponder on macOS.

---

## Usage

### Windows
1. Download or clone this repository.
2. Right-click **`nuke_adobe.bat`**.
3. Select **"Run as administrator"**.
4. Press `Y` to confirm.

### macOS
1. Open Terminal in the repo folder.
2. Make executable and run with `sudo`:
   ```bash
   chmod +x nuke_adobe.sh
   sudo ./nuke_adobe.sh
   ```

---

## Verification

After running `NukeAdobe`, verify your system is 100% clean:

### Windows (PowerShell):
```powershell
Get-Process -Name "*Adobe*", "*AGS*", "*AGM*"
Get-Service -Name "*AGM*", "*AGS*", "*Adobe*"
Get-ScheduledTask | Where-Object { $_.TaskName -like "*Adobe*" }
```

### macOS (Terminal):
```bash
pgrep -i adobe
launchctl list | grep -i adobe
ls -la /Library/LaunchDaemons/com.adobe.*
```

All commands return empty output.

---

## License

[MIT](LICENSE) © 2026 Adam M.
