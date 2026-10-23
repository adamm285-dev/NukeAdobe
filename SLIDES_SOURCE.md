# NukeAdobe: Technical Whitepaper & Overview

## 1. Executive Summary
NukeAdobe is a lightweight, cross-platform (Windows & macOS), zero-dependency uninstaller and persistence eradication engine. It was developed to remediate predatory persistence, continuous telemetry harvesting, and unauthorized service regeneration ("zombie architecture") deployed by Adobe Inc.'s background utilities, notably the Adobe Genuine Service (AGS), AdobeGCClient, and OOBE background updaters.

## 2. Problem Statement: The De-Coupled Resurrection Architecture
Modern software uninstallation mechanisms frequently mislead users into believing all software footprint has been removed. In reality, Adobe software suites utilize a de-coupled, three-tier resilience loop:
1. **Tier 1: Scheduled Tasks & LaunchDaemons.** Hidden timer triggers (`Adobe-Genuine-Software-Integrity-Scheduler`, `AdobeGCInvoker`, `com.adobe.agsservice.plist`) execute at user logon and hourly intervals.
2. **Tier 2: System-Level Privileged Daemons.** Windows services (`AGMService.exe`, `AGSService.exe`) and macOS root daemons monitor memory, process namespaces, and open file descriptors while continuously beaconing hardware IDs and process telemetry back to Adobe servers.
3. **Tier 3: The OOBE Mothership.** When a user terminates or deletes Tier 2 binaries, Tier 1 triggers activate secondary updater utilities (`PDapp.exe`, `agcinvokerutility.exe`, `updatercorehelper.exe`) to re-download, unpack, and reinstall the monitor.

## 3. The NukeAdobe 6-Phase Solution
1. **Synchronous Process Tree Termination:** Eliminates all active, dormant, and spawned child helper binaries to release file handle locks.
2. **Service & Daemon Deregistration:** Uses low-level OS APIs (`sc.exe delete` on Windows, `launchctl bootout` on macOS) to remove service registration keys from the OS kernel.
3. **Trigger Purging:** Wipes all scheduled triggers matching the vendor namespace, destroying the resurrection countdown.
4. **Filesystem Scrubbing:** Recursively purges orphaned application data caches, logs, and staging payloads from system and user directories.
5. **NTFS & APFS Immunization Shields:** Implements a collision-based filesystem lock. On Windows NTFS and macOS APFS, an OS cannot create a directory if an immutable system file of the identical name occupies that exact path. NukeAdobe drops 0-byte dummy files flagged `+R +S +H` (Windows) or `chflags uchg` (macOS), permanently neutralizing re-creation attempts.
6. **Registry & Cache Flush:** Eliminates dangling Add/Remove Programs registry stubs and flushes system DNS resolver caches.

## 4. Security & Safety Invariants
- **Zero Third-Party Dependencies:** Uses exclusively native OS utilities (`taskkill`, `sc`, `schtasks`, `rmdir`, `launchctl`, `killall`). No external binaries, downloads, or network calls are made.
- **Strict Canonical Path Targeting:** No unbounded wildcards (`*`) are executed in root directories (`C:\`, `/`). All deletion actions target explicit vendor subdirectories (`/Common Files/Adobe/`, `/Library/Application Support/Adobe/`).
- **Auditability:** Complete script source code is human-readable, fully documented, and under 150 lines per platform.
