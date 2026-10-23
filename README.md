# NukeAdobe 🚀

> **Total nuclear uninstaller, background persistence cleaner, and NTFS immunization tool for Windows.**

Permanently eradicates orphaned Adobe background services, telemetry brokers (`LogTransport2`, `AdobeIPCBroker`), updater daemons (`OOBE\PDApp`, `ARM`), Task Scheduler hooks, and residual registry footprints—and installs **NTFS Immunization Shields** to prevent them from ever resurrecting.

---

## The Problem: The Adobe "Zombie" Architecture

Commercial software packages frequently fail to uninstall cleanly. Even after running standard uninstallers or third-party cleanup tools, Adobe products often leave behind a multi-tiered background persistence network:

```
┌───────────────────────────────────────────────────────────┐
│                    Task Scheduler                         │
│  (Adobe-Genuine-Software-Integrity-Scheduler, AdobeGCInvoker)
└─────────────────────────────┬─────────────────────────────┘
                              ▼
┌───────────────────────────────────────────────────────────┐
│              Windows Background Services                  │
│             (AGMService.exe / AGSService.exe)             │
│   • Runs under Local System privileges                    │
│   • Scans processes, open handles, and network telemetry   │
└─────────────────────────────┬─────────────────────────────┘
                              ▼
┌───────────────────────────────────────────────────────────┐
│            Autonomous OOBE & ARM Updaters                 │
│      (PDapp.exe, LogTransport2.exe, AdobeIPCBroker)       │
│   • Silently queries Adobe telemetry servers              │
│   • Redownloads and restores deleted AGMService binaries   │
└───────────────────────────────────────────────────────────┘
```

When you kill or delete `AGMService`, the Task Scheduler trigger notes the missing binary and commands the OOBE updater to silently redownload and reinstate the service.

---

## The Solution: 6-Phase Eradication & Immunization

`NukeAdobe` breaks this resurrection loop completely through a 6-phase purge:

1. **Process Tree Termination:** Force-kills all active and dormant Adobe executables, including background IPC brokers, telemetry monitors, and crash reporters.
2. **Service Deletion (`sc delete`):** Deregisters and deletes all known Adobe Windows services (`AGMService`, `AGSService`, `AdobeUpdateService`, `AdobeARMservice`, etc.).
3. **Task Scheduler Cleansing:** Queries Task Scheduler across root and subfolders for any task containing `Adobe` and physically deletes them.
4. **Directory & Payload Nuke:** Wipes residual updater folders, payload caches, and broken application directories (`AdobeGCClient`, `OOBE`, `ARM`, `AdobeNotificationManager`, `CoreSyncExtension`).
5. **NTFS Immunization Shields:** In Windows NTFS, a directory cannot be created if an existing read-only system file with the identical name occupies that path. `NukeAdobe` drops immutable, 0-byte dummy files marked `+R +S +H` at `AdobeGCClient` and `ARM`, causing any future installer or background script to fail silently if it attempts to recreate those payload directories.
6. **Registry Purge:** Scrubs orphan `Uninstall` display entries and clears root `Software\Adobe` branches across `HKLM`, `HKCU`, and `WOW6432Node`.

---

## Usage

### Quick Start
1. Download or clone this repository.
2. Right-click **`nuke_adobe.bat`**.
3. Select **"Run as administrator"**.
4. Confirm with `Y` when prompted.

*Zero external dependencies. Pure native Windows batch scripting compatible with Windows 10 and Windows 11.*

---

## Verification

After running `NukeAdobe`, you can verify your system is completely clean using PowerShell:

```powershell
# 1. Verify 0 running processes
Get-Process -Name "*Adobe*", "*AGS*", "*AGM*"

# 2. Verify 0 active or stopped services
Get-Service -Name "*AGM*", "*AGS*", "*Adobe*"

# 3. Verify 0 scheduled tasks
Get-ScheduledTask | Where-Object { $_.TaskName -like "*Adobe*" }
```

All three commands will return empty output.

---

## Contributing & Disclaimer

Pull requests are welcome! If you identify additional persistent binaries, telemetry endpoints, or registry keys introduced in newer Adobe software builds, feel free to submit an issue or PR.

*Disclaimer: This tool is intended for personal computing sovereignty and system cleanup of orphaned, lingering, or unwanted software components after uninstallation.*

## License

[MIT](LICENSE) © 2026 Adam M.
