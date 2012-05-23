#
# Clarity installation of Road to IELTS 2
#

# Notes:
# {Name} refers to a compile time constant
# (^Name) refers to the standard language string for NSIS
# $Name refers to a variable set with Var Name
# !define is for compile time constants

Name "Road to IELTS 2" ; This is an Installer Attributes command, used for register key and product name

# General Symbol Definitions
!define FolderName "RoadToIELTS2" ; This is macro, used for directory name and url
!define ShortName "R2IV2"
!define Icon "${FolderName}\${ShortName}.ico"
!define REGKEY "SOFTWARE\$(^Name)"
!define VERSION 2.0
!define COMPANY "Clarity Language Consultants Ltd"
!define URL "http://www.ClarityEnglish.com"

# MUI Symbol Definitions
!define MUI_ICON "${Icon}"
!define MUI_WELCOMEFINISHPAGE_BITMAP Setup_${ShortName}.bmp

!define MUI_PAGE_HEADER_TEXT "Installation"
!define MUI_PAGE_HEADER_SUBTEXT "Choose which version of $(^Name) you want to install."
!define MUI_DIRECTORYPAGE_TEXT_TOP $ServerDesc

!define MUI_FINISHPAGE_NOAUTOCLOSE
!define MUI_STARTMENUPAGE_REGISTRY_ROOT HKLM
!define MUI_STARTMENUPAGE_NODISABLE
!define MUI_STARTMENUPAGE_REGISTRY_KEY ${REGKEY}
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME StartMenuGroup
!define MUI_STARTMENUPAGE_DEFAULTFOLDER Clarity
!define MUI_FINISHPAGE_RUN
!define MUI_FINISHPAGE_RUN_TEXT "Start $(^Name)"
!define MUI_FINISHPAGE_RUN_FUNCTION "LaunchLink"
!define MUI_FINISHPAGE_SHOWREADME $INSTDIR\Install\${FolderName}\network_installation_options.pdf
!define MUI_FINISHPAGE_SHOWREADME_TEXT "View network options document"
!define MUI_UNICON "Uninstall.ico"
!define MUI_UNFINISHPAGE_NOAUTOCLOSE

# Components page interface
!define MUI_COMPONENTSPAGE_TEXT_TOP "Check the version you want to use. Click Next to continue."
!define MUI_COMPONENTSPAGE_TEXT_COMPLIST "Select version to install:"
!define MUI_COMPONENTSPAGE_TEXT_INSTTYPE ""
!define MUI_COMPONENTSPAGE_TEXT_DESCRIPTION_TITLE "Description"
!define MUI_COMPONENTSPAGE_TEXT_DESCRIPTION_INFO "Position your mouse over a version to see its description."

# Included files ( NSIS default includes )
!include Sections.nsh
!include MUI.nsh
!include FileFunc.nsh
!include TextFunc.nsh
!include WordFunc.nsh

# Included files ( Clarity includes )
!include IpFunction.nsh
!include FileSearch.nsh

# Variables
var StartMenuGroup
var ASerial ; Serial number for product
var AProductCode ; Product code
var AUsers ; User numbers
var ALang ; Product language
var LangVersion
var LocalIp ; The server IP address auto detect
var InputPort ; User input server port for listening
var INSTVAL ; User input install directory
var isSrvEx ; Flag for the Clarity web service already exist or not
var ExSrvDir ; The root folder of exist Clarity web service
var ExExt
var ExPHP
var ExConf
var ExCommon
var ExDatabase
var ServerDesc

# Installer pages
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_COMPONENTS
Page custom PAGE_INSTALLTYPE PAGE_INSTALLTYPE_LEAVE
Page custom PAGE_WEBSETTING PAGE_WEBSETTING_LEAVE
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_STARTMENU Application $StartMenuGroup
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

# Installer languages
!insertmacro MUI_LANGUAGE English

# Installer attributes
RequestExecutionLevel admin
BrandingText "${COMPANY}"
OutFile ..\MakeCD\${FolderName}\Install\_setupws.exe
InstallDir C:\Clarity ; default installation folder

# If you SONY SecuROM this file, you can't do a CRC check
CRCCheck off
XPStyle on
ShowInstDetails show
VIProductVersion 2.0.0.851
VIAddVersionKey ProductName "$(^Name)"
VIAddVersionKey ProductVersion "${VERSION}"
VIAddVersionKey CompanyName "${COMPANY}"
VIAddVersionKey CompanyWebsite "${URL}"
VIAddVersionKey FileVersion "${VERSION}"
VIAddVersionKey FileDescription ""
VIAddVersionKey LegalCopyright "Copyright ${COMPANY} 1992-2012"
InstallDirRegKey HKLM "${REGKEY}" Path
ShowUninstDetails show

Section -Main SEC0000
    SetOverwrite on
    LogSet on
    AddSize 68421

	## 
	## Change to include the content installation in the single installation file.
	##  Advantages: simplifies the installation process, just one window, better uninstall
	##  Disadvantage: have to SecuROM a much bigger file, less flexibility for joint large/small network versions
	## So, keep separate files then!
	# 
	# Road to IELTS 2 content is just in one folder. 
	# You could skip the selection of various menu files if you want.
   	ExecWait 'ContentSetup.exe /NCRC /AINSTDIR=$INSTDIR /AProductCode=$AProductCode'
    
MainNext:
	# For files that end up in c:/Clarity/RoadToIELTS2 folder
	# Start-AC.php, config.xml, register.exe, registrationHelp.html
    SetOutPath $INSTDIR\${FolderName}
    SetOverwrite on
	File /r /x *.svn* "${FolderName}\*"

	# Some parts of Software\Common apply to RM and Bento
	# But we don't really need to install \Source, \SQLServer unless it is Orchid
	# Yes you do, the register program uses runProgressQuery.php
    SetOutPath $INSTDIR\Software\Common
    SetOverwrite ifnewer
	File /r /x *.svn* "D:\ContentBench\Software\Common\*"
	
	## TODO. Exclude parts that the network will not use, like \rmail, \reports, \smarty
	## TODO. Ensure everything is Zend encoded
	SetOutPath $INSTDIR\Software\ResultsManager
    SetOverwrite ifnewer
	File /r /x *.svn* "D:\ContentBench\Software\ResultsManager\*"
	
	SetOutPath $INSTDIR\Software
    SetOverwrite ifnewer
	File "D:\ContentBench\Software\${ShortName}.ico"

	; If there is web serivce already exist then upgrade the service, if not then create the service
    StrCmp $isSrvEx "True" UpgradeSrv CreateSrv
CreateSrv:
	    SetOutPath $INSTDIR\Database
	    # You don't want to ever overwrite an existing database or you will lose all accounts/users etc
	    SetOverwrite off
	    File /r /x *.svn* "D:\ContentBench\Database\clarity.db"
		#SetOutPath $INSTDIR\Software\Common
		#File /r /x *.svn* "Software\Common\*"
		SetOutPath $SYSDIR
	    IfFileExists $SYSDIR\libeay32.dll +2 0
	        File "WebServices\PHP\libeay32.dll"
	    IfFileExists $SYSDIR\ssleay32.dll +2 0
        	File "WebServices\PHP\ssleay32.dll"
		SetOutPath $INSTDIR\WebServices
		File /r /x *.svn* "WebServices\*"

	    ${ConfigWrite} "$INSTDIR\WebServices\conf\httpd.conf" "Listen " "$LocalIp:$InputPort" $R0
		; Update the configure file for Clarity web service
		FileOpen $0 $INSTDIR\WebServices\conf\httpd.conf a
		FileSeek $0 0 End ; Move the pointer to the end of configure file
		FileWrite $0 "$\r$\n\
			# CD-133D $\r$\n\
			<Directory '$INSTDIR\${FolderName}'>$\r$\n\
			Order allow,deny$\r$\n\
			Allow from all$\r$\n\
			DirectoryIndex Start.php$\r$\n\
			</Directory>$\r$\n\
			# End of CD-133D $\r$\n"
		FileClose $0
		; Create clarity web services
	    ExecWait 'sc create ClarityWebSrv binpath= "$INSTDIR\WebServices\bin\httpd.exe -k runservice" displayname= "ClarityWebSrv" start= auto'
	    Goto NextStep
UpgradeSrv:
		${WordAdd} $ExSrvDir "\" "+Software\Common" $ExCommon
		#SetOutPath $ExCommon
		#File /r /x *.svn* "Software\Common\*"
		
		; Update the configure file for Clarity web service
		${WordAdd} $ExSrvDir "\" "+WebServices\conf\httpd.conf" $ExConf
		; Check wether the installed dir configure or not
		Push $ExConf
		Push "<Directory '$INSTDIR\${FolderName}'>"
		Call FileSearch
		Pop $0 #Number of times found throughout
		Pop $1 #Number of lines found on
		StrCmp $0 0 0 UpdateDB # If not found this string in configure then register it, else do the updateDB directly
		; Backup httpd.conf first
		CreateDirectory "$ExSrvDir\WebServices\conf\backup"
		CopyFiles "$ExConf" "$ExSrvDir\WebServices\conf\backup"
		Rename "$ExSrvDir\WebServices\conf\backup\httpd.conf" "$ExSrvDir\WebServices\conf\backup\httpd.conf.${ShortName}.bak" 

		FileOpen $0 $ExConf a
		FileSeek $0 0 End ; Move the pointer to the end of configure file
		StrCmp $ExSrvDir $INSTDIR 0 AliasDir
		; Only change the install folder's index
		FileWrite $0 "$\r$\n\
			# CD-133D $\r$\n\
			<Directory '$INSTDIR\${FolderName}'>$\r$\n\
			Order allow,deny$\r$\n\
			Allow from all$\r$\n\
			DirectoryIndex Start.php$\r$\n\
			</Directory>$\r$\n\
			# End of CD-133D $\r$\n"
		Goto UpdateDB
	AliasDir:
		##
		## I think this is coping with an old, incorrect installation
		##
		; Alias folders to the new place
		FileWrite $0 "$\r$\n\
			# CD-133D $\r$\n\
			Alias '/${FolderName}' '$INSTDIR\${FolderName}'$\r$\n\
			<Directory '$INSTDIR\${FolderName}'>$\r$\n\
			Order allow,deny$\r$\n\
			Allow from all$\r$\n\
			DirectoryIndex Start.php$\r$\n\
			</Directory>$\r$\n\
			$\r$\n\
			Alias '/Software/${FolderName}' '$INSTDIR\Software\${FolderName}'$\r$\n\
			<Directory '$INSTDIR\Software\${FolderName}'>$\r$\n\
			Order allow,deny$\r$\n\
			Allow from all$\r$\n\
			</Directory>$\r$\n\
			$\r$\n\
			Alias '/Install' '$INSTDIR\Install'$\r$\n\
			<Directory '$INSTDIR\Install'>$\r$\n\
			Order allow,deny$\r$\n\
			Allow from all$\r$\n\
			</Directory>$\r$\n\
			$\r$\n\
			Alias '/Software/Recorder' '$INSTDIR\Software\Recorder'$\r$\n\
			<Directory '$INSTDIR\Software\Recorder'>$\r$\n\
			Order allow,deny$\r$\n\
			Allow from all$\r$\n\
			</Directory>"
			
			FileWrite $0 "$\r$\n\
				Alias '/Content/${FolderName}' '$INSTDIR\Content\${FolderName}'$\r$\n\
				<Directory '$INSTDIR\Content\${FolderName}'>$\r$\n\
				Order allow,deny$\r$\n\
				Allow from all$\r$\n\
				</Directory>$\r$\n\
				# End of CD-133D $\r$\n"
			Goto UpdateDB
UpdateDB:
		FileClose $0
		; Stop the exists web services
		ExecWait 'sc stop ClarityWebSrv'
		# Update old clarity.db and old clarity program
		${WordAdd} $ExSrvDir "\" "+Database" $ExDatabase
		SetOutPath $ExDatabase
		File "Update\sqlite3.exe"
		File "Update\updateDB.sql"
		ExecWait `"$ExDatabase\sqlite3.exe" "$ExDatabase\clarity.db" ".read '$ExDatabase\updateDB.sql'"`
		Delete "$ExDatabase\sqlite3.exe"
		Delete "$ExDatabase\updateDB.sql"
		
		## This section updates IYJ
		#IfFileExists "$ExSrvDir\area1\ItsYourJob\*.*" 0 +5
		#	SetOutPath "$ExSrvDir\area1\ItsYourJob"
		#	File "Update\ItsYourJob\location.txt"
		#	File "Update\ItsYourJob\location-IndEN.txt"
		#	File "Update\ItsYourJob\location-NAmEN.txt"
		#	SetOutPath "$ExSrvDir\Software\ResultsManager\web"
		#	File /r /x *.svn* "Update\ItsYourJob\ResultsManager\web\*"
		
		## Why are we waiting here for 4.5 seconds?
		sleep 4500
NextStep:
	; Start clarity web services
	ExecWait 'sc start ClarityWebSrv'
	## Why are we waiting here for 4.5 seconds? Doesn't ExecWait take as long as it needs?
	sleep 4500
	
	; Do registration
    ExecWait '$INSTDIR\${FolderName}\registerws.exe "ASerial=$ASerial&ALang=$ALang&AHost=http://$LocalIp:$inputPort"'
    WriteRegStr HKLM "${REGKEY}\Components" Main 1
SectionEnd

Section -post SEC0001
    WriteRegStr HKLM "${REGKEY}" Path $INSTDIR
    SetOutPath $INSTDIR
    CreateShortcut "$INSTDIR\$(^Name).lnk" "http://$LocalIp:$InputPort/${FolderName}/" "" "$INSTDIR\${FolderName}\${ShortName}.ico"
    WriteUninstaller "$INSTDIR\${FolderName}\uninstall.exe"
    !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
    SetOutPath $SMPROGRAMS\$StartMenuGroup
    SetShellVarContext all
    CreateShortcut "$SMPROGRAMS\$StartMenuGroup\Uninstall $(^Name).lnk" $INSTDIR\${FolderName}\uninstall.exe
    CreateShortcut "$SMPROGRAMS\$StartMenuGroup\$(^Name).lnk" "http://$LocalIp:$InputPort/${FolderName}/" "" "$INSTDIR\${FolderName}\${ShortName}.ico"
    CreateShortcut "$DESKTOP\$(^Name).lnk" "http://$LocalIp:$InputPort/${FolderName}/" "" "$INSTDIR\${FolderName}\${ShortName}.ico"
    !insertmacro MUI_STARTMENU_WRITE_END
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" DisplayName "$(^Name)"
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" DisplayVersion "${VERSION}"
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" Publisher "${COMPANY}"
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" URLInfoAbout "${URL}"
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" DisplayIcon $INSTDIR\${FolderName}\uninstall.exe
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" UninstallString $INSTDIR\${FolderName}\uninstall.exe
    WriteRegDWORD HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" NoModify 1
    WriteRegDWORD HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" NoRepair 1
    
    ; We need copy the uninstall.exe in the final version, because Sony SecureRom will break uninstall.exe.
	; The process is that you will run this installation once with the following commented out.
	; This creates a standard uninstaller. Then copy that into \ActiveReading folder
	; Uncomment this, which will then overwrite the created one with the preset one.
    ;SetOutPath $INSTDIR\${FolderName}
    ;File "${FolderName}\uninstall.exe"
SectionEnd

# Macro for selecting uninstaller sections
!macro SELECT_UNSECTION SECTION_NAME UNSECTION_ID
    Push $R0
    ReadRegStr $R0 HKLM "${REGKEY}\Components" "${SECTION_NAME}"
    StrCmp $R0 1 0 next${UNSECTION_ID}
    !insertmacro SelectSection "${UNSECTION_ID}"
    GoTo done${UNSECTION_ID}
next${UNSECTION_ID}:
    !insertmacro UnselectSection "${UNSECTION_ID}"
done${UNSECTION_ID}:
    Pop $R0
!macroend

# Uninstaller sections
Section -un.Main UNSEC0000
    MessageBox MB_YESNO \
	"The Clarity webserver may be needed to run Clarity programs as well. If you uninstall it now it will not be available for other programs. \
	$\n$\nDo you want to remove the webserver?" \
	IDYES SRVUNIT IDNO SRVNOTUNIT
SRVUNIT:
    ExecWait 'sc.exe stop ClarityWebSrv'
    ExecWait 'sc.exe delete ClarityWebSrv'
    sleep 3000
    RmDir /r "$INSTDIR\WebServices"
SRVNOTUNIT:
	IfFileExists "$ExSrvDir\WebServices\conf\backup\httpd.conf.${ShortName}.bak" 0 UNCON
		ExecWait 'sc.exe stop ClarityWebSrv'
		Delete "$ExSrvDir\WebServices\conf\httpd.conf"
		CopyFiles "$ExSrvDir\WebServices\conf\backup\httpd.conf.${ShortName}.bak" "$ExSrvDir\WebServices\conf"
		Rename "$ExSrvDir\WebServices\conf\httpd.conf.${ShortName}.bak" "$ExSrvDir\WebServices\conf\httpd.conf"
		Delete "$ExSrvDir\WebServices\conf\backup\httpd.conf.${ShortName}.bak"
		sleep 6000
		ExecWait 'sc.exe start ClarityWebSrv'
UNCON:
    RmDir /r "$INSTDIR\Content\${FolderName}"
    RmDir /r "$INSTDIR\Software\${FolderName}"
    DeleteRegValue HKLM "${REGKEY}\Components" Main
SectionEnd

Section -un.post UNSEC0001
    DeleteRegKey HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)"
    SetShellVarContext all
    Delete "$SMPROGRAMS\$StartMenuGroup\Uninstall $(^Name).lnk"
    Delete "$SMPROGRAMS\$StartMenuGroup\$(^Name).lnk"
    Delete "$DESKTOP\$(^Name).lnk"
    Delete "$INSTDIR\$(^Name).lnk"
    Delete $INSTDIR\${FolderName}\uninstall.exe
	RmDir /r "$INSTDIR\${FolderName}"
    DeleteRegValue HKLM "${REGKEY}" StartMenuGroup
    DeleteRegValue HKLM "${REGKEY}" Path
    DeleteRegKey /IfEmpty HKLM "${REGKEY}\Components"
    DeleteRegKey /IfEmpty HKLM "${REGKEY}"
    RmDir $SMPROGRAMS\$StartMenuGroup
    ;RmDir $INSTDIR
SectionEnd

# Installer call functions
Function .onInit
    InitPluginsDir
    ;============================================= 
    ;Get the server ip
    ip::get_ip
    Pop $0
	Loop:
		Push $0
		Call GetNextIp
		Call CheckIp
		Pop $2 ; Type of current IP-address
		Pop $1 ; Current IP-address
		Pop $0 ; Remaining addresses
		StrCmp $2 '1' '' NoLoopBackIp
			StrCpy $LocalIp "127.0.0.1"
			Goto Continue
	NoLoopBackIp:
		StrCmp $2 '2' '' NoAPA
			StrCpy $LocalIp "127.0.0.1"
			Goto Continue
	NoAPA:
		StrCmp $2 '3' '' NoLanIp
			StrCpy $LocalIp $1
			Goto ExitLoop
	NoLanIp:
		StrCpy $LocalIp "127.0.0.1"
	Continue:
		StrCmp $0 '' ExitLoop Loop
	ExitLoop:
    ;StrCpy $LocalIp $1
    ;=============================================
    StrCpy $InputPort "10082"
    StrCpy $ALang "EN"
    ReadRegStr $R0 HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" "UninstallString" 
    StrCmp $R0 "" NotInstalled 
        MessageBox MB_OKCANCEL|MB_ICONEXCLAMATION \
		"$(^Name) is already installed. $\n$\nClick `OK` to upgrade the \
		previous version or `Cancel` to cancel this upgrade." \
		IDOK uninst
		Abort
uninst:
	ClearErrors
    ExecWait '$R0 _?=$INSTDIR'
    IfErrors no_remove_uninstaller NotInstalled
    
    no_remove_uninstaller:
    ;Abort
NotInstalled: 

	## Road to IELTS 2 doesn't have a languageVersion as such. it just uses productCode
    #StrCpy $1 ${SEC01}
    #StrCpy $LangVersion $1
;    # Get the parameters from flash
;    ;ASerial=111-1111-1111 AProductCode=20 AUsers=10
    ${GetParameters} $R0
;    ${GetOptions} $R0 "/opi=" $R4
;    StrCmp $R4 "87134509873149087hgr" +3 0
;        MessageBox MB_OK "Please run the setup using the main Setup.exe program on the CD."
;        Abort
    ${GetOptions} $R0 "/ASerial=" $R1
    StrCmp $R1 "" 0 +3
        MessageBox MB_OK "Please run the setup using the main Setup.exe program on the CD."
        Abort
    ${GetOptions} $R0 "/AProductCode=" $R2
    ${GetOptions} $R0 "/AUsers=" $R3
    ;Call GetParameters
    StrCpy $ASerial $R1
    StrCpy $AProductCode $R2
    StrCpy $AUsers $R3
    
    SimpleSC::GetServiceBinaryPath "ClarityWebSrv"
    Pop $0
    Pop $1
    StrCmp $0 "0" ExistSrv NotExistSrv
ExistSrv:
	${WordFind} "$1" "\" "-4{*" $1 ; Get the web service root folder
	StrCpy $ServerDesc \
			"Setup will install the Clarity software in the following folder. \
			To install in a different folder, click Browse and select another folder. \
			Click Next to continue.$\r$\n\
			$\r$\n\
			You already have a Clarity web service.$\r$\n\
			We recommend you install the current program into the same Clarity folder $1"
	StrCpy $ExSrvDir $1
	StrCpy $INSTDIR $ExSrvDir
	StrCpy $isSrvEx "True"
	Goto MainContinue
NotExistSrv:
	StrCpy $ServerDesc \
			"Setup will install the Clarity software in the following folder. \
			To install in a different folder, click Browse and select another folder. \
			Click Next to continue."
MainContinue:
FunctionEnd

# Uninstaller callback function
Function un.onInit
    ReadRegStr $INSTDIR HKLM "${REGKEY}" Path
    !insertmacro MUI_STARTMENU_GETFOLDER Application $StartMenuGroup
    !insertmacro SELECT_UNSECTION Main ${UNSEC0000}
FunctionEnd

# Functions
Function PAGE_INSTALLTYPE
  # If you need to skip the page depending on a condition, call Abort.
  ReserveFile "page_inst.ini"
  !insertmacro MUI_INSTALLOPTIONS_EXTRACT "page_inst.ini"
  !insertmacro MUI_HEADER_TEXT "Installation method" "If you want to change the configuration of the webserver used for this network program, please choose advanced."
  !insertmacro MUI_INSTALLOPTIONS_DISPLAY "page_inst.ini"
FunctionEnd

Function PAGE_INSTALLTYPE_LEAVE
  # If you need to skip the page depending on a condition, call Abort.
  !insertmacro MUI_INSTALLOPTIONS_READ $INSTVAL "page_inst.ini" "Field 1" "State"
FunctionEnd

Function PAGE_WEBSETTING
  # If you need to skip the page depending on a condition, call Abort.
  StrCmp $INSTVAL 0 SHOWPAGE HIDEPAGE
  SHOWPAGE:
  	ReserveFile "IP_Address_Page.ini"
  	!insertmacro MUI_INSTALLOPTIONS_EXTRACT "IP_Address_Page.ini"
  	!insertmacro MUI_HEADER_TEXT "Advanced installation" "Please set the server configuration"
  	!insertmacro MUI_INSTALLOPTIONS_WRITE "IP_Address_Page.ini" "Field 1" "State" $LocalIp
  	!insertmacro MUI_INSTALLOPTIONS_WRITE "IP_Address_Page.ini" "Field 3" "State" $InputPort
  	!insertmacro MUI_INSTALLOPTIONS_DISPLAY "IP_Address_Page.ini"
  HIDEPAGE:
FunctionEnd
 
Function PAGE_WEBSETTING_LEAVE
  # Form validation here. Call Abort to go back to the page.
  # Use !insertmacro MUI_INSTALLOPTIONS_READ $Var "InstallOptionsFile.ini" ...
  # to get values.
  !insertmacro MUI_INSTALLOPTIONS_READ $LocalIp "IP_Address_Page.ini" "Field 1" "State"
  !insertmacro MUI_INSTALLOPTIONS_READ $InputPort "IP_Address_Page.ini" "Field 3" "State"
FunctionEnd

## Road to IELTS 2 doesn't offer this option
#Function .onSelChange
#	!insertmacro StartRadioButtons $1
#	!insertmacro RadioButton ${SEC01}
#	!insertmacro RadioButton ${SEC02}
#	!insertmacro EndRadioButtons
#	StrCpy $LangVersion $1
#FunctionEnd
Function LaunchLink
	ExecShell "open" "http://$LocalIp:$InputPort/${FolderName}/"
FunctionEnd