#
# Content installation for Road to IELTS 2
#
# Input: /AINSTDIR="c:\Clarity" /AProductCode=52
 
Name "Road to IELTS 2"

## For testing to keep the content file small(ish)
!define SmallContent "true"

# General Symbol Definitions
!define FolderName "RoadToIELTS2"
!define ShortName "R2IV2"
!define Icon "${FolderName}\${ShortName}.ico"
!define REGKEY "SOFTWARE\$(^Name)"
!define VERSION 2.0
!define COMPANY "Clarity Language Consultants Ltd"
!define URL "http://www.ClarityEnglish.com"

# MUI Symbol Definitions
!define MUI_ICON "${Icon}"
!define MUI_WELCOMEFINISHPAGE_BITMAP ${FolderName}\Setup_${ShortName}.bmp

!define MUI_PAGE_HEADER_TEXT "Content installation"
!define MUI_DIRECTORYPAGE_TEXT_TOP $ServerDesc

# Included files
!include "Sections.nsh"
!include "MUI.nsh"
!include "FileFunc.nsh"
!include "TextFunc.nsh"
!include "LogicLib.nsh"

# Variables
Var InstallDir
Var ProductCode

!insertmacro MUI_PAGE_INSTFILES

# Installer languages
!insertmacro MUI_LANGUAGE English

BrandingText "${COMPANY}"
OutFile ..\MakeCD\${FolderName}\Install\ContentSetup.exe
InstallDir C:\Clarity ; default installation folder
CRCCheck on
XPStyle on
ShowInstDetails show
VIProductVersion 1.0.0.0
VIAddVersionKey ProductName "${Name} content"
VIAddVersionKey ProductVersion "${VERSION}"
VIAddVersionKey CompanyName "${COMPANY}"
VIAddVersionKey CompanyWebsite "${URL}"
VIAddVersionKey FileVersion "${VERSION}"
VIAddVersionKey FileDescription ""
VIAddVersionKey LegalCopyright ""
InstallDirRegKey HKLM "${REGKEY}" Path
ShowUninstDetails show
AutoCloseWindow True

# Installer sections
Section -Main SEC0000
    SetOutPath $InstallDir
    SetOutPath $InstallDir\Content
    # Copy from an svn folder, D:\ContentBench\Content
	# Adrian. exclude svn files, shouldn't be any other rubbish files in this folder, but just in case(thumbs.db etc)
	##
	## Bug, I can't get LogicLib to work, the blocks are just ignored and everything is done
	## Duh. LogicLib is for run time conditionals. Here I want compile time conditions!
	!if ${SmallContent} == "true"
		File /r /x *.svn* /x Thumbs.db "D:\ContentBench\Content\${FolderName}\*.xml" 
	!else
		File /r /x *.svn* /x Thumbs.db "D:\ContentBench\Content\${FolderName}\*" 
	!endif
SectionEnd

# Installer functions
Function .onInit
    InitPluginsDir
    ${GetParameters} $R0
    ${GetOptions} $R0 "/AINSTDIR=" $R1
    ${GetOptions} $R0 "/AProductCode=" $R2
    StrCpy $InstallDir $R1
    StrCpy $ProductCode $R2
    ${If} $InstallDir == ""
        MessageBox MB_OK "Please run from the main Setup.exe program on the CD."
        Abort
    ${ElseIfNot} $ProductCode > 1
        MessageBox MB_OK "Please run from the main Setup.exe program on the CD."
        Abort
	${EndIf}
FunctionEnd
