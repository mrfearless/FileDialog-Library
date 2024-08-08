;==============================================================================
;
; FileDialog x86 Library Test Dialog
;
; http://github.com/mrfearless/FileDialog-Library
;
; This software is provided 'as-is', without any express or implied warranty. 
; In no event will the author be held liable for any damages arising from the 
; use of this software.
;
;==============================================================================

include windows.inc
include user32.inc
include kernel32.inc
include gdi32.inc
include shell32.inc
include comctl32.inc

includelib user32.lib
includelib kernel32.lib
includelib gdi32.lib
includelib shell32.lib
includelib comctl32.lib

include FileDialog.inc
includelib FileDialog.lib

;------------------------------------------------------------------------------
; FileDialogTest Prototypes
;------------------------------------------------------------------------------
WinMain                 PROTO :DWORD,:DWORD,:DWORD,:DWORD
WndProc                 PROTO :DWORD,:DWORD,:DWORD,:DWORD
InitGUI                 PROTO hWin:DWORD
ParseFileArray          PROTO hWin:DWORD, hEditControl:DWORD, dwFilenames:DWORD, lpArrayOfFilenames:DWORD, bWide:DWORD


.CONST
;------------------------------------------------------------------------------
; FileDialogTest Constants
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
; FileDialogTest Initialized Data
;------------------------------------------------------------------------------
ClassName               DB 'DLGCLASS',0
AppName                 DB 'FileDialog x86 Library Test',0
AboutMsg                DB 'github.com/mrfearless/FileDialog-Library',0

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

dwFileNameCount         DD 0
FileNameArrayA          DD 0
szOpenFileNameA         DD 0
szSaveFileNameA         DD 0
szFolderNameA           DD 0

FileNameArrayW          DD 0
szOpenFileNameW         DD 0
szSaveFileNameW         DD 0
szFolderNameW           DD 0

FileNameBuffer          DB 512 DUP (0)

ALIGN 4
szWideClassEdit         DB 'E',0,'d',0,'i',0,'t',0,0,0,0


.DATA?
;------------------------------------------------------------------------------
; FileDialogTest Uninitialized Data
;------------------------------------------------------------------------------
icc                     INITCOMMONCONTROLSEX <>
hInstance               DD ?
CommandLine             DD ?
hWnd                    DD ?
hIcoMain                DD ?
hEdtOpenFileA           DD ?
hEdtSaveFileA           DD ?
hEdtSelectFolderA       DD ?
hEdtOpenFilesA          DD ?

hEdtOpenFileW           DD ?
hEdtSaveFileW           DD ?
hEdtSelectFolderW       DD ?
hEdtOpenFilesW          DD ?

hLblA					DD ?
hLblW					DD ?
hLblAnsi                DD ?
hLblWide                DD ?

hLabelAWFont            DD ?

