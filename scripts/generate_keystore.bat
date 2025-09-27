@echo off
chcp 65001 >nul
echo MathStep App Keystore Generator
echo.

set KEYSTORE_PATH=android\app\keystore\mathstep-keystore.jks
set KEY_ALIAS=mathstep_key

echo Keystore file: %KEYSTORE_PATH%
echo Key alias: %KEY_ALIAS%
echo.

echo Please enter the following information:
echo.

set /p STORE_PASSWORD=Keystore password: 
set /p KEY_PASSWORD=Key password: 
set /p KEY_ALIAS_INPUT=Key alias (default: mathstep_key): 

if "%KEY_ALIAS_INPUT%"=="" set KEY_ALIAS_INPUT=mathstep_key

echo.
echo Generating keystore...

keytool -genkey -v -keystore %KEYSTORE_PATH% -alias %KEY_ALIAS_INPUT% -keyalg RSA -keysize 2048 -validity 10000 -storepass %STORE_PASSWORD% -keypass %KEY_PASSWORD% -dname "CN=MathStep, OU=Development, O=ProfileCode, L=Tokyo, S=Tokyo, C=JP"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo Keystore generated successfully!
    echo File: %KEYSTORE_PATH%
    echo.
    echo Please update key.properties file:
    echo storePassword=%STORE_PASSWORD%
    echo keyPassword=%KEY_PASSWORD%
    echo keyAlias=%KEY_ALIAS_INPUT%
    echo storeFile=app/keystore/mathstep-keystore.jks
) else (
    echo.
    echo Error: Failed to generate keystore.
)

pause
