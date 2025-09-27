# MathStep App Keystore Generator (PowerShell版)
Write-Host "MathStep App Keystore Generator" -ForegroundColor Green
Write-Host ""

$KEYSTORE_PATH = "android\app\keystore\mathstep-keystore.jks"
$KEY_ALIAS = "mathstep_key"

Write-Host "Keystore file: $KEYSTORE_PATH"
Write-Host "Key alias: $KEY_ALIAS"
Write-Host ""

Write-Host "Please enter the following information:"
Write-Host ""

$STORE_PASSWORD = Read-Host "Keystore password"
$KEY_PASSWORD = Read-Host "Key password"
$KEY_ALIAS_INPUT = Read-Host "Key alias (default: mathstep_key)"

if ([string]::IsNullOrEmpty($KEY_ALIAS_INPUT)) {
    $KEY_ALIAS_INPUT = "mathstep_key"
}

Write-Host ""
Write-Host "Generating keystore..." -ForegroundColor Yellow

try {
    keytool -genkey -v -keystore $KEYSTORE_PATH -alias $KEY_ALIAS_INPUT -keyalg RSA -keysize 2048 -validity 10000 -storepass $STORE_PASSWORD -keypass $KEY_PASSWORD -dname "CN=MathStep, OU=Development, O=ProfileCode, L=Tokyo, S=Tokyo, C=JP"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "Keystore generated successfully!" -ForegroundColor Green
        Write-Host "File: $KEYSTORE_PATH"
        Write-Host ""
        Write-Host "Please update key.properties file:"
        Write-Host "storePassword=$STORE_PASSWORD"
        Write-Host "keyPassword=$KEY_PASSWORD"
        Write-Host "keyAlias=$KEY_ALIAS_INPUT"
        Write-Host "storeFile=app/keystore/mathstep-keystore.jks"
    } else {
        Write-Host ""
        Write-Host "Error: Failed to generate keystore." -ForegroundColor Red
    }
} catch {
    Write-Host ""
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Read-Host "Press Enter to continue"

