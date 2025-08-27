@echo off
setlocal

REM ###############################################################
REM # Simple batch file for APK file editing on Windows 11        #
REM # Requires ADB and Apktool!                                   #
REM ###############################################################

ECHO.
ECHO =======================================================
ECHO       APK Extraction and Editing Tool
ECHO =======================================================
ECHO.
ECHO This script uses ADB to pull an APK from your device
ECHO and then uses Apktool to decompile it.
ECHO.
ECHO MAKE SURE YOUR ANDROID PHONE IS CONNECTED WITH USB DEBUGGING ENABLED.
ECHO.
pause

ECHO.
ECHO Step 1: Searching for a connected device...
adb devices
ECHO.
ECHO IF NO DEVICES ARE LISTED, CHECK YOUR CONNECTION OR DRIVERS AND TRY AGAIN.
ECHO.
pause

ECHO.
ECHO Step 2: Listing installed applications...
ECHO.
adb shell pm list packages -f | findstr /i "base.apk"
ECHO.
ECHO COPY THE PATH TO THE APK YOU WANT TO EDIT.
ECHO EXAMPLE: /data/app/~~C9u7W2pS--_pS-3EwW-fA==/com.example.app-vLq7Xh5iT41V5rS6VfD4pA==/base.apk
ECHO.
set /p apk_path="Paste the APK path and press ENTER: "

ECHO.
ECHO Step 3: Extracting filename from path...
FOR /F "delims=" %%i IN ("%apk_path%") DO (
    SET "filename=%%~ni%%~xi"
)
SET "apk_name=%filename:base.apk=pulled_app.apk%"
ECHO The APK filename will be: %apk_name%
ECHO.

ECHO Step 4: Pulling the APK file from your device to this folder...
adb pull "%apk_path%" "%apk_name%"
IF ERRORLEVEL 1 (
    ECHO.
    ECHO ERROR: Failed to pull the APK file. MAKE SURE THE PATH IS CORRECT AND TRY AGAIN.
    ECHO.
    goto end
)
ECHO.
ECHO APK file pulled as "%apk_name%".
ECHO.

ECHO Step 5: Decompiling the APK file for editing...
ECHO.
java -jar apktool.jar d "%apk_name%" -o "decompiled_app"
IF ERRORLEVEL 1 (
    ECHO.
    ECHO ERROR: Failed to decompile the APK file. MAKE SURE APKTOOL.JAR IS IN THIS FOLDER.
    ECHO.
    goto end
)

ECHO.
ECHO =======================================================
ECHO   The APK is now decompiled in the "decompiled_app" folder.
ECHO   You can now edit the following:
ECHO   - **Manifest**: Edit the AndroidManifest.xml file
ECHO   - **Files**: Add or change files in the "assets" or "res" folders.
ECHO   - **Strings**: Edit the strings.xml files in the "res" folder.
ECHO =======================================================
ECHO.
pause

ECHO.
ECHO Step 6: Recompiling the APK file...
java -jar apktool.jar b "decompiled_app" -o "recompiled_app.apk"
IF ERRORLEVEL 1 (
    ECHO.
    ECHO ERROR: Failed to recompile the file. Check if you corrupted any files.
    ECHO.
    goto end
)

ECHO.
ECHO Step 7: Uninstalling the original app (necessary for installing the new version)...
adb uninstall %apk_path%
ECHO.

ECHO Step 8: Installing the new, modified APK on your device...
REM Note: An unsigned APK might not work. You can sign it with apksigner.
adb install "recompiled_app.apk"
ECHO.
ECHO Installation complete.
ECHO.

:end
pause
endlocal
