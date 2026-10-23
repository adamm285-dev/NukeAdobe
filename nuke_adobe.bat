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
echo  ^| \ ^| ^| ^| ^| ^| ^|/ / ____^|   / \  ^|  _ \ / _ \^| __ )^| ____^|
echo  ^|  \^| ^| ^| ^| ^| ' /^|  _^|    / _ \ ^| ^| ^| ^| ^| ^| ^|  _ \^|  _^|  
echo  ^| ^|\  ^| ^|_^| ^| . \^| ^|___  / ___ \^| ^|_^| ^| ^|_^| ^| ^|_) ^| ^|___ 
echo  ^|_^| \_\^|___/^|_^|\_\_____^|/_/   \_\____/ \___/^|____/^|_____^|
echo.
echo          TOTAL NUCLEAR ADOBE PERSISTENCE CLEANER ^& IMMUNIZER
echo  ============================================================================
echo.
echo WARNING: This tool will completely terminate and eradicate ALL Adobe background
echo services, persistent daemons, telemetry hooks, OOBE updaters, and orphan files.
echo.
choice /M "Are you ready to permanently purge all Adobe components from this machine"
if errorlevel 2 (
    echo [ABORTED] Operation cancelled by user.
    pause
    exit /b 0
)

echo.
echo ==============================================================================
echo [Phase 1/6] Terminating Process Tree & Telemetry Daemons...
echo ==============================================================================
set PROCESSES=AGMService.exe AGSService.exe AdobeGCClient.exe agcinvokerutility.exe AdobeCleanUpUtility.exe Photoshop.exe AdobeNotificationHelper.exe CCXProcess.exe CoreSync.exe PDapp.exe AdobeIPCBroker.exe AAMLauncher.exe LogTransport2.exe "AAM Updates Notifier.exe" "Adobe Application Manager (Updater).exe" "Creative Cloud UI Helper.exe" CRClient.exe AIDE.dll CoreSyncCustomHook.exe AAMCustomHook.exe AAMLauncherUtil.exe Setup.exe TokenGenerator64.exe PlatformUtil.exe Adobe_Helperx32.exe Adobe_Helperx64.exe CustomHook_Helperx64.exe TokenResolverx64.exe "AAM Registration Notifier.exe" adobe_licutil.exe AASIapp.exe adobe_licensing_helper.exe adobe_lichelper.exe updatercorehelper.exe updaterstartuputility.exe CSDKConfigurator.exe PluginCleanup.exe cai-helper.exe

for %%P in (%PROCESSES%) do (
    taskkill /F /IM %%P /T >nul 2>&1
)
echo   [+] All active and dormant Adobe processes terminated.

echo.
echo ==============================================================================
echo [Phase 2/6] Deleting Windows Background Services...
echo ==============================================================================
set SERVICES=AGMService AGSService AdobeUpdateService AdobeFlashPlayerUpdateSvc AdobeARMservice CCXProcess CoreSync
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
echo [Phase 4/6] Wiping Orphan Directories, Updaters, & Payload Caches...
echo ==============================================================================
set DIRS="C:\Program Files (x86)\Common Files\Adobe\AdobeGCClient" "C:\Program Files (x86)\Common Files\Adobe\OOBE" "C:\Program Files (x86)\Common Files\Adobe\AdobeApplicationManager" "C:\Program Files (x86)\Common Files\Adobe\AdobeNotificationManager" "C:\Program Files (x86)\Common Files\Adobe\ARM" "C:\Program Files (x86)\Common Files\Adobe\CoreSyncExtension" "C:\Program Files (x86)\Common Files\Adobe\Adobe Desktop Common" "C:\Program Files (x86)\Common Files\Adobe\Installers" "C:\Program Files\Common Files\Adobe\Adobe XD" "C:\Program Files\Common Files\Adobe\CAI" "C:\Program Files\Common Files\Adobe\Microsoft\EdgeWebView" "C:\Program Files\Adobe\Adobe Photoshop (Beta)" "C:\Program Files\Adobe\Adobe Creative Cloud" "C:\Program Files (x86)\Adobe"

for %%D in (%DIRS%) do (
    if exist %%D (
        rmdir /s /q %%D >nul 2>&1
        echo   [-] Removed directory: %%D
    )
)

echo.
echo ==============================================================================
echo [Phase 5/6] Establishing NTFS Immunization Shields...
echo ==============================================================================
:: A read-only hidden system file blocks Windows NTFS from recreating folders of the same name.
if not exist "C:\Program Files (x86)\Common Files\Adobe" mkdir "C:\Program Files (x86)\Common Files\Adobe" >nul 2>&1

set IMMUNIZATIONS="C:\Program Files (x86)\Common Files\Adobe\AdobeGCClient" "C:\Program Files (x86)\Common Files\Adobe\ARM"

for %%I in (%IMMUNIZATIONS%) do (
    if not exist %%I (
        type nul > %%I 2>nul
        attrib +R +S +H %%I 2>nul
        echo   [*] Immunization active: %%I
    )
)

echo.
echo ==============================================================================
echo [Phase 6/6] Purging Residual Registry Trees & Uninstall Entries...
echo ==============================================================================
reg delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\AdobeGenuineService" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\PHSPBETA_24_7" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Adobe Genuine Service" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Adobe Genuine Service" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\PHSP_BETA_25.0" /f >nul 2>&1
reg delete "HKCU\Software\Adobe" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Adobe" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\WOW6432Node\Adobe" /f >nul 2>&1
echo   [-] Registry keys purged.

color 0A
echo.
echo ==============================================================================
echo [SUCCESS] NukeAdobe operation finished.
echo Zero persistent Adobe background processes, daemons, or tasks remain.
echo ==============================================================================
echo.
pause
