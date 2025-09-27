@echo off
echo MathStep リリースビルドを開始します...
echo.

echo 1. Flutter依存関係を更新中...
call flutter pub get
if %ERRORLEVEL% NEQ 0 (
    echo エラー: Flutter依存関係の更新に失敗しました。
    pause
    exit /b 1
)

echo.
echo 2. Android APKをビルド中...
call flutter build apk --release
if %ERRORLEVEL% NEQ 0 (
    echo エラー: Android APKのビルドに失敗しました。
    pause
    exit /b 1
)

echo.
echo 3. Android App Bundleをビルド中...
call flutter build appbundle --release
if %ERRORLEVEL% NEQ 0 (
    echo エラー: Android App Bundleのビルドに失敗しました。
    pause
    exit /b 1
)

echo.
echo 4. iOSアーカイブをビルド中...
call flutter build ios --release
if %ERRORLEVEL% NEQ 0 (
    echo エラー: iOSビルドに失敗しました。
    pause
    exit /b 1
)

echo.
echo ビルドが完了しました！
echo.
echo 生成されたファイル:
echo - Android APK: build\app\outputs\flutter-apk\app-release.apk
echo - Android App Bundle: build\app\outputs\bundle\release\app-release.aab
echo - iOS: build\ios\Release-iphoneos\Runner.app
echo.
echo 次のステップ:
echo 1. Android App BundleをGoogle Play Consoleにアップロード
echo 2. iOSアプリをXcodeでアーカイブしてApp Store Connectにアップロード
echo.

pause

