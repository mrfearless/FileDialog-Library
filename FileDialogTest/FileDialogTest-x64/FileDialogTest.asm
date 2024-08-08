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
.686
.MMX
.XMM
.x64

option casemap : none
option win64 : 11
option frame : auto
option stackbase : rsp

_WIN64 EQU 1
WINVER equ 0501h

;DEBUG64 EQU 1
;
;IFDEF DEBUG64
;    PRESERVEXMMREGS equ 1
;    includelib \UASM\lib\x64\Debug64.lib
;    DBG64LIB equ 1
;    DEBUGEXE textequ <'\UASM\bin\DbgWin.exe'>
;    include \UASM\include\debug64.inc
;    .DATA
;    RDBG_DbgWin	DB DEBUGEXE,0
;    .CODE
;ENDIF

include FileDialogTest.inc

.CODE

;------------------------------------------------------------------------------
; Startup
;------------------------------------------------------------------------------
WinMainCRTStartup proc FRAME
	Invoke GetModuleHandle, NULL
	mov hInstance, rax
	Invoke GetCommandLine
	mov CommandLine, rax
	Invoke InitCommonControls
	mov icc.dwSize, sizeof INITCOMMONCONTROLSEX
    mov icc.dwICC, ICC_COOL_CLASSES or ICC_STANDARD_CLASSES or ICC_WIN95_CLASSES
    Invoke InitCommonControlsEx, offset icc
	Invoke WinMain, hInstance, NULL, CommandLine, SW_SHOWDEFAULT
	Invoke ExitProcess, eax
    ret
WinMainCRTStartup endp
	

;------------------------------------------------------------------------------
; WinMain
;------------------------------------------------------------------------------
WinMain proc FRAME hInst:HINSTANCE, hPrev:HINSTANCE, CmdLine:LPSTR, iShow:DWORD
	LOCAL msg:MSG
	LOCAL wcex:WNDCLASSEX
	
	mov wcex.cbSize, sizeof WNDCLASSEX
	mov wcex.style, CS_HREDRAW or CS_VREDRAW
	lea rax, WndProc
	mov wcex.lpfnWndProc, rax
	mov wcex.cbClsExtra, 0
	mov wcex.cbWndExtra, DLGWINDOWEXTRA
	mov rax, hInst
	mov wcex.hInstance, rax
	mov wcex.hbrBackground, COLOR_BTNFACE+1
	mov wcex.lpszMenuName, IDM_MENU ;NULL 
	lea rax, ClassName
	mov wcex.lpszClassName, rax
    Invoke LoadIcon, hInstance, ICO_MAIN ; resource icon for main application icon
    mov hIcoMain, rax ; main application icon
	mov wcex.hIcon, rax
	mov wcex.hIconSm, rax
	Invoke LoadCursor, NULL, IDC_ARROW
	mov wcex.hCursor, rax
	Invoke RegisterClassEx, addr wcex
	
	;Invoke CreateWindowEx, 0, addr ClassName, addr szAppName, WS_OVERLAPPEDWINDOW, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, NULL, NULL, hInstance, NULL
	Invoke CreateDialogParam, hInstance, IDD_DIALOG, 0, Addr WndProc, 0
	mov hWnd, rax
	
	Invoke ShowWindow, hWnd, SW_SHOWNORMAL
	Invoke UpdateWindow, hWnd
	
	.WHILE (TRUE)
		Invoke GetMessage, addr msg, NULL, 0, 0
		.BREAK .IF (!rax)		
		
        Invoke IsDialogMessage, hWnd, addr msg
        .IF rax == 0
            Invoke TranslateMessage, addr msg
            Invoke DispatchMessage, addr msg
        .ENDIF
	.ENDW
	
	mov rax, msg.wParam
	ret	
WinMain endp


;------------------------------------------------------------------------------
; WndProc - Main Window Message Loop
;------------------------------------------------------------------------------
WndProc proc FRAME hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    
    mov eax, uMsg
	.IF eax == WM_INITDIALOG
		; Init Stuff Here
		Invoke InitGUI, hWin
		
	.ELSEIF eax == WM_COMMAND
        mov rax, wParam
		.IF rax == IDM_FILE_EXIT || rax == IDC_BtnExit
			Invoke SendMessage, hWin, WM_CLOSE, 0, 0
			
		.ELSEIF rax == IDM_HELP_ABOUT
			Invoke ShellAbout, hWin, Addr AppName, Addr AboutMsg, NULL
			
        ;----------------------------------------------------------------------
        ; Open a single file using Ansi version of FileOpenDialog
        ;----------------------------------------------------------------------
        .ELSEIF rax == IDC_BtnOpenFileA
            Invoke FileOpenDialogA, Addr szOpenTitle, Addr szOpenOkButton, Addr szOpenFileLabel, Addr szTempFolder, 0, NULL, hWin, FALSE, Addr qwFileNameCount, Addr szOpenFileNameA
            .IF rax == TRUE
                .IF qwFileNameCount != 0 && szOpenFileNameA != 0
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
        .ELSEIF rax == IDC_BtnSaveFileA
            Invoke FileSaveDialogA, Addr szSaveTitle, Addr szSaveOkButton, Addr szSaveFileLabel, Addr szTempFolder, 0, NULL, hWin, TRUE, Addr szDefaultSaveAsItem, Addr szSaveFileNameA
            .IF rax == TRUE
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
        .ELSEIF rax == IDC_BtnSelectFolderA
            Invoke FolderSelectDialogA, NULL, Addr szFolderOkButton, NULL, NULL, hWin, Addr szFolderNameA
            .IF rax == TRUE
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
        .ELSEIF rax == IDC_BtnOpenFilesA
            Invoke FileOpenDialogA, NULL, NULL, NULL, NULL, 0, NULL, hWin, TRUE, Addr qwFileNameCount, Addr FileNameArrayA
            .IF rax == TRUE
                .IF qwFileNameCount != 0 && FileNameArrayA != 0
                    Invoke SendMessage, hEdtOpenFilesA, WM_SETTEXT, 0, 0
                    Invoke ParseFileArray, hWin, hEdtOpenFilesA, qwFileNameCount, FileNameArrayA, FALSE
                    Invoke GlobalFree, FileNameArrayA
                    mov FileNameArrayA, 0
                .ELSE
                    Invoke SendMessage, hEdtOpenFilesA, WM_SETTEXT, 0, 0
                .ENDIF
            .ENDIF
        
        ;----------------------------------------------------------------------
        ; Open a single file using Wide version of FileOpenDialog
        ;----------------------------------------------------------------------
        .ELSEIF rax == IDC_BtnOpenFileW
            Invoke FileOpenDialogW, Addr szOpenTitleW, Addr szOpenOkButtonW, Addr szOpenFileLabelW, Addr szTempFolderW, 0, NULL, hWin, FALSE, Addr qwFileNameCount, Addr szOpenFileNameW
            .IF rax == TRUE
                .IF qwFileNameCount != 0 && szOpenFileNameW != 0
                    Invoke SendMessageW, hEdtOpenFileW, WM_SETTEXT, 0, 0
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
        .ELSEIF rax == IDC_BtnSaveFileW
            Invoke FileSaveDialogW, Addr szSaveTitleW, Addr szSaveOkButtonW, Addr szSaveFileLabelW, Addr szTempFolderW, 0, NULL, hWin, TRUE, Addr szDefaultSaveAsItemW, Addr szSaveFileNameW
            .IF rax == TRUE
                .IF szSaveFileNameW != 0
                    Invoke SendMessageW, hEdtSaveFileW, WM_SETTEXT, 0, 0
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
        .ELSEIF rax == IDC_BtnSelectFolderW
            Invoke FolderSelectDialogW, NULL, Addr szFolderOkButtonW, Addr szFolderLabelW, NULL, hWin, Addr szFolderNameW
            .IF rax == TRUE
                .IF szFolderNameW != 0
                    Invoke SendMessageW, hEdtSelectFolderW, WM_SETTEXT, 0, 0
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
        .ELSEIF rax == IDC_BtnOpenFilesW
            Invoke FileOpenDialogW, NULL, NULL, NULL, NULL, 0, NULL, hWin, TRUE, Addr qwFileNameCount, Addr FileNameArrayW
            .IF rax == TRUE
                .IF qwFileNameCount != 0 && FileNameArrayW != 0
                    Invoke SendMessageW, hEdtOpenFilesW, WM_SETTEXT, 0, 0
                    Invoke ParseFileArray, hWin, hEdtOpenFilesW, qwFileNameCount, FileNameArrayW, TRUE
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
    .ELSEIF rax == WM_CTLCOLORSTATIC
        mov rax, lParam
        .IF rax == hLblA || rax == hLblW
            Invoke SetTextColor, wParam, 0EBE1C9h
            Invoke SetBkMode, wParam, OPAQUE
            Invoke SetBkColor, wParam, 0F0F0F0h
            Invoke GetStockObject, NULL_BRUSH
        .ELSEIF rax == hLblAnsi || rax == hLblWide
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
		Invoke DefWindowProc, hWin, uMsg, wParam, lParam ; rcx, edx, r8, r9
		ret
	.ENDIF
	xor rax, rax
	ret
WndProc endp

;------------------------------------------------------------------------------
; InitGUI
;
; Initialize GUI related stuff
;
;------------------------------------------------------------------------------
InitGUI PROC FRAME hWin:QWORD
    
    Invoke SendMessage, hWin, WM_SETICON, ICON_BIG, hIcoMain
    Invoke SendMessage, hWin, WM_SETICON, ICON_SMALL, hIcoMain

    Invoke CreateFont, -68, 0, 0, 0, FW_SEMIBOLD, FALSE, FALSE, FALSE, 0, OUT_TT_PRECIS, 0, PROOF_QUALITY, 0, Addr szFont
    mov hLabelAWFont, rax

    Invoke GetDlgItem, hWin, IDC_EdtOpenFileA
    mov hEdtOpenFileA, rax
    Invoke GetDlgItem, hWin, IDC_EdtSaveFileA
    mov hEdtSaveFileA, rax
    Invoke GetDlgItem, hWin, IDC_EdtSelectFolderA
    mov hEdtSelectFolderA, rax
    Invoke GetDlgItem, hWin, IDC_EdtOpenFilesA
    mov hEdtOpenFilesA, rax
    
    Invoke GetDlgItem, hWin, IDC_EdtOpenFileW
    mov hEdtOpenFileW, rax
    Invoke GetDlgItem, hWin, IDC_EdtSaveFileW
    mov hEdtSaveFileW, rax
    Invoke GetDlgItem, hWin, IDC_EdtSelectFolderW
    mov hEdtSelectFolderW, rax
    Invoke GetDlgItem, hWin, IDC_EdtOpenFilesW
    mov hEdtOpenFilesW, rax

    Invoke GetDlgItem, hWin, IDC_LblA
    mov hLblA, rax
    Invoke GetDlgItem, hWin, IDC_LblW
    mov hLblW, rax
    
    Invoke GetDlgItem, hWin, IDC_LblAnsi
    mov hLblAnsi, rax
    Invoke GetDlgItem, hWin, IDC_LblWide
    mov hLblWide, rax
    
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
ParseFileArray PROC FRAME USES RBX hWin:QWORD, hEditControl:QWORD, qwFilenames:QWORD, lpArrayOfFilenames:QWORD, bWide:QWORD
    LOCAL nFile:QWORD
    LOCAL pFile:QWORD
    LOCAL nSize:QWORD
    
    mov rax, lpArrayOfFilenames
    mov pFile, rax
    mov nFile, 0
    mov rax, 0
    .WHILE rax < qwFilenames
        mov rbx, pFile
        
        .IF bWide == TRUE
            ;------------------------------------------------------------------
            ; Wide/Unicode FileArray
            ;------------------------------------------------------------------
            movzx rax, word ptr [rbx]
            .IF ax == 0
                .BREAK
            .ENDIF
            
            Invoke lstrlenW, pFile
            shl rax, 1 ; x2 for unicode chars to bytes
            mov nSize, rax
            
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
            movzx rax, byte ptr [rbx]
            .IF al == 0
                .BREAK
            .ENDIF
            
            Invoke lstrlenA, pFile
            mov nSize, rax
            
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
        mov rax, nSize
        add pFile, rax
        
        inc nFile
        mov rax, nFile
    .ENDW
    
    ret
ParseFileArray ENDP



end WinMainCRTStartup

