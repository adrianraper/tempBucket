@echo off

:: AIR application packaging
:: More information:
:: http://livedocs.adobe.com/flex/3/html/help.html?content=CommandLineTools_5.html#1035959

:: Path to Flex SDK binaries
:: set PATH=%PATH%;C:\Program Files\flex_sdk_4.1\bin
:: set PATH=%PATH%;C:\Program Files (x86)\Adobe\Adobe Flash Builder 4.5\sdks\4.6_AIR3.3\bin
set PATH=%PATH%;C:\Flex\4.9.1_AIR3.7\bin

:: Signature (see 'CreateCertificate.bat')
:: set CERTIFICATE=SelfSigned.pfx
set CERTIFICATE=C:\certificates\ClarityCertificate2015.p12
set SIGNING_OPTIONS=-storetype pkcs12 -keystore %CERTIFICATE% -keypass Clarit163y -storepass Clarit163y
if not exist %CERTIFICATE% goto certificate

:: Output
if not exist air md air
set AIR_FILE=air/ClarityRecorder.air

:: Input
:: Make sure you don't include any .svn files in the folders
set APP_XML=application.xml 
set FILE_OR_DIR=-C bin ClarityRecorder.swf updateConfig.xml RecorderHelp.html images icons/CRIcon_128x128.png icons/CRIcon_48x48.png icons/CRIcon_32x32.png icons/CRIcon_16x16.png

echo Signing AIR setup using certificate %CERTIFICATE%.
call adt -package %SIGNING_OPTIONS% %AIR_FILE% %APP_XML% %FILE_OR_DIR%
if errorlevel 1 goto failed

echo.
echo AIR setup created: %AIR_FILE%
echo.
goto end

:certificate
echo Certificate not found: %CERTIFICATE%
echo.
echo Troubleshooting: 
echo A certificate is required, generate one using 'CreateCertificate.bat'
echo.
goto end

:failed
echo AIR setup creation FAILED.
echo.
echo Troubleshooting: 
echo did you configure the Flex SDK path in this Batch file?
echo.

:end
pause
