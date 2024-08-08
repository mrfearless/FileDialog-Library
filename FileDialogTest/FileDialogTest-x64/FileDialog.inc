;==============================================================================
;
; FileDialog x64 Library
;
; http://github.com/mrfearless/FileDialog-Library
;
; This software is provided 'as-is', without any express or implied warranty. 
; In no event will the author be held liable for any damages arising from the 
; use of this software.
;
;==============================================================================

;------------------------------------------------------------------------------
; FileDialog Prototypes
;------------------------------------------------------------------------------
FileOpenDialogA     PROTO lpszTitle:QWORD, lpszOkLabel:QWORD, lpszFileLabel:QWORD, lpszFolder:QWORD, nMFS:QWORD, pMFS:QWORD, hWndOwner:QWORD, bMulti:QWORD, lpdwFiles:QWORD, lpFilesArray:QWORD
FileOpenDialogW     PROTO lpszTitle:QWORD, lpszOkLabel:QWORD, lpszFileLabel:QWORD, lpszFolder:QWORD, nMFS:QWORD, pMFS:QWORD, hWndOwner:QWORD, bMulti:QWORD, lpdwFiles:QWORD, lpFilesArray:QWORD

FileSaveDialogA     PROTO lpszTitle:QWORD, lpszOkLabel:QWORD, lpszFileLabel:QWORD, lpszFolder:QWORD, nMFS:QWORD, pMFS:QWORD, hWndOwner:QWORD, bWarn:QWORD, lpszFileName:QWORD, lpdwSaveFile:QWORD
FileSaveDialogW     PROTO lpszTitle:QWORD, lpszOkLabel:QWORD, lpszFileLabel:QWORD, lpszFolder:QWORD, nMFS:QWORD, pMFS:QWORD, hWndOwner:QWORD, bWarn:QWORD, lpszFileName:QWORD, lpdwSaveFile:QWORD

FolderSelectDialogA PROTO lpszTitle:QWORD, lpszOkLabel:QWORD, lpszFileLabel:QWORD, lpszFolder:QWORD, hWndOwner:QWORD, lpdwFolder:QWORD
FolderSelectDialogW PROTO lpszTitle:QWORD, lpszOkLabel:QWORD, lpszFileLabel:QWORD, lpszFolder:QWORD, hWndOwner:QWORD, lpdwFolder:QWORD



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
    pszName       DQ ?
    pszSpec       DQ ?
COMDLG_FILTERSPEC ENDS
ENDIF

