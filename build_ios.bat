@echo off
echo ===================================
echo   Building RGB Controller App
echo   for Apple App Store
echo ===================================

REM Set Flutter path
set PATH=C:\src\flutter\bin;%PATH%

REM Navigate to project directory
cd /d "c:\Users\johnn\Desktop\RGB\mobile-app"

echo.
echo [1/4] Cleaning previous builds...
flutter clean

echo.
echo [2/4] Getting dependencies...
flutter pub get

echo.
echo [3/4] Building iOS app for App Store...
echo Note: This requires macOS with Xcode installed.
echo On Windows, you can only prepare the Flutter code.
flutter build ios --release --no-codesign

echo.
echo [4/4] Build prepared!
echo.
echo Next steps for iOS distribution:
echo 1. Transfer the project to a Mac with Xcode
echo 2. Open ios/Runner.xcworkspace in Xcode
echo 3. Configure signing and provisioning profiles
echo 4. Archive and upload to App Store Connect
echo.
echo iOS build output: build\ios\iphoneos\Runner.app
echo.
pause