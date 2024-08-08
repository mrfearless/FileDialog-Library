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
.686
.MMX
.XMM
.model flat,stdcall
option casemap:none
include \masm32\macros\macros.asm

;DEBUG32 EQU 1
;
;IFDEF DEBUG32
;    PRESERVEXMMREGS equ 1
;    includelib M:\Masm32\lib\Debug32.lib
;    DBG32LIB equ 1
;    DEBUGEXE textequ <'M:\Masm32\DbgWin.exe'>
;    include M:\Masm32\include\debug32.inc
;    include msvcrt.inc
;    includelib ucrt.lib
;    includelib vcruntime.lib
;    
;ENDIF

include FileDialogTest.inc

.code

start:

    Invoke GetModuleHandle, NULL
    mov hInstance, eax
    Invoke GetCommandLine
    mov CommandLine, eax
    Invoke InitCommonControls
    mov icc.dwSize, sizeof INITCOMMONCONTROLSEX
    mov icc.dwICC, ICC_COOL_CLASSES or ICC_STANDARD_CLASSES or ICC_WIN95_CLASSES
    Invoke InitCommonControlsEx, Offset icc
    
    Invoke WinMain, hInstance, NULL, CommandLine, SW_SHOWDEFAULT
    Invoke ExitProcess, eax

;------------------------------------------------------------------------------
; WinMain
;------------------------------------------------------------------------------
WinMain PROC hInst:HINSTANCE, hPrevInst:HINSTANCE, CmdLine:LPSTR, CmdShow:DWORD
    LOCAL wc:WNDCLASSEX
    LOCAL msg:MSG

    mov wc.cbSize, SIZEOF WNDCLASSEX
    mov wc.style, CS_HREDRAW or CS_VREDRAW
    mov wc.lpfnWndProc, Offset WndProc
    mov wc.cbClsExtra, NULL
    mov wc.cbWndExtra, DLGWINDOWEXTRA
    push hInst
    pop wc.hInstance
    mov wc.hbrBackground, COLOR_BTNFACE+1 ; COLOR_WINDOW+1
    mov wc.lpszMenuName, IDM_MENU
    mov wc.lpszClassName, Offset ClassName
    Invoke LoadIcon, hInstance, ICO_MAIN ; resource icon for main application icon
    mov hIcoMain, eax ; main application icon
    mov wc.hIcon, eax
    mov wc.hIconSm, eax
    Invoke LoadCursor, NULL, IDC_ARROW
    mov wc.hCursor,eax
    Invoke RegisterClassEx, Addr wc
    Invoke CreateDialogParam, hInstance, IDD_DIALOG, NULL, Addr WndProc, NULL
    mov hWnd, eax
    Invoke ShowWindow, hWnd, SW_SHOWNORMAL
    Invoke UpdateWindow, hWnd
    .WHILE TRUE
        Invoke GetMessage, Addr msg, NULL, 0, 0
        .BREAK .if !eax
        Invoke IsDialogMessage, hWnd, Addr msg
        .IF eax == 0
            Invoke TranslateMessage, Addr msg
            Invoke DispatchMessage, Addr msg
        .ENDIF
    .ENDW
    mov eax, msg.wParam
    ret
WinMain ENDP


;------------------------------------------------------------------------------
; WndProc - Main Window Message Loop
;------------------------------------------------------------------------------
WndProc PROC hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    
    mov eax, uMsg
    .IF eax == WM_INITDIALOG
        ; Init Stuff Here
        Invoke InitGUI, hWin
        
    .ELSEIF eax == WM_COMMAND
        mov eax, wParam
        and eax, 0FFFFh
        .IF eax == IDM_FILE_EXIT || eax == IDC_BtnExit
            Invoke SendMessage, hWin, WM_CLOSE, 0, 0
            
        .ELSEIF eax == IDM_HELP_ABOUT
            Invoke ShellAbout, hWin, Addr AppName, Addr AboutMsg,NULL
            
        ;----------------------------------------------------------------------
        ; Open a single file using Ansi version of FileOpenDialog
        ;----------------------------------------------------------------------
        .ELSEIF eax == IDC_BtnOpenFileA
            Invoke FileOpenDialogA, Addr szOpenTitle, Addr szOpenOkButton, Addr szOpenFileLabel, Addr szTempFolder, 0, NULL, hWin, FALSE, Addr dwFileNameCount, Addr szOpenFileNameA
            .IF eax == TRUE
                .IF dwFileNameCount != 0 && szOpenFileNameA != 0
                    Invoke SendMessage, hEdtOpenFileA, WM_SETTEXT, 0, 0
                    Invoke SendMessage, hEdtOpenFileA, WM_SETTEXT, 0, szOpenFileNameA
                    Invoke GlobalFree, szOpenFileNameA
                    mov szOpenFileNameA, 0
                .ELSE
                    Invoke SendMessage, hEdtOpenFileA, WM_SETTEXT, 0, 0
                .ENDIF
            .ENDIF
        
        ;----------------------------------------------------------------------
        ; Save a single file using Ansi version of FileSaveDialog
        ;----------------------------------------------------------------------
        .ELSEIF eax == IDC_BtnSaveFileA
            Invoke FileSaveDialogA, Addr szSaveTitle, Addr szSaveOkButton, Addr szSaveFileLabel, Addr szTempFolder, 0, NULL, hWin, TRUE, Addr szDefaultSaveAsItem, Addr szSaveFileNameA
            .IF eax == TRUE
                .IF szSaveFileNameA != 0
                    Invoke SendMessage, hEdtSaveFileA, WM_SETTEXT, 0, 0
                    Invoke SendMessage, hEdtSaveFileA, WM_SETTEXT, 0, szSaveFileNameA
                    Invoke GlobalFree, szSaveFileNameA
                    mov szSaveFileNameA, 0
                .ELSE
                    Invoke SendMessage, hEdtSaveFileA, WM_SETTEXT, 0, 0
                .ENDIF
            .ENDIF
        
        ;----------------------------------------------------------------------
        ; Select a single folder using Ansi version of FolderSelectDialog
        ;----------------------------------------------------------------------
        .ELSEIF eax == IDC_BtnSelectFolderA
            Invoke FolderSelectDialogA, NULL, Addr szFolderOkButton, NULL, NULL, hWin, Addr szFolderNameA
            .IF eax == TRUE
                .IF szFolderNameA != 0
                    Invoke SendMessage, hEdtSelectFolderA, WM_SETTEXT, 0, 0
                    Invoke SendMessage, hEdtSelectFolderA, WM_SETTEXT, 0, szFolderNameA
                    Invoke GlobalFree, szFolderNameA
                    mov szFolderNameA, 0
                .ELSE
                    Invoke SendMessage, hEdtSelectFolderA, WM_SETTEXT, 0, 0
                .ENDIF
            .ENDIF
            
        ;----------------------------------------------------------------------
        ; Open multiple files using Ansi version of FileOpenDialog
        ;----------------------------------------------------------------------
        .ELSEIF eax == IDC_BtnOpenFilesA
            Invoke FileOpenDialogA, NULL, NULL, NULL, NULL, 0, NULL, hWin, TRUE, Addr dwFileNameCount, Addr FileNameArrayA
            .IF eax == TRUE
                .IF dwFileNameCount != 0 && FileNameArrayA != 0
                    Invoke SendMessage, hEdtOpenFilesA, WM_SETTEXT, 0, 0
                    Invoke ParseFileArray, hWin, hEdtOpenFilesA, dwFileNameCount, FileNameArrayA, FALSE
                    Invoke GlobalFree, FileNameArrayA
                    mov FileNameArrayA, 0
                .ELSE
                    Invoke SendMessage, hEdtOpenFilesA, WM_SETTEXT, 0, 0
                .ENDIF
            .ENDIF
        
        ;----------------------------------------------------------------------
        ; Open a single file using Wide version of FileOpenDialog
        ;----------------------------------------------------------------------
        .ELSEIF eax == IDC_BtnOpenFileW
            Invoke FileOpenDialogW, Addr szOpenTitleW, Addr szOpenOkButtonW, Addr szOpenFileLabelW, Addr szTempFolderW, 0, NULL, hWin, FALSE, Addr dwFileNameCount, Addr szOpenFileNameW
            .IF eax == TRUE
                .IF dwFileNameCount != 0 && szOpenFileNameW != 0
                    Invoke SendMessage, hEdtOpenFileW, WM_SETTEXT, 0, 0
                    Invoke SendMessageW, hEdtOpenFileW, WM_SETTEXT, 0, szOpenFileNameW
                    Invoke GlobalFree, szOpenFileNameW
                    mov szOpenFileNameW, 0
                .ELSE
                    Invoke SendMessageW, hEdtOpenFileW, WM_SETTEXT, 0, 0
                .ENDIF
            .ENDIF
            
        ;----------------------------------------------------------------------
        ; Save a single file using Wide version of FileSaveDialog
        ;----------------------------------------------------------------------
        .ELSEIF eax == IDC_BtnSaveFileW
            Invoke FileSaveDialogW, Addr szSaveTitleW, Addr szSaveOkButtonW, Addr szSaveFileLabelW, Addr szTempFolderW, 0, NULL, hWin, TRUE, Addr szDefaultSaveAsItemW, Addr szSaveFileNameW
            .IF eax == TRUE
                .IF szSaveFileNameW != 0
                    Invoke SendMessage, hEdtSaveFileW, WM_SETTEXT, 0, 0
                    Invoke SendMessageW, hEdtSaveFileW, WM_SETTEXT, 0, szSaveFileNameW
                    Invoke GlobalFree, szSaveFileNameW
                    mov szSaveFileNameW, 0
                .ELSE
                    Invoke SendMessageW, hEdtSaveFileW, WM_SETTEXT, 0, 0
                .ENDIF
            .ENDIF
        
        ;----------------------------------------------------------------------
        ; Select a single folder using Wide version of FolderSelectDialog
        ;----------------------------------------------------------------------
        .ELSEIF eax == IDC_BtnSelectFolderW
            Invoke FolderSelectDialogW, NULL, Addr szFolderOkButtonW, Addr szFolderLabelW, NULL, hWin, Addr szFolderNameW
            .IF eax == TRUE
                .IF szFolderNameW != 0
                    Invoke SendMessage, hEdtSelectFolderW, WM_SETTEXT, 0, 0
                    Invoke SendMessageW, hEdtSelectFolderW, WM_SETTEXT, 0, szFolderNameW
                    Invoke GlobalFree, szFolderNameW
                    mov szFolderNameW, 0
                .ELSE
                    Invoke SendMessageW, hEdtSelectFolderW, WM_SETTEXT, 0, 0
                .ENDIF
            .ENDIF
        
        ;----------------------------------------------------------------------
        ; Open multiple files using Wide version of FileOpenDialog
        ;----------------------------------------------------------------------
        .ELSEIF eax == IDC_BtnOpenFilesW
            Invoke FileOpenDialogW, NULL, NULL, NULL, NULL, 0, NULL, hWin, TRUE, Addr dwFileNameCount, Addr FileNameArrayW
            .IF eax == TRUE
                .IF dwFileNameCount != 0 && FileNameArrayW != 0
                    Invoke SendMessage, hEdtOpenFilesW, WM_SETTEXT, 0, 0
                    Invoke ParseFileArray, hWin, hEdtOpenFilesW, dwFileNameCount, FileNameArrayW, TRUE
                    Invoke GlobalFree, FileNameArrayW
                    mov FileNameArrayW, 0
                .ELSE
                    Invoke SendMessageW, hEdtOpenFilesW, WM_SETTEXT, 0, 0
                .ENDIF
            .ENDIF
            
        .ENDIF
    
    ;--------------------------------------------------------------------------
    ; Color the A and W letters and background of static labels
    ;--------------------------------------------------------------------------
    .ELSEIF eax == WM_CTLCOLORSTATIC
        mov eax, lParam
        .IF eax == hLblA || eax == hLblW
            Invoke SetTextColor, wParam, 0EBE1C9h
            Invoke SetBkMode, wParam, OPAQUE
            Invoke SetBkColor, wParam, 0F0F0F0h
            Invoke GetStockObject, NULL_BRUSH
        .ELSEIF eax == hLblAnsi || eax == hLblWide
            Invoke SetBkMode, wParam, OPAQUE
            Invoke SetBkColor, wParam, 0F0F0F0h
            Invoke GetStockObject, NULL_BRUSH
        .ENDIF
        ret
    
    .ELSEIF eax == WM_CLOSE
        Invoke DestroyWindow, hWin
        
    .ELSEIF eax == WM_DESTROY
        Invoke PostQuitMessage, NULL
        
    .ELSE
        Invoke DefWindowProc, hWin, uMsg, wParam, lParam
        ret
    .ENDIF
    xor eax, eax
    ret
WndProc ENDP


;------------------------------------------------------------------------------
; InitGUI
;
; Initialize GUI related stuff
;
;------------------------------------------------------------------------------
InitGUI PROC hWin:DWORD
    
    Invoke SendMessage, hWin, WM_SETICON, ICON_BIG, hIcoMain
    Invoke SendMessage, hWin, WM_SETICON, ICON_SMALL, hIcoMain
    
    Invoke CreateFont, -68, 0, 0, 0, FW_SEMIBOLD, FALSE, FALSE, FALSE, 0, OUT_TT_PRECIS, 0, PROOF_QUALITY, 0, Addr szFont
    mov hLabelAWFont, eax
    
    Invoke GetDlgItem, hWin, IDC_EdtOpenFileA
    mov hEdtOpenFileA, eax
    Invoke GetDlgItem, hWin, IDC_EdtSaveFileA
    mov hEdtSaveFileA, eax
    Invoke GetDlgItem, hWin, IDC_EdtSelectFolderA
    mov hEdtSelectFolderA, eax
    Invoke GetDlgItem, hWin, IDC_EdtOpenFilesA
    mov hEdtOpenFilesA, eax
    
    Invoke GetDlgItem, hWin, IDC_EdtOpenFileW
    mov hEdtOpenFileW, eax
    Invoke GetDlgItem, hWin, IDC_EdtSaveFileW
    mov hEdtSaveFileW, eax
    Invoke GetDlgItem, hWin, IDC_EdtSelectFolderW
    mov hEdtSelectFolderW, eax
    Invoke GetDlgItem, hWin, IDC_EdtOpenFilesW
    mov hEdtOpenFilesW, eax
    
    Invoke GetDlgItem, hWin, IDC_LblA
    mov hLblA, eax
    Invoke GetDlgItem, hWin, IDC_LblW
    mov hLblW, eax
    
    Invoke GetDlgItem, hWin, IDC_LblAnsi
    mov hLblAnsi, eax
    Invoke GetDlgItem, hWin, IDC_LblWide
    mov hLblWide, eax
    
    Invoke SendMessage, hLblA, WM_SETFONT, hLabelAWFont, TRUE
    Invoke SendMessage, hLblW, WM_SETFONT, hLabelAWFont, TRUE
    
    ret
InitGUI ENDP


;------------------------------------------------------------------------------
; ParseFileArray 
;
; Parse the filename array returned from FileOpenDialogA or FileOpenDialogW
; when set to allow selection of multiple files.
;
; Loop throught the null seperated list of filenames in the filename array and 
; output to the correct edit control (Ansi or Wide) along with carriage return 
; and line feed. 
;
;------------------------------------------------------------------------------
ParseFileArray PROC USES EBX hWin:DWORD, hEditControl:DWORD, dwFilenames:DWORD, lpArrayOfFilenames:DWORD, bWide:DWORD
    LOCAL nFile:DWORD
    LOCAL pFile:DWORD
    LOCAL nSize:DWORD
    
    mov eax, lpArrayOfFilenames
    mov pFile, eax
    mov nFile, 0
    mov eax, 0
    .WHILE eax < dwFilenames
        mov ebx, pFile
        
        .IF bWide == TRUE
            ;------------------------------------------------------------------
            ; Wide/Unicode FileArray
            ;------------------------------------------------------------------
            movzx eax, word ptr [ebx]
            .IF ax == 0
                .BREAK
            .ENDIF
            
            Invoke lstrlenW, pFile
            shl eax, 1 ; x2 for unicode chars to bytes
            mov nSize, eax
            
            Invoke SendMessageW, hEditControl, EM_SETSEL, -1, -1
            Invoke SendMessageW, hEditControl, EM_REPLACESEL, FALSE, pFile
            Invoke SendMessageW, hEditControl, EM_SETSEL, -1, -1
            Invoke SendMessage, hEditControl, EM_REPLACESEL, FALSE, Addr szCRLF ; Wide version doesnt work
            Invoke SendMessageW, hEditControl, EM_SCROLLCARET, 0, 0
            add nSize, 2
            
        .ELSE
            ;------------------------------------------------------------------
            ; Ansi FileArray
            ;------------------------------------------------------------------
            movzx eax, byte ptr [ebx]
            .IF al == 0
                .BREAK
            .ENDIF
            
            Invoke lstrlenA, pFile
            mov nSize, eax
            
            Invoke SendMessage, hEditControl, EM_SETSEL, -1, -1
            Invoke SendMessage, hEditControl, EM_REPLACESEL, FALSE, pFile
            Invoke SendMessage, hEditControl, EM_SETSEL, -1, -1
            Invoke SendMessage, hEditControl, EM_REPLACESEL, FALSE, Addr szCRLF
            Invoke SendMessage, hEditControl, EM_SCROLLCARET, 0, 0
            add nSize, 1
            
        .ENDIF
        
        ;----------------------------------------------------------------------
        ; Add length of filename to pFile and also skip past the null at the
        ; end of the filename string to point to next filename in the array
        ;----------------------------------------------------------------------
        mov eax, nSize
        add pFile, eax
        
        inc nFile
        mov eax, nFile
    .ENDW
    
    ret
ParseFileArray ENDP

end start















