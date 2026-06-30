@echo off
title Balatro APK Builder - TripleSix Project
echo ==========================================
echo   Balatro APK Builder for TripleSix
echo ==========================================
echo.

:: Ensure Java JDK path is in environment variables for this session
set PATH=%PATH%;C:\Program Files\Eclipse Adoptium\jdk-17.0.12.7-hotspot\bin

set BUILD_DIR=%PROJECT_DIR%\APK_Builder
set PROJECT_DIR=%cd%

echo [1/3] Dong bo ma nguon project sang thu muc build...
if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"
if not exist "%BUILD_DIR%\mods" mkdir "%BUILD_DIR%\mods"
if not exist "%BUILD_DIR%\mods\Balatro-TripleSix" mkdir "%BUILD_DIR%\mods\Balatro-TripleSix"

:: Clean old build mods first to ensure fresh code
powershell -Command "Remove-Item -Path '%BUILD_DIR%\mods\Balatro-TripleSix\*' -Recurse -Force -ErrorAction SilentlyContinue"

:: Sync mod code excluding git/temp build files
xcopy "%PROJECT_DIR%" "%BUILD_DIR%\mods\Balatro-TripleSix" /E /I /Y /Exclude:%PROJECT_DIR%\.exclude_apk.txt

echo.
echo [2/3] Chay bo build APK...
echo Luu y: Vui long lam theo cac huong dan tren man hinh console.
cd /d "%BUILD_DIR%"
call balatro-mobile-maker.exe

echo.
echo [3/3] Sao chep file APK thanh pham ve project...
if exist "%BUILD_DIR%\balatro.apk" (
    copy "%BUILD_DIR%\balatro.apk" "%PROJECT_DIR%\Balatro.apk" /Y
    echo.
    echo SUCCESS: Build hoan tat! File 'Balatro.apk' da duoc xuat ra o thu muc project cua ban.
) else (
    echo.
    echo WARNING: Khong tim thay file balatro.apk thanh pham. Co the build bi loi hoac bi huy.
)

cd /d "%PROJECT_DIR%"
pause
