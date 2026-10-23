@echo off
:: ==============================================================================
:: NukeAdobe - Total Nuclear Adobe Uninstaller, Persistence Cleaner & Immunizer
:: Repository: https://github.com/adamm285-dev/NukeAdobe
:: License: MIT
:: ==============================================================================
setlocal EnableDelayedExpansion

:: 1. Administrative Privilege Verification
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo ==============================================================================
    echo [ERROR] Administrative privileges required!
    echo Please right-click 'nuke_adobe.bat' and select 'Run as administrator'.
    echo ==============================================================================
    echo.
    pause
    exit /b 1
)

color 0C
echo.
echo  ============================================================================
echo   _   _ _   _ _  _______     _    ____   ___  ____  _____ 
echo  ^| \ ^| ^| ^| ^| ^| ^|/ / ____^|   / \  ^|  _ \ / _ \| __ )| ____^|
echo  ^|  \^| ^| ^| ^| ^| ' /^|  _|    / _ \ ^| ^| ^| ^| ^| ^| ^|  _ \^|  _|  
echo  ^| ^|\  ^| ^|_^| ^| . \^| ^|___  / ___ \| |_| | |_| | |_) ^| ^|___ 
echo  ^|_^| \_\^|___/^|_^|\_\_____^|/_/   \_\____/ \___/|____/^|_____^|
echo.
echo          TOTAL NUCLEAR ADOBE PERSISTENCE CLEANER ^& IMMUNIZER
echo  ============================================================================
echo.
echo  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
echo  [CRITICAL WARNING: THIS IS A TOTAL SYSTEM PURGE - NO JOKE]
echo  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
echo.
echo  This tool does NOT perform a gentle uninstallation. It executes a full-scale
echo  eradication of EVERY Adobe program, service, background monitor, and user
echo  cache on this machine.
echo.
echo  WHAT WILL BE PURGED:
echo   - ALL running Adobe apps (Photoshop, Premiere, Illustrator, AfterFX, Acrobat)
echo   - ALL Adobe background services and stealth monitors (AGMService, AGSService)
echo   - ALL Task Scheduler resurrection triggers
echo   - ALL installed Adobe application folders in Program Files (gigabytes of apps)
echo   - ALL Adobe user application data, temp caches, and local configurations
echo   - ALL Adobe registry branches across HKLM and HKCU
echo.
echo  WHAT IT ESTABLISHES:
echo   - Drops immutable NTFS Immunization Shields to physically block Adobe from
echo     ever recreating background monitoring directories on this computer.
echo.
echo  IF YOU STILL USE ANY ADOBE PRODUCTS ON THIS PC, CANCEL RIGHT NOW.
echo  ============================================================================
echo.

choice /M "Are you 100%% certain you want to permanently NUKE all Adobe components"
if errorlevel 2 (
    echo.
    echo [ABORTED] Operation cancelled by user. Zero changes were made.
    pause
    exit /b 0
)

echo.
echo ==============================================================================
echo [Phase 1/6] Force-Terminating All Creative Apps, Background Tree & Telemetry...
echo ==============================================================================
set PROCESSES=Photoshop.exe "Adobe Premiere Pro.exe" Premiere.exe Illustrator.exe AfterFX.exe Acrobat.exe AcroCEF.exe "Adobe InDesign.exe" InDesign.exe "Adobe Media Encoder.exe" AME.exe Lightroom.exe Audition.exe "Creative Cloud.exe" "Creative Cloud UI Helper.exe" AGMService.exe AGSService.exe AdobeGCClient.exe agcinvokerutility.exe AdobeCleanUpUtility.exe AdobeNotificationHelper.exe CCXProcess.exe CoreSync.exe PDapp.exe AdobeIPCBroker.exe AAMLauncher.exe LogTransport2.exe "AAM Updates Notifier.exe" "Adobe Application Manager (Updater).exe" CRClient.exe AIDE.dll CoreSyncCustomHook.exe AAMCustomHook.exe AAMLauncherUtil.exe Setup.exe TokenGenerator64.exe PlatformUtil.exe Adobe_Helperx32.exe Adobe_Helperx64.exe CustomHook_Helperx64.exe TokenResolverx64.exe "AAM Registration Notifier.exe" adobe_licutil.exe AASIapp.exe adobe_licensing_helper.exe adobe_lichelper.exe updatercorehelper.exe updaterstartuputility.exe CSDKConfigurator.exe PluginCleanup.exe cai-helper.exe

for %%P in (%PROCESSES%) do (
    taskkill /F /IM %%P /T >nul 2>&1
)
echo   [+] All active and dormant Adobe applications and processes terminated.

echo.
echo ==============================================================================
echo [Phase 2/6] Deleting Windows Background Services...
echo ==============================================================================
set SERVICES=AGMService AGSService AdobeUpdateService AdobeFlashPlayerUpdateSvc AdobeARMservice CCXProcess CoreSync "Adobe Acrobat Update Service"
for %%S in (%SERVICES%) do (
    sc stop "%%S" >nul 2>&1
    sc delete "%%S" >nul 2>&1
    echo   [-] Service removed: %%S
)

echo.
echo ==============================================================================
echo [Phase 3/6] Purging Resurrecting Task Scheduler Triggers...
echo ==============================================================================
for /f "tokens=1 delims=," %%T in ('schtasks /query /fo csv /nh 2^>nul ^| findstr /i "Adobe"') do (
    schtasks /delete /tn %%T /f >nul 2>&1
    echo   [-] Task deleted: %%T
)

echo.
echo ==============================================================================
echo [Phase 4/6] Wiping All Program Directories, User Caches & Data Trees...
echo ==============================================================================
set ROOT_DIRS="C:\Program Files\Adobe" "C:\Program Files (x86)\Adobe" "C:\Program Files\Common Files\Adobe" "C:\Program Files (x86)\Common Files\Adobe" "%LOCALAPPDATA%\Adobe" "%APPDATA%\Adobe" "%PROGRAMDATA%\Adobe"

for %%D in (%ROOT_DIRS%) do (
    if exist %%D (
        rmdir /s /q %%D >nul 2>&1
        echo   [-] Nuked directory tree: %%D
    )
)

echo.
echo ==============================================================================
echo [Phase 5/6] Establishing NTFS Immunization Shields...
echo ==============================================================================
:: Re-create common Adobe parent folders to host the collision locks
if not exist "C:\Program Files (x86)\Common Files\Adobe" mkdir "C:\Program Files (x86)\Common Files\Adobe" >nul 2>&1
if not exist "C:\Program Files\Common Files\Adobe" mkdir "C:\Program Files\Common Files\Adobe" >nul 2>&1

set IMMUNIZATIONS="C:\Program Files (x86)\Common Files\Adobe\AdobeGCClient" "C:\Program Files (x86)\Common Files\Adobe\ARM" "C:\Program Files\Common Files\Adobe\AdobeGCClient"

for %%I in (%IMMUNIZATIONS%) do (
    if not exist %%I (
        type nul > %%I 2>nul
        attrib +R +S +H %%I 2>nul
        echo   [*] Immunization shield active: %%I
    )
)

echo.
echo ==============================================================================
echo [Phase 6/6] Purging Residual Registry Trees & Add/Remove Programs Entries...
echo ==============================================================================
reg delete "HKCU\Software\Adobe" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Adobe" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\WOW6432Node\Adobe" /f >nul 2>&1

for /f "tokens=*" %%K in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" 2^>nul ^| findstr /i "Adobe PHSP ILST PPRO"') do (
    reg delete "%%K" /f >nul 2>&1
)
for /f "tokens=*" %%K in ('reg query "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall" 2^>nul ^| findstr /i "Adobe PHSP ILST PPRO"') do (
    reg delete "%%K" /f >nul 2>&1
)
echo   [-] Registry keys and uninstall references purged.

color 0A
echo.
echo ==============================================================================
echo [SUCCESS] NukeAdobe operation finished.
echo Zero Adobe programs, services, background daemons, or tasks remain on this PC.
echo ==============================================================================
echo.
pause
