@echo off

:: Use when you need to update an application that was originally signed with a certificate that has been renewed
:: More information:
:: http://help.adobe.com/en_US/AIR/1.5/devappshtml/WS13ACB483-1711-43c0-9049-0A7251630A7D.html

:: Path to Flex SDK binaries
set PATH=%PATH%;C:\Flex\Flex4.16_AIR26.0\bin

:: Signature (see 'CreateCertificate.bat')
:: The original certificate
set CERTIFICATE=c:\certificates\ClarityCertificate2010.pfx
set SIGNING_OPTIONS=-storetype pkcs12 -keystore %CERTIFICATE% -keypass Clarit163y -storepass Clarit163y
if not exist %CERTIFICATE% goto certificate

:: Output
if not exist air md air
set AIR_FILE=air/ClarityRecorder.air
set AIR_FILE_NEW=air/ClarityRecorderRenew.air

:: Call migration option, just need the name of the AIR
echo Renewing AIR setup using certificate %CERTIFICATE%.
call adt -migrate %SIGNING_OPTIONS% %AIR_FILE% %AIR_FILE_NEW%
if errorlevel 1 goto failed

echo.
echo AIR setup created: %AIR_FILE%
echo.
goto end

:certificate
echo Certificate not found: %CERTIFICATE%
echo.
echo Troubleshotting: 
echo A certificate is required, generate one using 'CreateCertificate.bat'
echo.
goto end

:failed
echo AIR setup creation FAILED.
echo.
echo Troubleshotting: 
echo did you configure the Flex SDK path in this Batch file?
echo.

:end
pause
