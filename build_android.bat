@echo off
echo ===================================
echo   Building RGB Controller App
echo   for Google Play Store
echo ===================================

REM Set Flutter path
set FLUTTER_ROOT=C:\src\flutter
set PATH=%FLUTTER_ROOT%\bin;%PATH%

REM Navigate to project directory
cd /d "c:\Users\johnn\Desktop\RGB\mobile-app"

echo.
echo [1/5] Cleaning previous builds...
"%FLUTTER_ROOT%\bin\flutter.bat" clean

echo.
echo [2/5] Getting dependencies...
"%FLUTTER_ROOT%\bin\flutter.bat" pub get

echo.
echo [3/5] Building APK for testing...
"%FLUTTER_ROOT%\bin\flutter.bat" build apk --release

echo.
echo [4/5] Building App Bundle for Play Store...
"%FLUTTER_ROOT%\bin\flutter.bat" build appbundle --release

echo.
echo [5/5] Build completed!
echo.
echo Files generated:
echo - APK: build\app\outputs\flutter-apk\app-release.apk
echo - AAB: build\app\outputs\bundle\release\app-release.aab
echo.
echo Upload the AAB file to Google Play Console for distribution.
echo Use the APK file for direct installation and testing.
echo.
pause