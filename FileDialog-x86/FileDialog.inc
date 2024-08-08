;==============================================================================
;
; FileDialog x86 Library
;
; http://github.com/mrfearless
;
; This software is provided 'as-is', without any express or implied warranty. 
; In no event will the author be held liable for any damages arising from the 
; use of this software.
;
;==============================================================================

;------------------------------------------------------------------------------
; FileDialog Prototypes
;------------------------------------------------------------------------------
FileOpenDialogA     PROTO lpszTitle:DWORD, lpszOkLabel:DWORD, lpszFileLabel:DWORD, lpszFolder:DWORD, nMFS:DWORD, pMFS:DWORD, hWndOwner:DWORD, bMulti:DWORD, lpdwFiles:DWORD, lpFilesArray:DWORD
FileOpenDialogW     PROTO lpszTitle:DWORD, lpszOkLabel:DWORD, lpszFileLabel:DWORD, lpszFolder:DWORD, nMFS:DWORD, pMFS:DWORD, hWndOwner:DWORD, bMulti:DWORD, lpdwFiles:DWORD, lpFilesArray:DWORD

FileSaveDialogA     PROTO lpszTitle:DWORD, lpszOkLabel:DWORD, lpszFileLabel:DWORD, lpszFolder:DWORD, nMFS:DWORD, pMFS:DWORD, hWndOwner:DWORD, bWarn:DWORD, lpszFileName:DWORD, lpdwSaveFile:DWORD
FileSaveDialogW     PROTO lpszTitle:DWORD, lpszOkLabel:DWORD, lpszFileLabel:DWORD, lpszFolder:DWORD, nMFS:DWORD, pMFS:DWORD, hWndOwner:DWORD, bWarn:DWORD, lpszFileName:DWORD, lpdwSaveFile:DWORD

FolderSelectDialogA PROTO lpszTitle:DWORD, lpszOkLabel:DWORD, lpszFileLabel:DWORD, lpszFolder:DWORD, hWndOwner:DWORD, lpdwFolder:DWORD
FolderSelectDialogW PROTO lpszTitle:DWORD, lpszOkLabel:DWORD, lpszFileLabel:DWORD, lpszFolder:DWORD, hWndOwner:DWORD, lpdwFolder:DWORD



IFDEF __UNICODE__
    FileOpenDialog      EQU <FileOpenDialogW>
    FileSaveDialog      EQU <FileSaveDialogW>
    FolderSelectDialog  EQU <FolderSelectDialogW>
ELSE ; ANSI
    FileOpenDialog      EQU <FileOpenDialogA>
    FileSaveDialog      EQU <FileSaveDialogA>
    FolderSelectDialog  EQU <FolderSelectDialogA>
ENDIF

;------------------------------------------------------------------------------
; FileDialog Structures
;------------------------------------------------------------------------------
IFNDEF COMDLG_FILTERSPEC
COMDLG_FILTERSPEC STRUCT
    pszName       DD ?
    pszSpec       DD ?
COMDLG_FILTERSPEC ENDS
ENDIF

