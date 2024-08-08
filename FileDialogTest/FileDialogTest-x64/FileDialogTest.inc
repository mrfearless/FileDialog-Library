;==============================================================================
;
; FileDialog x64 Library Test Dialog
;
; http://github.com/mrfearless/FileDialog-Library
;
; This software is provided 'as-is', without any express or implied warranty. 
; In no event will the author be held liable for any damages arising from the 
; use of this software.
;
;==============================================================================

include windows.inc
include CommCtrl.inc
include shellapi.inc

includelib user32.lib
includelib kernel32.lib
includelib gdi32.lib
includelib comctl32.lib
includelib shell32.lib

include FileDialog.inc
includelib FileDialog.lib

;------------------------------------------------------------------------------
; IFDTest Prototypes
;------------------------------------------------------------------------------
InitGUI                 PROTO hWin:QWORD
ParseFileArray          PROTO hWin:QWORD, hEditControl:QWORD, qwFilenames:QWORD, lpArrayOfFilenames:QWORD, bWide:QWORD



.CONST
;------------------------------------------------------------------------------
; IFDTest Constants
;------------------------------------------------------------------------------
ICO_MAIN                        EQU 100

; Main Dialog
IDD_DIALOG                      EQU 1000
IDC_BtnExit                     equ 1001
IDC_StatusBar                   equ 1002
IDC_BtnOpenFileA                equ 1003
IDC_BtnOpenFilesA               equ 1004
IDC_BtnSaveFileA                equ 1005
IDC_BtnSaveFileW                equ 1006
IDC_BtnOpenFilesW               equ 1007
IDC_BtnOpenFileW                equ 1008
IDC_BtnSelectFolderA            equ 1009
IDC_BtnSelectFolderW            equ 1010
IDC_EdtOpenFileA                equ 1011
IDC_EdtSaveFileA                equ 1012
IDC_EdtSelectFolderA            equ 1013
IDC_EdtOpenFilesA               equ 1014
IDC_SHP1                        equ 1015
IDC_SHP2                        equ 1016
IDC_SHP3                        equ 1017
IDC_LblAnsi						equ 1018
IDC_LblWide                     equ 1019
IDC_EdtOpenFileW                equ 1021
IDC_EdtSaveFileW                equ 1022
IDC_EdtSelectFolderW            equ 1023
IDC_EdtOpenFilesW               equ 1024
IDC_LblA						equ 1020
IDC_LblW						equ 1025

; Main Menu 
IDM_MENU                EQU 10000
IDM_FILE_EXIT           EQU 10001
IDM_HELP_ABOUT          EQU 10101

.DATA
;------------------------------------------------------------------------------
; IFDTest Initialized Data
;------------------------------------------------------------------------------
align 01
szClass					db 'Win64class', 0
szAppName				db 'FileDialog x64 Library Test', 0

ClassName				DB 'DLGCLASS',0
AppName					DB 'FileDialog x64 Library Test',0
AboutMsg				DB 'github.com/mrfearless/FileDialog-Library',0

; Ansi strings
szOpenTitle             DB 'Open A Test File',0
szSaveTitle             DB 'Save A Test File As',0
szFolderTitle           DB 'Select A Test Folder',0
szTempFolder            DB 'C:\Temp',0
szDefaultSaveAsItem     DB 'NewFile-Test.txt',0
szOpenOkButton          DB 'Okey Dokey',0
szOpenFileLabel         DB 'Open File: ',0
szSaveOkButton          DB 'Save It!',0
szSaveFileLabel         DB 'Save File:',0
szFolderOkButton        DB 'Pick Folder',0
szFolderLabel           DB 'Folder Name: ',0

; Wide strings
szOpenTitleW            DB 'O',0,'p',0,'e',0,'n',0,' ',0,'A',0,' ',0,'T',0,'e',0,'s',0,'t',0,' ',0,'F',0,'i',0,'l',0,'e',0
                        DB 0,0,0,0
szSaveTitleW            DB 'S',0,'a',0,'v',0,'e',0,' ',0,'A',0,' ',0,'T',0,'e',0,'s',0,'t',0,' ',0,'F',0,'i',0,'l',0,'e',0,' ',0,'A',0,'s',0
                        DB 0,0,0,0
szFolderTitleW          DB 'S',0,'e',0,'l',0,'e',0,'c',0,'t',0,' ',0,'A',0,' ',0,'T',0,'e',0,'s',0,'t',0,' ',0,'F',0,'o',0,'l',0,'d',0,'e',0,'r',0
                        DB 0,0,0,0
szTempFolderW           DB 'C',0,':',0,'\',0,'T',0,'e',0,'m',0,'p',0
                        DB 0,0,0,0
szDefaultSaveAsItemW    DB 'N',0,'e',0,'w',0,'F',0,'i',0,'l',0,'e',0,'-',0
                        DB 'T',0,'e',0,'s',0,'t',0,'.',0,'t',0,'x',0,'t',0
                        DB 0,0,0,0
szOpenOkButtonW         DB 'O',0,'k',0,'e',0,'y',0,' ',0,'D',0,'o',0,'k',0,'e',0,'y',0
                        DB 0,0,0,0
szOpenFileLabelW        DB 'O',0,'p',0,'e',0,'n',0,' ',0,'F',0,'i',0,'l',0,'e',0,':',0,' ',0
                        DB 0,0,0,0
szSaveOkButtonW         DB 'S',0,'a',0,'v',0,'e',0,' ',0,'I',0,'t',0,'!',0
                        DB 0,0,0,0
szSaveFileLabelW        DB 'S',0,'a',0,'v',0,'e',0,' ',0,'F',0,'i',0,'l',0,'e',0,':',0
                        DB 0,0,0,0
szFolderOkButtonW       DB 'P',0,'i',0,'c',0,'k',0,' ',0,'F',0,'o',0,'l',0,'d',0,'e',0,'r',0
                        DB 0,0,0,0
szFolderLabelW          DB 'F',0,'o',0,'l',0,'d',0,'e',0,'r',0,' ',0,'N',0,'a',0,'m',0,'e',0,':',0
                        DB 0,0,0,0

szFont                  DB 'Times New Roman',0 ;'Segoe UI',0
szCRLF                  DB 13,10,0

qwFileNameCount         DQ 0
FileNameArrayA          DQ 0
szOpenFileNameA         DQ 0
szSaveFileNameA         DQ 0
szFolderNameA           DQ 0

FileNameArrayW          DQ 0
szOpenFileNameW         DQ 0
szSaveFileNameW         DQ 0
szFolderNameW           DQ 0

szWideClassEdit         DB 'E',0,'d',0,'i',0,'t',0,0,0,0

.DATA?
;------------------------------------------------------------------------------
; IFDTest Uninitialized Data
;------------------------------------------------------------------------------
align 08
icc 					INITCOMMONCONTROLSEX <>
hInstance				HINSTANCE ?
CommandLine				LPSTR ?
hWnd					HWND ?
hIcoMain                DQ ?

hEdtOpenFileA           DQ ?
hEdtSaveFileA           DQ ?
hEdtSelectFolderA       DQ ?
hEdtOpenFilesA          DQ ?

hEdtOpenFileW           DQ ?
hEdtSaveFileW           DQ ?
hEdtSelectFolderW       DQ ?
hEdtOpenFilesW          DQ ?


hLblA					DQ ?
hLblW					DQ ?
hLblAnsi                DQ ?
hLblWide                DQ ?

hLabelAWFont            DQ ?




