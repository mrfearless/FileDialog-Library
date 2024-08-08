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
.686
.MMX
.XMM
.model flat,stdcall
option casemap:none
include \masm32\macros\macros.asm

;DEBUG32 EQU 1
;IFDEF DEBUG32
;    PRESERVEXMMREGS equ 1
;    includelib M:\Masm32\lib\Debug32.lib
;    DBG32LIB equ 1
;    DEBUGEXE textequ <'M:\Masm32\DbgWin.exe'>
;    include M:\Masm32\include\debug32.inc
;    
;    include msvcrt.inc
;    includelib ucrt.lib
;    includelib vcruntime.lib
;    
;ENDIF

;include windows.inc

;include user32.inc
includelib user32.lib

;include kernel32.inc
includelib kernel32.lib

;include ole32.inc
includelib ole32.lib

;include shell32.inc
includelib shell32.lib

include FileDialog.inc

IFNDEF NULL
NULL EQU 0
ENDIF
IFNDEF TRUE
TRUE EQU 1
ENDIF
IFNDEF FALSE
FALSE EQU 0
ENDIF
IFNDEF GlobalAlloc
GlobalAlloc PROTO uFlags:DWORD, dwBytes:DWORD
ENDIF
IFNDEF GlobalFree
GlobalFree PROTO pMem:DWORD
ENDIF
IFNDEF GMEM_FIXED
GMEM_FIXED EQU 0000h
ENDIF
IFNDEF GMEM_ZEROINIT
GMEM_ZEROINIT EQU 0040h
ENDIF
IFNDEF RtlMoveMemory
RtlMoveMemory PROTO Destination:DWORD, Source:DWORD, dwLength:DWORD
ENDIF
IFNDEF lstrlenA
lstrlenA PROTO lpString:DWORD
ENDIF
IFNDEF lstrlenW
lstrlenW PROTO lpString:DWORD
ENDIF
IFNDEF WideCharToMultiByte 
WideCharToMultiByte PROTO CodePage:DWORD, dwFlags:DWORD, lpWideCharStr:DWORD, ccWideChar:DWORD, lpMultiByteStr:DWORD, cbMultiByte:DWORD, lpDefaultChar:DWORD, lpUsedDefaultChar:DWORD
ENDIF
IFNDEF MultiByteToWideChar 
MultiByteToWideChar PROTO CodePage:DWORD, dwFlags:DWORD, lpMultiByteStr:DWORD, cbMultiByte:DWORD, lpWideCharStr:DWORD, ccWideChar:DWORD
ENDIF
IFNDEF CoInitializeEx
CoInitializeEx PROTO pvReserved:DWORD, dwCoInit:DWORD
ENDIF
IFNDEF CoUninitialize
CoUninitialize PROTO
ENDIF
IFNDEF CoCreateInstance
CoCreateInstance PROTO rclsid:DWORD, pUnkOuter:DWORD, dwClsContext:DWORD, riid:DWORD, ppv:DWORD
ENDIF
IFNDEF CoTaskMemFree
CoTaskMemFree PROTO pv:DWORD
ENDIF
IFNDEF SHCreateItemFromParsingName
SHCreateItemFromParsingName PROTO pszPath:DWORD, pbc:DWORD, riid:DWORD, ppv:DWORD
ENDIF

;------------------------------------------------------------------------------
; Prototypes for internal use
;------------------------------------------------------------------------------
IFileOpenDialogInit         PROTO pIFileOpenDialog:DWORD
IFileSaveDialogInit         PROTO pIFileSaveDialog:DWORD
IFileDialogInit             PROTO pIFileDialog:DWORD

IShellItemInit              PROTO pIShellItem:DWORD
IShellItemArrayInit         PROTO pIShellItemArray:DWORD

_FD_ConvertStringToAnsi     PROTO lpszWideString:DWORD
_FD_ConvertStringToWide     PROTO lpszAnsiString:DWORD
_FD_ConvertStringFree     PROTO lpString:DWORD

;------------------------------------------------------------------------------
; COM Prototypes
;------------------------------------------------------------------------------
; IUnknown
IUnknown_QueryInterface_Proto                   TYPEDEF PROTO STDCALL pThis:DWORD, riid:DWORD, ppvObject:DWORD
IUnknown_AddRef_Proto                           TYPEDEF PROTO STDCALL pThis:DWORD
IUnknown_Release_Proto                          TYPEDEF PROTO STDCALL pThis:DWORD

; IModalWindow
IModalWindow_Show_Proto                         TYPEDEF PROTO STDCALL pThis:DWORD, hwndOwner:DWORD

; IFileDialog
IFileDialog_SetFileTypes_Proto                  TYPEDEF PROTO STDCALL pThis:DWORD, cFileTypes:DWORD, rgFilterSpec:DWORD
IFileDialog_SetFileTypeIndex_Proto              TYPEDEF PROTO STDCALL pThis:DWORD, iFileType:DWORD
IFileDialog_GetFileTypeIndex_Proto              TYPEDEF PROTO STDCALL pThis:DWORD, piFileType:DWORD
IFileDialog_Advise_Proto                        TYPEDEF PROTO STDCALL pThis:DWORD, pfde:DWORD, pdwCookie:DWORD
IFileDialog_Unadvise_Proto                      TYPEDEF PROTO STDCALL pThis:DWORD, dwCookie:DWORD
IFileDialog_SetOptions_Proto                    TYPEDEF PROTO STDCALL pThis:DWORD, fos:DWORD
IFileDialog_GetOptions_Proto                    TYPEDEF PROTO STDCALL pThis:DWORD, pfos:DWORD
IFileDialog_SetDefaultFolder_Proto              TYPEDEF PROTO STDCALL pThis:DWORD, psi:DWORD
IFileDialog_SetFolder_Proto                     TYPEDEF PROTO STDCALL pThis:DWORD, psi:DWORD
IFileDialog_GetFolder_Proto                     TYPEDEF PROTO STDCALL pThis:DWORD, ppsi:DWORD
IFileDialog_GetCurrentSelection_Proto           TYPEDEF PROTO STDCALL pThis:DWORD, ppsi:DWORD
IFileDialog_SetFileName_Proto                   TYPEDEF PROTO STDCALL pThis:DWORD, pszName:DWORD
IFileDialog_GetFileName_Proto                   TYPEDEF PROTO STDCALL pThis:DWORD, pszName:DWORD
IFileDialog_SetTitle_Proto                      TYPEDEF PROTO STDCALL pThis:DWORD, pszTitle:DWORD
IFileDialog_SetOkButtonLabel_Proto              TYPEDEF PROTO STDCALL pThis:DWORD, pszText:DWORD
IFileDialog_SetFileNameLabel_Proto              TYPEDEF PROTO STDCALL pThis:DWORD, pszLabel:DWORD
IFileDialog_GetResult_Proto                     TYPEDEF PROTO STDCALL pThis:DWORD, ppsi:DWORD
IFileDialog_AddPlace_Proto                      TYPEDEF PROTO STDCALL pThis:DWORD, psi:DWORD, fdap:DWORD
IFileDialog_SetDefaultExtension_Proto           TYPEDEF PROTO STDCALL pThis:DWORD, pszDefaultExtension:DWORD
IFileDialog_Close_Proto                         TYPEDEF PROTO STDCALL pThis:DWORD, hr:DWORD
IFileDialog_SetClientGuid_Proto                 TYPEDEF PROTO STDCALL pThis:DWORD, guid:DWORD
IFileDialog_ClearClientData_Proto               TYPEDEF PROTO STDCALL pThis:DWORD
IFileDialog_SetFilter_Proto                     TYPEDEF PROTO STDCALL pThis:DWORD, pFilter:DWORD

; IFileSaveDialog
IFileSaveDialog_SetSaveAsItem_Proto             TYPEDEF PROTO STDCALL pThis:DWORD, psi:DWORD
IFileSaveDialog_SetProperties_Proto             TYPEDEF PROTO STDCALL pThis:DWORD, pStore:DWORD
IFileSaveDialog_SetCollectedProperties_Proto    TYPEDEF PROTO STDCALL pThis:DWORD, pList:DWORD, fAppendDefault:DWORD
IFileSaveDialog_GetProperties_Proto             TYPEDEF PROTO STDCALL pThis:DWORD, ppStore:DWORD
IFileSaveDialog_ApplyProperties_Proto           TYPEDEF PROTO STDCALL pThis:DWORD, psi:DWORD, pStore:DWORD, hwnd:DWORD, pSink:DWORD

; IFileOpenDialog
IFileOpenDialog_GetResults_Proto                TYPEDEF PROTO STDCALL pThis:DWORD, ppenum:DWORD
IFileOpenDialog_GetSelectedItems_Proto          TYPEDEF PROTO STDCALL pThis:DWORD, ppsai:DWORD

; IFileDialogEvents
IFileDialogEvents_OnFileOk_Proto                TYPEDEF PROTO STDCALL pThis:DWORD, pfd:DWORD
IFileDialogEvents_OnFolderChanging_Proto        TYPEDEF PROTO STDCALL pThis:DWORD, pfd:DWORD, psiFolder:DWORD
IFileDialogEvents_OnFolderChange_Proto          TYPEDEF PROTO STDCALL pThis:DWORD, pfd:DWORD
IFileDialogEvents_OnSelectionChange_Proto       TYPEDEF PROTO STDCALL pThis:DWORD, pfd:DWORD
IFileDialogEvents_OnShareViolation_Proto        TYPEDEF PROTO STDCALL pThis:DWORD, pfd:DWORD, psi:DWORD, pResponse:DWORD
IFileDialogEvents_OnTypeChange_Proto            TYPEDEF PROTO STDCALL pThis:DWORD, pfd:DWORD
IFileDialogEvents_OnOverwrite_Proto             TYPEDEF PROTO STDCALL pThis:DWORD, pfd:DWORD, psi:DWORD, pResponse:DWORD

; IShellItem
IShellItem_BindToHandler_Proto                  TYPEDEF PROTO STDCALL pThis:DWORD, pbc:DWORD, bhid:DWORD, riid:DWORD, ppvOut:DWORD
IShellItem_GetParent_Proto                      TYPEDEF PROTO STDCALL pThis:DWORD, ppsi:DWORD
IShellItem_GetDisplayName_Proto                 TYPEDEF PROTO STDCALL pThis:DWORD, sigdnName:DWORD, ppszName:DWORD
IShellItem_GetAttributes_Proto                  TYPEDEF PROTO STDCALL pThis:DWORD, sfgaoMask:DWORD, psfgaoAttribs:DWORD
IShellItem_Compare_Proto                        TYPEDEF PROTO STDCALL pThis:DWORD, psi:DWORD, hint:DWORD, piOrder:DWORD

; IShellItemArray
IShellItemArray_BindToHandler_Proto             TYPEDEF PROTO STDCALL pThis:DWORD, pbc:DWORD, bhid:DWORD, riid:DWORD, ppvOut:DWORD
IShellItemArray_GetPropertyStore_Proto          TYPEDEF PROTO STDCALL pThis:DWORD, flags:DWORD, riid:DWORD, ppv:DWORD
IShellItemArray_GetPropertyDescriptionList_Proto TYPEDEF PROTO STDCALL pThis:DWORD, keyType:DWORD, riid:DWORD, ppv:DWORD
IShellItemArray_GetAttributes_Proto             TYPEDEF PROTO STDCALL pThis:DWORD, AttribFlags:DWORD, sfgaoMask:DWORD, psfgaoAttribs:DWORD
IShellItemArray_GetCount_Proto                  TYPEDEF PROTO STDCALL pThis:DWORD, pdwNumItems:DWORD
IShellItemArray_GetItemAt_Proto                 TYPEDEF PROTO STDCALL pThis:DWORD, dwIndex:DWORD, ppsi:DWORD
IShellItemArray_EnumItems_Proto                 TYPEDEF PROTO STDCALL pThis:DWORD, ppenumShellItems:DWORD


;------------------------------------------------------------------------------
; Pointer To Prototypes
;------------------------------------------------------------------------------
; IUnknown
IUnknown_QueryInterface_Ptr                     TYPEDEF PTR IUnknown_QueryInterface_Proto
IUnknown_AddRef_Ptr                             TYPEDEF PTR IUnknown_AddRef_Proto
IUnknown_Release_Ptr                            TYPEDEF PTR IUnknown_Release_Proto

; IModalWindow
IModalWindow_Show_Ptr                           TYPEDEF PTR IModalWindow_Show_Proto

; IFileDialog
IFileDialog_QueryInterface_Ptr                  TYPEDEF PTR IUnknown_QueryInterface_Proto
IFileDialog_AddRef_Ptr                          TYPEDEF PTR IUnknown_AddRef_Proto
IFileDialog_Release_Ptr                         TYPEDEF PTR IUnknown_Release_Proto
IFileDialog_Show_Ptr                            TYPEDEF PTR IModalWindow_Show_Proto
IFileDialog_SetFileTypes_Ptr                    TYPEDEF PTR IFileDialog_SetFileTypes_Proto
IFileDialog_SetFileTypeIndex_Ptr                TYPEDEF PTR IFileDialog_SetFileTypeIndex_Proto
IFileDialog_GetFileTypeIndex_Ptr                TYPEDEF PTR IFileDialog_GetFileTypeIndex_Proto
IFileDialog_Advise_Ptr                          TYPEDEF PTR IFileDialog_Advise_Proto
IFileDialog_Unadvise_Ptr                        TYPEDEF PTR IFileDialog_Unadvise_Proto
IFileDialog_SetOptions_Ptr                      TYPEDEF PTR IFileDialog_SetOptions_Proto
IFileDialog_GetOptions_Ptr                      TYPEDEF PTR IFileDialog_GetOptions_Proto
IFileDialog_SetDefaultFolder_Ptr                TYPEDEF PTR IFileDialog_SetDefaultFolder_Proto
IFileDialog_SetFolder_Ptr                       TYPEDEF PTR IFileDialog_SetFolder_Proto
IFileDialog_GetFolder_Ptr                       TYPEDEF PTR IFileDialog_GetFolder_Proto
IFileDialog_GetCurrentSelection_Ptr             TYPEDEF PTR IFileDialog_GetCurrentSelection_Proto
IFileDialog_SetFileName_Ptr                     TYPEDEF PTR IFileDialog_SetFileName_Proto
IFileDialog_GetFileName_Ptr                     TYPEDEF PTR IFileDialog_GetFileName_Proto
IFileDialog_SetTitle_Ptr                        TYPEDEF PTR IFileDialog_SetTitle_Proto
IFileDialog_SetOkButtonLabel_Ptr                TYPEDEF PTR IFileDialog_SetOkButtonLabel_Proto
IFileDialog_SetFileNameLabel_Ptr                TYPEDEF PTR IFileDialog_SetFileNameLabel_Proto
IFileDialog_GetResult_Ptr                       TYPEDEF PTR IFileDialog_GetResult_Proto
IFileDialog_AddPlace_Ptr                        TYPEDEF PTR IFileDialog_AddPlace_Proto
IFileDialog_SetDefaultExtension_Ptr             TYPEDEF PTR IFileDialog_SetDefaultExtension_Proto
IFileDialog_Close_Ptr                           TYPEDEF PTR IFileDialog_Close_Proto
IFileDialog_SetClientGuid_Ptr                   TYPEDEF PTR IFileDialog_SetClientGuid_Proto
IFileDialog_ClearClientData_Ptr                 TYPEDEF PTR IFileDialog_ClearClientData_Proto
IFileDialog_SetFilter_Ptr                       TYPEDEF PTR IFileDialog_SetFilter_Proto

; IFileSaveDialog
IFileSaveDialog_SetSaveAsItem_Ptr               TYPEDEF PTR IFileSaveDialog_SetSaveAsItem_Proto
IFileSaveDialog_SetProperties_Ptr               TYPEDEF PTR IFileSaveDialog_SetProperties_Proto
IFileSaveDialog_SetCollectedProperties_Ptr      TYPEDEF PTR IFileSaveDialog_SetCollectedProperties_Proto
IFileSaveDialog_GetProperties_Ptr               TYPEDEF PTR IFileSaveDialog_GetProperties_Proto
IFileSaveDialog_ApplyProperties_Ptr             TYPEDEF PTR IFileSaveDialog_ApplyProperties_Proto

; IFileOpenDialog
IFileOpenDialog_GetResults_Ptr                  TYPEDEF PTR IFileOpenDialog_GetResults_Proto
IFileOpenDialog_GetSelectedItems_Ptr            TYPEDEF PTR IFileOpenDialog_GetSelectedItems_Proto

; IFileDialogEvents
IFileDialogEvents_OnFileOk_Ptr                  TYPEDEF PTR IFileDialogEvents_OnFileOk_Proto
IFileDialogEvents_OnFolderChanging_Ptr          TYPEDEF PTR IFileDialogEvents_OnFolderChanging_Proto
IFileDialogEvents_OnFolderChange_Ptr            TYPEDEF PTR IFileDialogEvents_OnFolderChange_Proto
IFileDialogEvents_OnSelectionChange_Ptr         TYPEDEF PTR IFileDialogEvents_OnSelectionChange_Proto
IFileDialogEvents_OnShareViolation_Ptr          TYPEDEF PTR IFileDialogEvents_OnShareViolation_Proto
IFileDialogEvents_OnTypeChange_Ptr              TYPEDEF PTR IFileDialogEvents_OnTypeChange_Proto
IFileDialogEvents_OnOverwrite_Ptr               TYPEDEF PTR IFileDialogEvents_OnOverwrite_Proto

; IShellItem
IShellItem_QueryInterface_Ptr                   TYPEDEF PTR IUnknown_QueryInterface_Proto
IShellItem_AddRef_Ptr                           TYPEDEF PTR IUnknown_AddRef_Proto
IShellItem_Release_Ptr                          TYPEDEF PTR IUnknown_Release_Proto
IShellItem_BindToHandler_Ptr                    TYPEDEF PTR IShellItem_BindToHandler_Proto
IShellItem_GetParent_Ptr                        TYPEDEF PTR IShellItem_GetParent_Proto
IShellItem_GetDisplayName_Ptr                   TYPEDEF PTR IShellItem_GetDisplayName_Proto
IShellItem_GetAttributes_Ptr                    TYPEDEF PTR IShellItem_GetAttributes_Proto
IShellItem_Compare_Ptr                          TYPEDEF PTR IShellItem_Compare_Proto

; IShellItemArray
IShellItemArray_QueryInterface_Ptr              TYPEDEF PTR IUnknown_QueryInterface_Proto
IShellItemArray_AddRef_Ptr                      TYPEDEF PTR IUnknown_AddRef_Proto
IShellItemArray_Release_Ptr                     TYPEDEF PTR IUnknown_Release_Proto
IShellItemArray_BindToHandler_Ptr               TYPEDEF PTR IShellItemArray_BindToHandler_Proto
IShellItemArray_GetPropertyStore_Ptr            TYPEDEF PTR IShellItemArray_GetPropertyStore_Proto
IShellItemArray_GetPropertyDescriptionList_Ptr  TYPEDEF PTR IShellItemArray_GetPropertyDescriptionList_Proto
IShellItemArray_GetAttributes_Ptr               TYPEDEF PTR IShellItemArray_GetAttributes_Proto
IShellItemArray_GetCount_Ptr                    TYPEDEF PTR IShellItemArray_GetCount_Proto
IShellItemArray_GetItemAt_Ptr                   TYPEDEF PTR IShellItemArray_GetItemAt_Proto
IShellItemArray_EnumItems_Ptr                   TYPEDEF PTR IShellItemArray_EnumItems_Proto


;------------------------------------------------------------------------------
; Structures for internal use
;------------------------------------------------------------------------------

;------------------------------------------------------------------------------
; COM Structures
;------------------------------------------------------------------------------
IFNDEF IUnknownVtbl
IUnknownVtbl            STRUCT
    QueryInterface      IUnknown_QueryInterface_Ptr 0
    AddRef              IUnknown_AddRef_Ptr 0
    Release             IUnknown_Release_Ptr 0
IUnknownVtbl            ENDS
ENDIF

IFNDEF IModalWindowVtbl
IModalWindowVtbl        STRUCT
    QueryInterface      IUnknown_QueryInterface_Ptr 0
    AddRef              IUnknown_AddRef_Ptr 0
    Release             IUnknown_Release_Ptr 0
    Show                IModalWindow_Show_Ptr 0
IModalWindowVtbl        ENDS
ENDIF

IFNDEF IFileDialogVtbl
IFileDialogVtbl         STRUCT
    QueryInterface      IUnknown_QueryInterface_Ptr 0
    AddRef              IUnknown_AddRef_Ptr 0
    Release             IUnknown_Release_Ptr 0
    Show                IModalWindow_Show_Ptr 0
    SetFileTypes        IFileDialog_SetFileTypes_Ptr 0
    SetFileTypeIndex    IFileDialog_SetFileTypeIndex_Ptr 0
    GetFileTypeIndex    IFileDialog_GetFileTypeIndex_Ptr 0
    Advise              IFileDialog_Advise_Ptr 0
    Unadvise            IFileDialog_Unadvise_Ptr 0
    SetOptions          IFileDialog_SetOptions_Ptr 0
    GetOptions          IFileDialog_GetOptions_Ptr 0
    SetDefaultFolder    IFileDialog_SetDefaultFolder_Ptr 0
    SetFolder           IFileDialog_SetFolder_Ptr 0
    GetFolder           IFileDialog_GetFolder_Ptr 0
    GetCurrentSelection IFileDialog_GetCurrentSelection_Ptr 0
    SetFileName         IFileDialog_SetFileName_Ptr 0
    GetFileName         IFileDialog_GetFileName_Ptr 0
    SetTitle            IFileDialog_SetTitle_Ptr 0
    SetOkButtonLabel    IFileDialog_SetOkButtonLabel_Ptr 0
    SetFileNameLabel    IFileDialog_SetFileNameLabel_Ptr 0
    GetResult           IFileDialog_GetResult_Ptr 0
    AddPlace            IFileDialog_AddPlace_Ptr 0
    SetDefaultExtension IFileDialog_SetDefaultExtension_Ptr 0
    Close               IFileDialog_Close_Ptr 0
    SetClientGuid       IFileDialog_SetClientGuid_Ptr 0
    ClearClientData     IFileDialog_ClearClientData_Ptr 0
    SetFilter           IFileDialog_SetFilter_Ptr 0
IFileDialogVtbl         ENDS
ENDIF

IFNDEF IFileSaveDialogVtbl
IFileSaveDialogVtbl     STRUCT
    QueryInterface      IUnknown_QueryInterface_Ptr 0
    AddRef              IUnknown_AddRef_Ptr 0
    Release             IUnknown_Release_Ptr 0
    Show                IModalWindow_Show_Ptr 0
    SetFileTypes        IFileDialog_SetFileTypes_Ptr 0
    SetFileTypeIndex    IFileDialog_SetFileTypeIndex_Ptr 0
    GetFileTypeIndex    IFileDialog_GetFileTypeIndex_Ptr 0
    Advise              IFileDialog_Advise_Ptr 0
    Unadvise            IFileDialog_Unadvise_Ptr 0
    SetOptions          IFileDialog_SetOptions_Ptr 0
    GetOptions          IFileDialog_GetOptions_Ptr 0
    SetDefaultFolder    IFileDialog_SetDefaultFolder_Ptr 0
    SetFolder           IFileDialog_SetFolder_Ptr 0
    GetFolder           IFileDialog_GetFolder_Ptr 0
    GetCurrentSelection IFileDialog_GetCurrentSelection_Ptr 0
    SetFileName         IFileDialog_SetFileName_Ptr 0
    GetFileName         IFileDialog_GetFileName_Ptr 0
    SetTitle            IFileDialog_SetTitle_Ptr 0
    SetOkButtonLabel    IFileDialog_SetOkButtonLabel_Ptr 0
    SetFileNameLabel    IFileDialog_SetFileNameLabel_Ptr 0
    GetResult           IFileDialog_GetResult_Ptr 0
    AddPlace            IFileDialog_AddPlace_Ptr 0
    SetDefaultExtension IFileDialog_SetDefaultExtension_Ptr 0
    Close               IFileDialog_Close_Ptr 0
    SetClientGuid       IFileDialog_SetClientGuid_Ptr 0
    ClearClientData     IFileDialog_ClearClientData_Ptr 0
    SetFilter           IFileDialog_SetFilter_Ptr 0
    SetSaveAsItem       IFileSaveDialog_SetSaveAsItem_Ptr 0
    SetProperties       IFileSaveDialog_SetProperties_Ptr 0
    SetCollectedProperties IFileSaveDialog_SetCollectedProperties_Ptr 0
    GetProperties       IFileSaveDialog_GetProperties_Ptr 0
    ApplyProperties     IFileSaveDialog_ApplyProperties_Ptr 0
IFileSaveDialogVtbl     ENDS
ENDIF

IFNDEF IFileOpenDialogVtbl
IFileOpenDialogVtbl     STRUCT
    QueryInterface      IUnknown_QueryInterface_Ptr 0
    AddRef              IUnknown_AddRef_Ptr 0
    Release             IUnknown_Release_Ptr 0
    Show                IModalWindow_Show_Ptr 0
    SetFileTypes        IFileDialog_SetFileTypes_Ptr 0
    SetFileTypeIndex    IFileDialog_SetFileTypeIndex_Ptr 0
    GetFileTypeIndex    IFileDialog_GetFileTypeIndex_Ptr 0
    Advise              IFileDialog_Advise_Ptr 0
    Unadvise            IFileDialog_Unadvise_Ptr 0
    SetOptions          IFileDialog_SetOptions_Ptr 0
    GetOptions          IFileDialog_GetOptions_Ptr 0
    SetDefaultFolder    IFileDialog_SetDefaultFolder_Ptr 0
    SetFolder           IFileDialog_SetFolder_Ptr 0
    GetFolder           IFileDialog_GetFolder_Ptr 0
    GetCurrentSelection IFileDialog_GetCurrentSelection_Ptr 0
    SetFileName         IFileDialog_SetFileName_Ptr 0
    GetFileName         IFileDialog_GetFileName_Ptr 0
    SetTitle            IFileDialog_SetTitle_Ptr 0
    SetOkButtonLabel    IFileDialog_SetOkButtonLabel_Ptr 0
    SetFileNameLabel    IFileDialog_SetFileNameLabel_Ptr 0
    GetResult           IFileDialog_GetResult_Ptr 0
    AddPlace            IFileDialog_AddPlace_Ptr 0
    SetDefaultExtension IFileDialog_SetDefaultExtension_Ptr 0
    Close               IFileDialog_Close_Ptr 0
    SetClientGuid       IFileDialog_SetClientGuid_Ptr 0
    ClearClientData     IFileDialog_ClearClientData_Ptr 0
    SetFilter           IFileDialog_SetFilter_Ptr 0
    GetResults          IFileOpenDialog_GetResults_Ptr 0
    GetSelectedItems    IFileOpenDialog_GetSelectedItems_Ptr 0
IFileOpenDialogVtbl     ENDS
ENDIF

IFNDEF IFileDialogEventsVtbl
IFileDialogEventsVtbl   STRUCT
    QueryInterface      IUnknown_QueryInterface_Ptr 0
    AddRef              IUnknown_AddRef_Ptr 0
    Release             IUnknown_Release_Ptr 0
    OnFileOk            IFileDialogEvents_OnFileOk_Ptr 0
    OnFolderChanging    IFileDialogEvents_OnFolderChanging_Ptr 0
    OnFolderChange      IFileDialogEvents_OnFolderChange_Ptr 0
    OnSelectionChange   IFileDialogEvents_OnSelectionChange_Ptr 0
    OnShareViolation    IFileDialogEvents_OnShareViolation_Ptr 0
    OnTypeChange        IFileDialogEvents_OnTypeChange_Ptr 0
    OnOverwrite         IFileDialogEvents_OnOverwrite_Ptr 0
IFileDialogEventsVtbl   ENDS
ENDIF

IFNDEF IShellItemVtbl
IShellItemVtbl          STRUCT
    QueryInterface      IUnknown_QueryInterface_Ptr 0
    AddRef              IUnknown_AddRef_Ptr 0
    Release             IUnknown_Release_Ptr 0
    BindToHandler       IShellItem_BindToHandler_Ptr 0
    GetParent           IShellItem_GetParent_Ptr 0
    GetDisplayName      IShellItem_GetDisplayName_Ptr 0
    GetAttributes       IShellItem_GetAttributes_Ptr 0
    Compare             IShellItem_Compare_Ptr 0
IShellItemVtbl          ENDS
ENDIF

IFNDEF IShellItemArrayVtbl
IShellItemArrayVtbl     STRUCT
    QueryInterface      IUnknown_QueryInterface_Ptr 0
    AddRef              IUnknown_AddRef_Ptr 0
    Release             IUnknown_Release_Ptr 0
    BindToHandler       IShellItemArray_BindToHandler_Ptr 0
    GetPropertyStore    IShellItemArray_GetPropertyStore_Ptr 0
    GetPropertyDescriptionList IShellItemArray_GetPropertyDescriptionList_Ptr 0
    GetAttributes       IShellItemArray_GetAttributes_Ptr 0
    GetCount            IShellItemArray_GetCount_Ptr 0
    GetItemAt           IShellItemArray_GetItemAt_Ptr 0
    EnumItems           IShellItemArray_EnumItems_Ptr 0
IShellItemArrayVtbl     ENDS
ENDIF

IFNDEF COMDLG_FILTERSPEC
COMDLG_FILTERSPEC STRUCT
    pszName       DD ?
    pszSpec       DD ?
COMDLG_FILTERSPEC ENDS
ENDIF

IFNDEF GUID
GUID        STRUCT
    Data1   DD ?
    Data2   DW ?
    Data3   DW ?
    Data4   DB 8 DUP (?)
GUID        ENDS
ENDIF


.CONST
CP_ACP	EQU	0
CP_UTF7	EQU	65000
CP_UTF8	EQU	65001

COINIT_APARTMENTTHREADED	EQU 02h
COINIT_MULTITHREADED		EQU 00h
COINIT_DISABLE_OLE1DDE		EQU 04h
COINIT_SPEED_OVER_MEMORY	EQU 08h

CLSCTX_INPROC_SERVER        EQU 1h
CLSCTX_INPROC_HANDLER       EQU 2h
CLSCTX_LOCAL_SERVER         EQU 4h
CLSCTX_INPROC_SERVER16      EQU 8h
CLSCTX_REMOTE_SERVER        EQU 10h
CLSCTX_INPROC_HANDLER16     EQU 20h
CLSCTX_INPROC_SERVERX86     EQU 40h
CLSCTX_INPROC_HANDLERX86    EQU 80h
CLSCTX_ESERVER_HANDLER      EQU 100h
CLSCTX_NO_CODE_DOWNLOAD     EQU 400h
CLSCTX_NO_CUSTOM_MARSHAL    EQU 1000h
CLSCTX_ENABLE_CODE_DOWNLOAD EQU 2000h
CLSCTX_NO_FAILURE_LOG       EQU 4000h
CLSCTX_DISABLE_AAA          EQU 8000h
CLSCTX_ENABLE_AAA           EQU 10000h
CLSCTX_FROM_DEFAULT_CONTEXT EQU 20000h

IFNDEF S_OK
S_OK EQU 0
ENDIF
IFNDEF S_FALSE
S_FALSE EQU 1
ENDIF
IFNDEF HRESULT
HRESULT TYPEDEF DWORD
ENDIF
IFNDEF HRESULT_ERROR_CANCELLED
HRESULT_ERROR_CANCELLED EQU 800704C7h
ENDIF

FILEOPENDIALOGOPTIONS       TYPEDEF DWORD
FOS_OVERWRITEPROMPT	        EQU 2h
FOS_STRICTFILETYPES	        EQU 4h
FOS_NOCHANGEDIR	            EQU 8h
FOS_PICKFOLDERS	            EQU 20h
FOS_FORCEFILESYSTEM	        EQU 40h
FOS_ALLNONSTORAGEITEMS	    EQU 80h
FOS_NOVALIDATE	            EQU 100h
FOS_ALLOWMULTISELECT	    EQU 200h
FOS_PATHMUSTEXIST	        EQU 800h
FOS_FILEMUSTEXIST	        EQU 1000h
FOS_CREATEPROMPT	        EQU 2000h
FOS_SHAREAWARE	            EQU 4000h
FOS_NOREADONLYRETURN	    EQU 8000h
FOS_NOTESTFILECREATE	    EQU 10000h
FOS_HIDEMRUPLACES	        EQU 20000h
FOS_HIDEPINNEDPLACES	    EQU 40000h
FOS_NODEREFERENCELINKS	    EQU 100000h
FOS_DONTADDTORECENT	        EQU 2000000h
FOS_FORCESHOWHIDDEN	        EQU 10000000h
FOS_DEFAULTNOMINIMODE	    EQU 20000000h
FOS_FORCEPREVIEWPANEON	    EQU 40000000h

SIGDN                       TYPEDEF DWORD
SIGDN_NORMALDISPLAY	        EQU 0h
SIGDN_PARENTRELATIVEPARSING	EQU 80018001h
SIGDN_DESKTOPABSOLUTEPARSING EQU 80028000h
SIGDN_PARENTRELATIVEEDITING	EQU 80031001h
SIGDN_DESKTOPABSOLUTEEDITING EQU 8004C000h
SIGDN_FILESYSPATH	        EQU 80058000h
SIGDN_URL	                EQU 80068000h
SIGDN_PARENTRELATIVEFORADDRESSBAR EQU 8007C001h
SIGDN_PARENTRELATIVE	    EQU 80080001h

.DATA
CLSID_FileOpenDialog         GUID <0DC1C5A9Ch,0E88Ah,04ddeh,<0A5h,0A1h,060h,0F8h,02Ah,020h,0AEh,0F7h>>
CLSID_FileSaveDialog         GUID <0C0B4E2F3h,0BA21h,04773h,<08Dh,0BAh,033h,05Eh,0C9h,046h,0EBh,08Bh>>

IID_IShellItem               GUID <043826d1eh,0e718h,042eeh,<0bch,055h,0a1h,0e2h,061h,0c3h,07bh,0feh>>
IID_IShellItem2              GUID <07e9fb0d3h,0919fh,04307h,<0abh,02eh,09bh,018h,060h,031h,00ch,093h>>
IID_IEnumShellItems          GUID <070629033h,0e363h,04a28h,<0a5h,067h,00dh,0b7h,080h,006h,0e6h,0d7h>>
IID_IShellItemResources      GUID <0ff5693beh,02ce0h,04d48h,<0b5h,0c5h,040h,081h,07dh,01ah,0cdh,0b9h>>
IID_IShellItemArray          GUID <0b63ea76dh,01f85h,0456fh,<0a1h,09ch,048h,015h,09eh,0fah,085h,08bh>>
IID_IModalWindow             GUID <0b4db1657h,070d7h,0485eh,<08eh,03eh,06fh,0cbh,05ah,05ch,018h,002h>>
IID_IFileDialogEvents        GUID <0973510dbh,07d7fh,0452bh,<089h,075h,074h,0a8h,058h,028h,0d3h,054h>>
IID_IFileDialog              GUID <042f85136h,0db7eh,0439ch,<085h,0f1h,0e4h,007h,05dh,013h,05fh,0c8h>>
IID_IFileSaveDialog          GUID <084bccd23h,05fdeh,04cdbh,<0aeh,0a4h,0afh,064h,0b8h,03dh,078h,0abh>>
IID_IFileOpenDialog          GUID <0d57c7288h,0d4adh,04768h,<0beh,002h,09dh,096h,095h,032h,0d9h,060h>>
IID_IFileDialogCustomize     GUID <0e6fdd21ah,0163fh,04975h,<09ch,08ch,0a6h,09fh,01bh,0a3h,070h,034h>>
IID_IFileDialogControlEvents GUID <036116642h,0D713h,04b97h,<09Bh,083h,074h,084h,0A9h,0D0h,004h,033h>>
IID_IFileDialog2             GUID <061744fc7h,085b5h,04791h,<0a9h,0b0h,027h,022h,076h,030h,09bh,013h>>
IID_IBrowserFrameOptions     GUID <010DF43C8h,01DBEh,011d3h,<08Bh,034h,000h,060h,097h,0DFh,05Bh,0D4h>>
IID_IKnownFolder             GUID <03AA7AF7Eh,09B36h,0420ch,<0A8h,0E3h,0F7h,07Dh,046h,074h,0A4h,088h>>
IID_IKnownFolderManager      GUID <08BE2D872h,086AAh,04d47h,<0B7h,076h,032h,0CCh,0A4h,00Ch,070h,018h>>
IID_IShellItemFilter         GUID <02659B475h,0EEB8h,048b7h,<08Fh,007h,0B3h,078h,081h,00Fh,048h,0CFh>>
IID_IUnknown                 GUID <000000000h,00000h,00000h,<0C0h,000h,000h,000h,000h,000h,000h,046h>>

;------------------------------------------------------------------------------
; Function Pointers
;------------------------------------------------------------------------------

; IUnknown
IUnknown_QueryInterface             IUnknown_QueryInterface_Ptr 0
IUnknown_AddRef                     IUnknown_AddRef_Ptr 0
IUnknown_Release                    IUnknown_Release_Ptr 0

; IModalWindow
IModalWindow_Show                   IModalWindow_Show_Ptr 0

; IFileDialog
IFileDialog_QueryInterface          IFileDialog_QueryInterface_Ptr 0
IFileDialog_AddRef                  IFileDialog_AddRef_Ptr 0
IFileDialog_Release                 IFileDialog_Release_Ptr 0
IFileDialog_Show                    IFileDialog_Show_Ptr 0
IFileDialog_SetFileTypes            IFileDialog_SetFileTypes_Ptr 0
IFileDialog_SetFileTypeIndex        IFileDialog_SetFileTypeIndex_Ptr 0
IFileDialog_GetFileTypeIndex        IFileDialog_GetFileTypeIndex_Ptr 0
IFileDialog_Advise                  IFileDialog_Advise_Ptr 0
IFileDialog_Unadvise                IFileDialog_Unadvise_Ptr 0
IFileDialog_SetOptions              IFileDialog_SetOptions_Ptr 0
IFileDialog_GetOptions              IFileDialog_GetOptions_Ptr 0
IFileDialog_SetDefaultFolder        IFileDialog_SetDefaultFolder_Ptr 0
IFileDialog_SetFolder               IFileDialog_SetFolder_Ptr 0
IFileDialog_GetFolder               IFileDialog_GetFolder_Ptr 0
IFileDialog_GetCurrentSelection     IFileDialog_GetCurrentSelection_Ptr 0
IFileDialog_SetFileName             IFileDialog_SetFileName_Ptr 0
IFileDialog_GetFileName             IFileDialog_GetFileName_Ptr 0
IFileDialog_SetTitle                IFileDialog_SetTitle_Ptr 0
IFileDialog_SetOkButtonLabel        IFileDialog_SetOkButtonLabel_Ptr 0
IFileDialog_SetFileNameLabel        IFileDialog_SetFileNameLabel_Ptr 0
IFileDialog_GetResult               IFileDialog_GetResult_Ptr 0
IFileDialog_AddPlace                IFileDialog_AddPlace_Ptr 0
IFileDialog_SetDefaultExtension     IFileDialog_SetDefaultExtension_Ptr 0
IFileDialog_Close                   IFileDialog_Close_Ptr 0
IFileDialog_SetClientGuid           IFileDialog_SetClientGuid_Ptr 0
IFileDialog_ClearClientData         IFileDialog_ClearClientData_Ptr 0
IFileDialog_SetFilter               IFileDialog_SetFilter_Ptr 0

; IFileSaveDialog
IFileSaveDialog_QueryInterface      EQU IFileDialog_QueryInterface      
IFileSaveDialog_AddRef              EQU IFileDialog_AddRef              
IFileSaveDialog_Release             EQU IFileDialog_Release             
IFileSaveDialog_Show                EQU IFileDialog_Show                
IFileSaveDialog_SetFileTypes        EQU IFileDialog_SetFileTypes        
IFileSaveDialog_SetFileTypeIndex    EQU IFileDialog_SetFileTypeIndex    
IFileSaveDialog_GetFileTypeIndex    EQU IFileDialog_GetFileTypeIndex    
IFileSaveDialog_Advise              EQU IFileDialog_Advise              
IFileSaveDialog_Unadvise            EQU IFileDialog_Unadvise            
IFileSaveDialog_SetOptions          EQU IFileDialog_SetOptions          
IFileSaveDialog_GetOptions          EQU IFileDialog_GetOptions          
IFileSaveDialog_SetDefaultFolder    EQU IFileDialog_SetDefaultFolder    
IFileSaveDialog_SetFolder           EQU IFileDialog_SetFolder           
IFileSaveDialog_GetFolder           EQU IFileDialog_GetFolder           
IFileSaveDialog_GetCurrentSelection EQU IFileDialog_GetCurrentSelection 
IFileSaveDialog_SetFileName         EQU IFileDialog_SetFileName         
IFileSaveDialog_GetFileName         EQU IFileDialog_GetFileName         
IFileSaveDialog_SetTitle            EQU IFileDialog_SetTitle            
IFileSaveDialog_SetOkButtonLabel    EQU IFileDialog_SetOkButtonLabel    
IFileSaveDialog_SetFileNameLabel    EQU IFileDialog_SetFileNameLabel    
IFileSaveDialog_GetResult           EQU IFileDialog_GetResult           
IFileSaveDialog_AddPlace            EQU IFileDialog_AddPlace            
IFileSaveDialog_SetDefaultExtension EQU IFileDialog_SetDefaultExtension 
IFileSaveDialog_Close               EQU IFileDialog_Close               
IFileSaveDialog_SetClientGuid       EQU IFileDialog_SetClientGuid       
IFileSaveDialog_ClearClientData     EQU IFileDialog_ClearClientData     
IFileSaveDialog_SetFilter           EQU IFileDialog_SetFilter           
IFileSaveDialog_SetSaveAsItem       IFileSaveDialog_SetSaveAsItem_Ptr 0
IFileSaveDialog_SetProperties       IFileSaveDialog_SetProperties_Ptr 0
IFileSaveDialog_SetCollectedProperties IFileSaveDialog_SetCollectedProperties_Ptr 0
IFileSaveDialog_GetProperties       IFileSaveDialog_GetProperties_Ptr 0
IFileSaveDialog_ApplyProperties     IFileSaveDialog_ApplyProperties_Ptr 0

; IFileOpenDialog
IFileOpenDialog_QueryInterface      EQU IFileDialog_QueryInterface      
IFileOpenDialog_AddRef              EQU IFileDialog_AddRef              
IFileOpenDialog_Release             EQU IFileDialog_Release             
IFileOpenDialog_Show                EQU IFileDialog_Show                
IFileOpenDialog_SetFileTypes        EQU IFileDialog_SetFileTypes        
IFileOpenDialog_SetFileTypeIndex    EQU IFileDialog_SetFileTypeIndex    
IFileOpenDialog_GetFileTypeIndex    EQU IFileDialog_GetFileTypeIndex    
IFileOpenDialog_Advise              EQU IFileDialog_Advise              
IFileOpenDialog_Unadvise            EQU IFileDialog_Unadvise            
IFileOpenDialog_SetOptions          EQU IFileDialog_SetOptions          
IFileOpenDialog_GetOptions          EQU IFileDialog_GetOptions          
IFileOpenDialog_SetDefaultFolder    EQU IFileDialog_SetDefaultFolder    
IFileOpenDialog_SetFolder           EQU IFileDialog_SetFolder           
IFileOpenDialog_GetFolder           EQU IFileDialog_GetFolder           
IFileOpenDialog_GetCurrentSelection EQU IFileDialog_GetCurrentSelection 
IFileOpenDialog_SetFileName         EQU IFileDialog_SetFileName         
IFileOpenDialog_GetFileName         EQU IFileDialog_GetFileName         
IFileOpenDialog_SetTitle            EQU IFileDialog_SetTitle            
IFileOpenDialog_SetOkButtonLabel    EQU IFileDialog_SetOkButtonLabel    
IFileOpenDialog_SetFileNameLabel    EQU IFileDialog_SetFileNameLabel    
IFileOpenDialog_GetResult           EQU IFileDialog_GetResult           
IFileOpenDialog_AddPlace            EQU IFileDialog_AddPlace            
IFileOpenDialog_SetDefaultExtension EQU IFileDialog_SetDefaultExtension 
IFileOpenDialog_Close               EQU IFileDialog_Close               
IFileOpenDialog_SetClientGuid       EQU IFileDialog_SetClientGuid       
IFileOpenDialog_ClearClientData     EQU IFileDialog_ClearClientData     
IFileOpenDialog_SetFilter           EQU IFileDialog_SetFilter           
IFileOpenDialog_GetResults          IFileOpenDialog_GetResults_Ptr 0
IFileOpenDialog_GetSelectedItems    IFileOpenDialog_GetSelectedItems_Ptr 0

; IShellItem
IShellItem_QueryInterface           IShellItem_QueryInterface_Ptr 0
IShellItem_AddRef                   IShellItem_AddRef_Ptr 0
IShellItem_Release                  IShellItem_Release_Ptr 0
IShellItem_BindToHandler            IShellItem_BindToHandler_Ptr 0
IShellItem_GetParent                IShellItem_GetParent_Ptr 0
IShellItem_GetDisplayName           IShellItem_GetDisplayName_Ptr 0
IShellItem_GetAttributes            IShellItem_GetAttributes_Ptr 0
IShellItem_Compare                  IShellItem_Compare_Ptr 0

; IShellItemArray
IShellItemArray_QueryInterface      IShellItemArray_QueryInterface_Ptr 0
IShellItemArray_AddRef              IShellItemArray_AddRef_Ptr 0
IShellItemArray_Release             IShellItemArray_Release_Ptr 0
IShellItemArray_BindToHandler       IShellItemArray_BindToHandler_Ptr 0
IShellItemArray_GetPropertyStore    IShellItemArray_GetPropertyStore_Ptr 0
IShellItemArray_GetPropertyDescriptionList IShellItemArray_GetPropertyDescriptionList_Ptr 0
IShellItemArray_GetAttributes       IShellItemArray_GetAttributes_Ptr 0
IShellItemArray_GetCount            IShellItemArray_GetCount_Ptr 0
IShellItemArray_GetItemAt           IShellItemArray_GetItemAt_Ptr 0
IShellItemArray_EnumItems           IShellItemArray_EnumItems_Ptr 0

; All files (*.*) default filespec
szAllFilesW         DB "A",0,"l",0,"l",0," ",0,"F",0,"i",0,"l",0,"e",0,"s",0," ",0,"(",0,"*",0,".",0,"*",0,")",0,0,0,0,0
szAllFilesSpecW     DB "*",0,".",0,"*",0,0,0,0,0

DefaultMFSW         \
COMDLG_FILTERSPEC   <Offset szAllFilesW, Offset szAllFilesSpecW>


.CODE

ALIGN 8
;------------------------------------------------------------------------------
; FileOpenDialogA
;
; Creates an Open dialog box that lets the user specify the drive, directory, 
; and the name of a file or set of files to be opened.
; 
; Parameters:
; 
; * lpszTitle - pointer to a string for the title of the open dialog.
;
; * lpszOkLabel - pointer to a string for the ok button in the open dialog.
;
; * lpszFileLabel - pointer to a string for the file label in the open dialog.
;
; * lpszFolder - pointer to a string for the initial folder to start in.
;
; * nMFS - number of COMDLG_FILTERSPEC structures pointed to by pMFS.
;
; * pMFS - array of COMDLG_FILTERSPEC structures for multi file spec.
;
; * hWndOwner - handle of the parent window that owns this open dialog.
;
; * bMulti - allow multiple file selection (TRUE) or single file only (FALSE)
;
; * lpdwFiles - pointer to a variable that stores the number of files that the
;   user selected to 'open' and the number of files in the lpFilesArray array 
;   of filenames.   

; * lpFilesArray - pointer to a variable that stores a pointer to a null 
;   separated list of filenames that the user selected to 'open'. The list ends
;   with a double null.
; 
; Returns:
; 
; TRUE if successful, or FALSE otherwise.
; 
; Notes:
;
; This is the Ansi version of FileOpenDialog. All strings passed as parameters 
; are expected to be Ansi strings, and the return results are stored in the
; lpFilesArray parameter as a pointer to an array of Ansi strings.
;
; For the Wide/Unicode version see the FileOpenDialogW function.
;
; FileOpenDialog Implements the common file open dialog (CLSID_FileOpenDialog)
;
; See Also:
;
; FileSaveDialogA, FolderSelectDialogA
; 
;------------------------------------------------------------------------------
FileOpenDialogA PROC USES EBX lpszTitle:DWORD, lpszOkLabel:DWORD, lpszFileLabel:DWORD, lpszFolder:DWORD, nMFS:DWORD, pMFS:DWORD, hWndOwner:DWORD, bMulti:DWORD, lpdwFiles:DWORD, lpFilesArray:DWORD
    LOCAL pIFOD:DWORD       ; pointer to IFileOpenDialog
    LOCAL pISIA:DWORD       ; pointer to IShellItemArray
    LOCAL pISI:DWORD        ; pointer to IShellItem
    LOCAL pISIF:DWORD       ; pointer to IShellItem for lpszFolder
    LOCAL dwOptions:DWORD
    LOCAL dwFileCount:DWORD
    LOCAL nCount:DWORD
    LOCAL pFileArray:DWORD
    LOCAL pFileName:DWORD
    LOCAL dwFileNameLength:DWORD
    LOCAL dwFileArraySize:DWORD
    LOCAL nPos:DWORD
    LOCAL lpszWideTitle:DWORD
    LOCAL lpszWideOkLabel:DWORD
    LOCAL lpszWideFileLabel:DWORD
    LOCAL lpszWideFolder:DWORD
    LOCAL pWideMFS:DWORD
    LOCAL pCurFileSpecSrc:DWORD
    LOCAL pCurFileSpecDest:DWORD
    LOCAL lpszString:DWORD
    LOCAL dwReturnResult:DWORD
    
    .IF lpdwFiles == 0 || lpFilesArray == 0
        mov eax, FALSE
        ret
    .ENDIF
    
    ;--------------------------------------------------------------------------
    ; Initialize
    ;--------------------------------------------------------------------------
    mov dwReturnResult, FALSE
    mov dwFileCount, 0
    mov lpszWideTitle, 0
    mov lpszWideOkLabel, 0
    mov lpszWideFileLabel, 0
    mov lpszWideFolder, 0
    mov pWideMFS, 0
    mov pCurFileSpecSrc, 0
    mov pCurFileSpecDest, 0
    mov pFileArray, 0
    mov dwFileArraySize, 0
    mov dwOptions, 0
    mov pIFOD, 0
    mov pISIA, 0
    mov pISI, 0
    mov pISIF, 0
    
    Invoke CoInitializeEx, NULL, COINIT_APARTMENTTHREADED
    
    Invoke IFileOpenDialogInit, Addr pIFOD
    .IF eax == FALSE
        IFDEF DEBUG32
        PrintText 'FileOpenDialogA IFileOpenDialogInit Failed'
        ENDIF
        jmp FileOpenDialogA_Exit
    .ENDIF
    
    ;--------------------------------------------------------------------------
    ; Set Title
    ;--------------------------------------------------------------------------
    .IF lpszTitle != NULL
        Invoke _FD_ConvertStringToWide, lpszTitle
        mov lpszWideTitle, eax
    
        Invoke IFileOpenDialog_SetTitle, pIFOD, lpszWideTitle
        .IF eax != S_OK
            IFDEF DEBUG32
            PrintText 'FileOpenDialogA SetTitle Failed'
            ENDIF
            jmp FileOpenDialogA_Exit
        .ENDIF
    .ENDIF
    
    ;--------------------------------------------------------------------------
    ; Set Ok Label
    ;--------------------------------------------------------------------------
    .IF lpszOkLabel != NULL
        Invoke _FD_ConvertStringToWide, lpszOkLabel
        mov lpszWideOkLabel, eax
    
        Invoke IFileOpenDialog_SetOkButtonLabel, pIFOD, lpszWideOkLabel
        .IF eax != S_OK
            IFDEF DEBUG32
            PrintText 'FileOpenDialogA SetOkButtonLabel Failed'
            ENDIF
            jmp FileOpenDialogA_Exit
        .ENDIF
    .ENDIF
    
    ;--------------------------------------------------------------------------
    ; Set File Label
    ;--------------------------------------------------------------------------
    .IF lpszFileLabel != NULL
        Invoke _FD_ConvertStringToWide, lpszFileLabel
        mov lpszWideFileLabel, eax
    
        Invoke IFileOpenDialog_SetFileNameLabel, pIFOD, lpszWideFileLabel
        .IF eax != S_OK
            IFDEF DEBUG32
            PrintText 'FileOpenDialogA SetFileNameLabel Failed'
            ENDIF
            jmp FileOpenDialogA_Exit
        .ENDIF
    .ENDIF
    
    ;--------------------------------------------------------------------------
    ; Set Inital Folder 
    ;--------------------------------------------------------------------------
    .IF lpszFolder != NULL
        Invoke _FD_ConvertStringToWide, lpszFolder
        mov lpszWideFolder, eax
    
        Invoke SHCreateItemFromParsingName, lpszWideFolder, NULL, Addr IID_IShellItem, Addr pISIF
        .IF eax != S_OK
            IFDEF DEBUG32
            PrintText 'FileOpenDialogA SHCreateItemFromParsingName lpszFolder Failed'
            ENDIF
            ;jmp FileOpenDialogA_Exit
        .ELSE
            Invoke IFileOpenDialog_SetFolder, pIFOD, pISIF
            .IF eax != S_OK
                IFDEF DEBUG32
                PrintText 'FileOpenDialogA SetFolder Failed'
                ENDIF
                ;jmp FileOpenDialogA_Exit
            .ENDIF
        .ENDIF
    .ENDIF
    
    ;--------------------------------------------------------------------------
    ; Multi File Spec
    ;--------------------------------------------------------------------------
    .IF pMFS != NULL && nMFS != 0

        mov eax, nMFS
        mov ebx, SIZEOF COMDLG_FILTERSPEC
        mul ebx
        Invoke GlobalAlloc, GMEM_FIXED or GMEM_ZEROINIT, eax
        .IF eax == NULL
            jmp FileOpenDialogA_Exit
        .ENDIF
        mov pWideMFS, eax
        
        mov eax, pWideMFS
        mov pCurFileSpecDest, eax
        mov eax, pMFS
        mov pCurFileSpecSrc, eax
        
        mov nCount, 0
        mov eax, 0
        .WHILE eax < nMFS
            mov ebx, pCurFileSpecSrc
            mov eax, [ebx].COMDLG_FILTERSPEC.pszName
            mov lpszString, eax
            Invoke _FD_ConvertStringToWide, lpszString
           
            mov ebx, pCurFileSpecDest
            mov [ebx].COMDLG_FILTERSPEC.pszName, eax
            
            mov ebx, pCurFileSpecSrc
            mov eax, [ebx].COMDLG_FILTERSPEC.pszSpec
            mov lpszString, eax
            Invoke _FD_ConvertStringToWide, lpszString
            
            mov ebx, pCurFileSpecDest
            mov [ebx].COMDLG_FILTERSPEC.pszSpec, eax
            
            add pCurFileSpecDest, SIZEOF COMDLG_FILTERSPEC
            add pCurFileSpecSrc, SIZEOF COMDLG_FILTERSPEC
            inc nCount
            mov eax, nCount
        .ENDW
    
        Invoke IFileOpenDialog_SetFileTypes, pIFOD, nMFS, pWideMFS
        .IF eax != S_OK
            IFDEF DEBUG32
            PrintText 'FileOpenDialogA SetFileTypes Failed'
            ENDIF
            jmp FileOpenDialogA_Exit
        .ELSE
            Invoke IFileOpenDialog_SetFileTypeIndex, pIFOD, 1
        .ENDIF
    .ELSE
        Invoke IFileOpenDialog_SetFileTypes, pIFOD, 1, Addr DefaultMFSW
        .IF eax != S_OK
            IFDEF DEBUG32
            PrintText 'FileOpenDialogA SetFileTypes Failed'
            ENDIF
            jmp FileOpenDialogA_Exit
        .ELSE
            Invoke IFileOpenDialog_SetFileTypeIndex, pIFOD, 1
        .ENDIF
    .ENDIF
    
    ;--------------------------------------------------------------------------
    ; Set options: multi select or single select
    ;--------------------------------------------------------------------------
    mov dwOptions, FOS_FORCEFILESYSTEM or FOS_FORCESHOWHIDDEN
    .IF bMulti == TRUE
        or dwOptions, FOS_ALLOWMULTISELECT
    .ENDIF
    Invoke IFileOpenDialog_SetOptions, pIFOD, dwOptions
    .IF eax != S_OK
        IFDEF DEBUG32
        PrintText 'FileOpenDialogA SetOptions Failed'
        ENDIF
        jmp FileOpenDialogA_Exit
    .ENDIF
    
    ;--------------------------------------------------------------------------
    ; Show The Open Dialog 
    ;--------------------------------------------------------------------------
    Invoke IFileOpenDialog_Show, pIFOD, hWndOwner
    .IF eax == HRESULT_ERROR_CANCELLED
        IFDEF DEBUG32
        PrintText 'FileOpenDialogA Cancelled'
        ENDIF
        mov dwReturnResult, TRUE
        jmp FileOpenDialogA_Exit
    .ELSEIF eax != S_OK
        IFDEF DEBUG32
        PrintText 'FileOpenDialogA Show Failed'
        ENDIF
        jmp FileOpenDialogA_Exit
    .ENDIF
    IFDEF DEBUG32
    PrintText 'FileOpenDialogA Show Ok'
    ENDIF
    
    ;--------------------------------------------------------------------------
    ; Get the results and loop through the results array
    ;--------------------------------------------------------------------------
    Invoke IFileOpenDialog_GetResults, pIFOD, Addr pISIA
    Invoke IShellItemArrayInit, pISIA
    Invoke IShellItemArray_GetCount, pISIA, Addr dwFileCount
    
    .IF dwFileCount != 0
        
        IFDEF DEBUG32
        PrintDec dwFileCount
        ENDIF
        
        ;----------------------------------------------------------------------
        ; Loop through results and calc sizes of filenames for filename array
        ;----------------------------------------------------------------------
        mov nCount, 0
        xor ebx, ebx
        .WHILE ebx < dwFileCount    
            
            ; Get filename in each item in the results array 
            Invoke IShellItemArray_GetItemAt, pISIA, ebx, Addr pISI
            mov eax, pISI
            mov ebx, [eax]
            Invoke [ebx].IShellItemVtbl.GetDisplayName, pISI, SIGDN_FILESYSPATH, Addr pFileName
            
            Invoke lstrlenW, pFileName
            ;shl eax, 1 ; x2 for unicode chars to bytes
            add eax, 1 ; for null terminator
            add dwFileArraySize, eax
            
            Invoke CoTaskMemFree, pFileName
            
            mov eax, pISI
            mov ebx, [eax]
            Invoke [ebx].IShellItemVtbl.Release, pISI
            
            inc nCount
            mov ebx, nCount
        .ENDW
        add dwFileArraySize, 1 ; for double null
        
        ;----------------------------------------------------------------------
        ; Allocate memory for filename array
        ;----------------------------------------------------------------------
        mov eax, dwFileArraySize
        add eax, 8 ; just in case
        Invoke GlobalAlloc, GMEM_FIXED or GMEM_ZEROINIT, eax
        .IF eax == NULL
            jmp FileOpenDialogA_Exit
        .ENDIF
        mov pFileArray, eax
        
        ;----------------------------------------------------------------------
        ; Loop through results and copy filenames to filename array
        ;----------------------------------------------------------------------
        mov nPos, 0
        mov nCount, 0
        xor ebx, ebx
        .WHILE ebx < dwFileCount    
        
            ; Get filename in each item in the results array 
            Invoke IShellItemArray_GetItemAt, pISIA, ebx, Addr pISI
            mov eax, pISI
            mov ebx, [eax]
            Invoke [ebx].IShellItemVtbl.GetDisplayName, pISI, SIGDN_FILESYSPATH, Addr pFileName
            
            Invoke _FD_ConvertStringToAnsi, pFileName
            mov lpszString, eax
            
            Invoke lstrlenA, lpszString
            mov dwFileNameLength, eax
            
            mov ebx, pFileArray
            add ebx, nPos
            Invoke RtlMoveMemory, ebx, lpszString, dwFileNameLength
            
            Invoke _FD_ConvertStringFree, lpszString
            
            Invoke CoTaskMemFree, pFileName
            
            mov eax, pISI
            mov ebx, [eax]
            Invoke [ebx].IShellItemVtbl.Release, pISI
            
            mov eax, dwFileNameLength
            add eax, 1 ; for null terminator
            add nPos, eax
            
            inc nCount
            mov ebx, nCount
        .ENDW
    
        IFDEF DEBUG32
        DbgDump pFileArray, dwFileArraySize
        ENDIF
    
    .ENDIF
    
    mov dwReturnResult, TRUE
    
FileOpenDialogA_Exit:
 
    ;--------------------------------------------------------------------------
    ; Free up any objects
    ;--------------------------------------------------------------------------
    .IF pISIF != 0
        mov eax, pISIF
        mov ebx, [eax]
        Invoke [ebx].IShellItemVtbl.Release, pISIF
    .ENDIF
    
    .IF pISIA != 0
        Invoke IShellItemArray_Release, pISIA
    .ENDIF
    
    .IF pIFOD != 0
        Invoke IFileOpenDialog_Release, pIFOD
    .ENDIF    
        
    ;--------------------------------------------------------------------------
    ; Free up any wide strings we created
    ;--------------------------------------------------------------------------
    .IF lpszWideTitle != 0
        Invoke _FD_ConvertStringFree, lpszWideTitle
    .ENDIF
    .IF lpszWideOkLabel != 0
        Invoke _FD_ConvertStringFree, lpszWideOkLabel
    .ENDIF
    .IF lpszWideFileLabel != 0
        Invoke _FD_ConvertStringFree, lpszWideFileLabel
    .ENDIF
    .IF lpszWideFolder != 0
        Invoke _FD_ConvertStringFree, lpszWideFolder
    .ENDIF

    ;--------------------------------------------------------------------------
    ; Free up wide conversion of MultiFileSpec strings
    ;--------------------------------------------------------------------------
    .IF pWideMFS != 0
        mov eax, pWideMFS
        mov pCurFileSpecSrc, eax
        mov nCount, 0
        mov eax, 0
        .WHILE eax < nMFS
        
            mov ebx, pCurFileSpecSrc
            mov eax, [ebx].COMDLG_FILTERSPEC.pszName
            .IF eax != 0
                mov lpszString, eax
                Invoke _FD_ConvertStringFree, lpszString
            .ENDIF
            
            mov ebx, pCurFileSpecSrc
            mov eax, [ebx].COMDLG_FILTERSPEC.pszSpec
            .IF eax != 0
                mov lpszString, eax
                Invoke _FD_ConvertStringFree, lpszString
            .ENDIF
            
            add pCurFileSpecSrc, SIZEOF COMDLG_FILTERSPEC
            inc nCount
            mov eax, nCount
        .ENDW
        Invoke GlobalFree, pWideMFS
    .ENDIF
    
    ;--------------------------------------------------------------------------
    ; Return file count and pointer to file array
    ;--------------------------------------------------------------------------
    .IF lpdwFiles != 0
        mov ebx, lpdwFiles
        mov eax, dwFileCount
        mov [ebx], eax
    .ENDIF
    
    .IF lpFilesArray != 0
        mov ebx, lpFilesArray
        mov eax, pFileArray
        mov [ebx], eax
    .ENDIF
    
    Invoke CoUninitialize
    mov eax, dwReturnResult

    ret
FileOpenDialogA ENDP

ALIGN 8
;------------------------------------------------------------------------------
; FileOpenDialogW
; 
; Creates an Open dialog box that lets the user specify the drive, directory, 
; and the name of a file or set of files to be opened.
;
; Parameters:
; 
; * lpszTitle - pointer to a string for the title of the open dialog.
;
; * lpszOkLabel - pointer to a string for the ok button in the open dialog.
;
; * lpszFileLabel - pointer to a string for the file label in the open dialog.
;
; * lpszFolder - pointer to a string for the initial folder to start in.
;
; * nMFS - number of COMDLG_FILTERSPEC structures pointed to by pMFS.
;
; * pMFS - array of COMDLG_FILTERSPEC structures for multi file spec.
;
; * hWndOwner - handle of the parent window that owns this open dialog.
;
; * bMulti - allow multiple file selection (TRUE) or single file only (FALSE)
;
; * lpdwFiles - pointer to a variable that stores the number of files that the
;   user selected to 'open' and the number of files in the lpFilesArray array 
;   of filenames.   

; * lpFilesArray - pointer to a variable that stores a pointer to a null 
;   separated list of filenames that the user selected to 'open'. The list ends
;   with a double null.
; 
; Returns:
; 
; TRUE if successful, or FALSE otherwise.
; 
; Notes:
;
; This is the Wide/Unicode version of FileOpenDialog. All strings passed as 
; parameters are expected to be Wide/Unicode strings, and the return results 
; are stored in the lpFilesArray parameter as a pointer to an array of 
; Wide/Unicode strings.
;
; For the Ansi version see the FileOpenDialogA function.
;
; FileOpenDialog Implements the common file open dialog (CLSID_FileOpenDialog)
;
; See Also:
;
; FileSaveDialogW, FolderSelectDialogW
; 
;------------------------------------------------------------------------------
FileOpenDialogW PROC USES EBX lpszTitle:DWORD, lpszOkLabel:DWORD, lpszFileLabel:DWORD, lpszFolder:DWORD, nMFS:DWORD, pMFS:DWORD, hWndOwner:DWORD, bMulti:DWORD, lpdwFiles:DWORD, lpFilesArray:DWORD
    LOCAL pIFOD:DWORD       ; pointer to IFileOpenDialog
    LOCAL pISIA:DWORD       ; pointer to IShellItemArray
    LOCAL pISI:DWORD        ; pointer to IShellItem
    LOCAL pISIF:DWORD       ; pointer to IShellItem for lpszFolder
    LOCAL dwOptions:DWORD
    LOCAL dwFileCount:DWORD
    LOCAL nCount:DWORD
    LOCAL pFileArray:DWORD
    LOCAL pFileName:DWORD
    LOCAL dwFileNameLength:DWORD
    LOCAL dwFileArraySize:DWORD
    LOCAL nPos:DWORD
    LOCAL dwReturnResult:DWORD
    
    .IF lpdwFiles == 0 || lpFilesArray == 0
        mov eax, FALSE
        ret
    .ENDIF
    
    ;--------------------------------------------------------------------------
    ; Initialize
    ;--------------------------------------------------------------------------
    mov dwReturnResult, FALSE
    mov dwFileCount, 0
    mov pFileArray, 0
    mov dwFileArraySize, 0
    mov dwOptions, 0
    mov pIFOD, 0
    mov pISIA, 0
    mov pISI, 0
    mov pISIF, 0
    
    Invoke CoInitializeEx, NULL, COINIT_APARTMENTTHREADED
    
    Invoke IFileOpenDialogInit, Addr pIFOD
    .IF eax == FALSE
        IFDEF DEBUG32
        PrintText 'FileOpenDialogW IFileOpenDialogInit Failed'
        ENDIF
        jmp FileOpenDialogW_Exit
    .ENDIF
    
    ;--------------------------------------------------------------------------
    ; Set Title
    ;--------------------------------------------------------------------------
    .IF lpszTitle != NULL
        Invoke IFileOpenDialog_SetTitle, pIFOD, lpszTitle
        .IF eax != S_OK
            IFDEF DEBUG32
            PrintText 'FileOpenDialogW SetTitle Failed'
            ENDIF
            jmp FileOpenDialogW_Exit
        .ENDIF
    .ENDIF
    
    ;--------------------------------------------------------------------------
    ; Set Ok Label
    ;--------------------------------------------------------------------------
    .IF lpszOkLabel != NULL
        Invoke IFileOpenDialog_SetOkButtonLabel, pIFOD, lpszOkLabel
        .IF eax != S_OK
            IFDEF DEBUG32
            PrintText 'FileOpenDialogW SetOkButtonLabel Failed'
            ENDIF
            jmp FileOpenDialogW_Exit
        .ENDIF
    .ENDIF
    
    ;--------------------------------------------------------------------------
    ; Set File Label
    ;--------------------------------------------------------------------------
    .IF lpszFileLabel != NULL
        Invoke IFileOpenDialog_SetFileNameLabel, pIFOD, lpszFileLabel
        .IF eax != S_OK
            IFDEF DEBUG32
            PrintText 'FileOpenDialogW SetFileNameLabel Failed'
            ENDIF
            jmp FileOpenDialogW_Exit
        .ENDIF
    .ENDIF
    
    ;--------------------------------------------------------------------------
    ; Set Inital Folder 
    ;--------------------------------------------------------------------------
    .IF lpszFolder != NULL
        Invoke SHCreateItemFromParsingName, lpszFolder, NULL, Addr IID_IShellItem, Addr pISIF
        .IF eax != S_OK
            IFDEF DEBUG32
            PrintText 'FileOpenDialogW SHCreateItemFromParsingName lpszFolder Failed'
            ENDIF
            ;jmp FileOpenDialogW_Exit
        .ELSE
            Invoke IFileOpenDialog_SetFolder, pIFOD, pISIF
            .IF eax != S_OK
                IFDEF DEBUG32
                PrintText 'FileOpenDialogW SetFolder Failed'
                ENDIF
                ;jmp FileOpenDialogW_Exit
            .ENDIF
        .ENDIF
    .ENDIF
    
    ;--------------------------------------------------------------------------
    ; Multi File Spec
    ;--------------------------------------------------------------------------
    .IF pMFS != NULL && nMFS != 0
        Invoke IFileDialog_SetFileTypes, pIFOD, nMFS, pMFS
        .IF eax != S_OK
            IFDEF DEBUG32
            PrintText 'FileOpenDialogW SetFileTypes Failed'
            ENDIF
            jmp FileOpenDialogW_Exit
        .ELSE
            Invoke IFileOpenDialog_SetFileTypeIndex, pIFOD, 1
        .ENDIF
    .ELSE
        Invoke IFileOpenDialog_SetFileTypes, pIFOD, 1, Addr DefaultMFSW
        .IF eax != S_OK
            IFDEF DEBUG32
            PrintText 'FileOpenDialogW SetFileTypes Failed'
            ENDIF
            jmp FileOpenDialogW_Exit
        .ELSE
            Invoke IFileOpenDialog_SetFileTypeIndex, pIFOD, 1
        .ENDIF
    .ENDIF
    
    ;--------------------------------------------------------------------------
    ; Set options: multi select or single select
    ;--------------------------------------------------------------------------
    mov dwOptions, FOS_FORCEFILESYSTEM or FOS_FORCESHOWHIDDEN
    .IF bMulti == TRUE
        or dwOptions, FOS_ALLOWMULTISELECT
    .ENDIF
    Invoke IFileOpenDialog_SetOptions, pIFOD, dwOptions
    .IF eax != S_OK
        IFDEF DEBUG32
        PrintText 'FileOpenDialogW SetOptions Failed'
        ENDIF
        jmp FileOpenDialogW_Exit
    .ENDIF
    
    ;--------------------------------------------------------------------------
    ; Show The Open Dialog 
    ;--------------------------------------------------------------------------
    Invoke IFileOpenDialog_Show, pIFOD, hWndOwner
    .IF eax == HRESULT_ERROR_CANCELLED
        IFDEF DEBUG32
        PrintText 'FileOpenDialogW Cancelled'
        ENDIF
        mov dwReturnResult, TRUE
        jmp FileOpenDialogW_Exit
    .ELSEIF eax != S_OK
        IFDEF DEBUG32
        PrintText 'FileOpenDialogW Show Failed'
        ENDIF
        jmp FileOpenDialogW_Exit
    .ENDIF
    IFDEF DEBUG32
    PrintText 'FileOpenDialogW Show Ok'
    ENDIF
    
    ;--------------------------------------------------------------------------
    ; Get the results and loop through the results array
    ;--------------------------------------------------------------------------
    Invoke IFileOpenDialog_GetResults, pIFOD, Addr pISIA
    Invoke IShellItemArrayInit, pISIA
    Invoke IShellItemArray_GetCount, pISIA, Addr dwFileCount
    
    .IF dwFileCount != 0
        
        IFDEF DEBUG32
        PrintDec dwFileCount
        ENDIF
        
        ;----------------------------------------------------------------------
        ; Loop through results and calc sizes of filenames for filename array
        ;----------------------------------------------------------------------
        mov nCount, 0
        xor ebx, ebx
        .WHILE ebx < dwFileCount    
            
            ; Get filename in each item in the results array 
            Invoke IShellItemArray_GetItemAt, pISIA, ebx, Addr pISI
            mov eax, pISI
            mov ebx, [eax]
            Invoke [ebx].IShellItemVtbl.GetDisplayName, pISI, SIGDN_FILESYSPATH, Addr pFileName
            
            Invoke lstrlenW, pFileName
            shl eax, 1 ; x2 for unicode chars to bytes
            add eax, 2 ; for null terminator
            add dwFileArraySize, eax
            
            Invoke CoTaskMemFree, pFileName
            
            mov eax, pISI
            mov ebx, [eax]
            Invoke [ebx].IShellItemVtbl.Release, pISI
            
            inc nCount
            mov ebx, nCount
        .ENDW
        add dwFileArraySize, 2 ; for double null
        
        ;----------------------------------------------------------------------
        ; Allocate memory for filename array
        ;----------------------------------------------------------------------
        mov eax, dwFileArraySize
        add eax, 8 ; just in case
        Invoke GlobalAlloc, GMEM_FIXED or GMEM_ZEROINIT, eax
        .IF eax == NULL
            jmp FileOpenDialogW_Exit
        .ENDIF
        mov pFileArray, eax
        
        ;----------------------------------------------------------------------
        ; Loop through results and copy filenames to filename array
        ;----------------------------------------------------------------------
        mov nPos, 0
        mov nCount, 0
        xor ebx, ebx
        .WHILE ebx < dwFileCount    
        
            ; Get filename in each item in the results array 
            Invoke IShellItemArray_GetItemAt, pISIA, ebx, Addr pISI
            mov eax, pISI
            mov ebx, [eax]
            Invoke [ebx].IShellItemVtbl.GetDisplayName, pISI, SIGDN_FILESYSPATH, Addr pFileName
            
            Invoke lstrlenW, pFileName
            shl eax, 1 ; x2 for unicode chars to bytes
            mov dwFileNameLength, eax
            
            mov ebx, pFileArray
            add ebx, nPos
            Invoke RtlMoveMemory, ebx, pFileName, dwFileNameLength
            
            mov eax, dwFileNameLength
            add eax, 2 ; for null terminator
            add nPos, eax
            
            Invoke CoTaskMemFree, pFileName
            
            mov eax, pISI
            mov ebx, [eax]
            Invoke [ebx].IShellItemVtbl.Release, pISI
            
            inc nCount
            mov ebx, nCount
        .ENDW
    
        IFDEF DEBUG32
        DbgDump pFileArray, dwFileArraySize
        ENDIF
    
    .ENDIF
    
    mov dwReturnResult, TRUE
    
FileOpenDialogW_Exit:

    ;--------------------------------------------------------------------------
    ; Free up any objects
    ;--------------------------------------------------------------------------
    .IF pISIF != 0
        mov eax, pISIF
        mov ebx, [eax]
        Invoke [ebx].IShellItemVtbl.Release, pISIF
    .ENDIF
    
    .IF pISIA != 0
        Invoke IShellItemArray_Release, pISIA
    .ENDIF
    
    .IF pIFOD != 0
        Invoke IFileOpenDialog_Release, pIFOD
    .ENDIF    

    ;--------------------------------------------------------------------------
    ; Return file count and pointer to file array
    ;--------------------------------------------------------------------------
    .IF lpdwFiles != 0
        mov ebx, lpdwFiles
        mov eax, dwFileCount
        mov [ebx], eax
    .ENDIF
    
    .IF lpFilesArray != 0
        mov ebx, lpFilesArray
        mov eax, pFileArray
        mov [ebx], eax
    .ENDIF
    
    Invoke CoUninitialize
    mov eax, dwReturnResult
    
    ret
FileOpenDialogW ENDP

ALIGN 8
;------------------------------------------------------------------------------
; FileSaveDialogA
;
; Creates a Save dialog box that lets the user specify the drive, directory, 
; and name of a file to save.
; 
; Parameters:
; 
; * lpszTitle - pointer to a string for the title of the save dialog.
;
; * lpszOkLabel - pointer to a string for the ok button in the save dialog.
;
; * lpszFileLabel - pointer to a string for the file label in the save dialog.
;
; * lpszFolder - pointer to a string for the initial folder to start in.
;
; * nMFS - number of COMDLG_FILTERSPEC structures pointed to by pMFS.
;
; * pMFS - array of COMDLG_FILTERSPEC structures for multi file spec.
;
; * hWndOwner - handle of the parent window that owns this save dialog.
;
; * bWarn - prompt before overwriting an existing file of the same name.
;
; * lpszFileName - pointer to a string for the initial filename to use.
;
; * lpdwSaveFile - pointer to a variable that stores a pointer to a string
;   containting the save filename to use.
;
; Returns:
; 
; TRUE if successful, or FALSE otherwise.
; 
; Notes:
;
; This is the Ansi version of FileSaveDialog. All strings passed as parameters 
; are expected to be Ansi strings, and the return results are stored in the
; lpdwSaveFile parameter as a pointer to an Ansi string.
;
; For the Wide/Unicode version see the FileSaveDialogW function.
;
; FileSaveDialog Implements the common file save dialog (CLSID_FileSaveDialog)
;
; See Also:
;
; FileOpenDialogA, FolderSelectDialogA
; 
;------------------------------------------------------------------------------
FileSaveDialogA PROC USES EBX lpszTitle:DWORD, lpszOkLabel:DWORD, lpszFileLabel:DWORD, lpszFolder:DWORD, nMFS:DWORD, pMFS:DWORD, hWndOwner:DWORD, bWarn:DWORD, lpszFileName:DWORD, lpdwSaveFile:DWORD
    LOCAL pIFSD:DWORD       ; pointer to IFileSaveDialog
    LOCAL pISI:DWORD        ; pointer to IShellItem
    LOCAL pISIF:DWORD       ; pointer to IShellItem for lpszFolder
    LOCAL pISISAI:DWORD     ; pointer to IShellItem SaveAsItem for lpszInitialFile
    LOCAL dwOptions:DWORD
    LOCAL nCount:DWORD
    LOCAL pFileName:DWORD
    LOCAL lpszAnsiFileName:DWORD
    LOCAL dwFileNameLength:DWORD
    LOCAL lpszWideTitle:DWORD
    LOCAL lpszWideOkLabel:DWORD
    LOCAL lpszWideFileLabel:DWORD
    LOCAL lpszWideFolder:DWORD
    LOCAL lpszWideFile:DWORD
    LOCAL pWideMFS:DWORD
    LOCAL pCurFileSpecSrc:DWORD
    LOCAL pCurFileSpecDest:DWORD
    LOCAL lpszString:DWORD
    LOCAL dwReturnResult:DWORD
    
    .IF lpdwSaveFile == 0
        mov eax, FALSE
        ret
    .ENDIF
    
    ;--------------------------------------------------------------------------
    ; Initialize
    ;--------------------------------------------------------------------------
    mov dwReturnResult, FALSE
    mov lpszWideTitle, 0
    mov lpszWideOkLabel, 0
    mov lpszWideFileLabel, 0
    mov lpszWideFolder, 0
    mov lpszWideFile, 0
    mov pWideMFS, 0
    mov pCurFileSpecSrc, 0
    mov pCurFileSpecDest, 0
    mov dwOptions, 0
    mov pIFSD, 0
    mov pISI, 0
    mov pISIF, 0
    mov pISISAI, 0
    mov lpszAnsiFileName, 0
    
    Invoke CoInitializeEx, NULL, COINIT_APARTMENTTHREADED
    
    Invoke IFileSaveDialogInit, Addr pIFSD
    .IF eax == FALSE
        IFDEF DEBUG32
        PrintText 'FileSaveDialogA IFileSaveDialogInit Failed'
        ENDIF
        jmp FileSaveDialogA_Exit
    .ENDIF
    
    ;--------------------------------------------------------------------------
    ; Set Title
    ;--------------------------------------------------------------------------
    .IF lpszTitle != NULL
        Invoke _FD_ConvertStringToWide, lpszTitle
        mov lpszWideTitle, eax
        
        Invoke IFileSaveDialog_SetTitle, pIFSD, lpszWideTitle
        .IF eax != S_OK
            IFDEF DEBUG32
            PrintText 'FileSaveDialogA SetTitle Failed'
            ENDIF
            jmp FileSaveDialogA_Exit
        .ENDIF
    .ENDIF
    
    ;--------------------------------------------------------------------------
    ; Set Ok Label
    ;--------------------------------------------------------------------------
    .IF lpszOkLabel != NULL
        Invoke _FD_ConvertStringToWide, lpszOkLabel
        mov lpszWideOkLabel, eax
    
        Invoke IFileSaveDialog_SetOkButtonLabel, pIFSD, lpszWideOkLabel
        .IF eax != S_OK
            IFDEF DEBUG32
            PrintText 'FileSaveDialogA SetOkButtonLabel Failed'
            ENDIF
            jmp FileSaveDialogA_Exit
        .ENDIF
    .ENDIF
    
    ;--------------------------------------------------------------------------
    ; Set File Label
    ;--------------------------------------------------------------------------
    .IF lpszFileLabel != NULL
        Invoke _FD_ConvertStringToWide, lpszFileLabel
        mov lpszWideFileLabel, eax
    
        Invoke IFileSaveDialog_SetFileNameLabel, pIFSD, lpszWideFileLabel
        .IF eax != S_OK
            IFDEF DEBUG32
            PrintText 'FileSaveDialogA SetFileNameLabel Failed'
            ENDIF
            jmp FileSaveDialogA_Exit
        .ENDIF
    .ENDIF
    
    ;--------------------------------------------------------------------------
    ; Set Inital Folder 
    ;--------------------------------------------------------------------------
    .IF lpszFolder != NULL
        Invoke _FD_ConvertStringToWide, lpszFolder
        mov lpszWideFolder, eax
    
        Invoke SHCreateItemFromParsingName, lpszWideFolder, NULL, Addr IID_IShellItem, Addr pISIF
        .IF eax != S_OK
            IFDEF DEBUG32
            PrintText 'FileSaveDialogA SHCreateItemFromParsingName lpszFolder Failed'
            ENDIF
            ;jmp FileSaveDialogA_Exit
        .ELSE
            Invoke IFileOpenDialog_SetFolder, pIFSD, pISIF
            .IF eax != S_OK
                IFDEF DEBUG32
                PrintText 'FileSaveDialogA SetFolder Failed'
                ENDIF
                ;jmp FileSaveDialogA_Exit
            .ENDIF
        .ENDIF
    .ENDIF
    
    ;--------------------------------------------------------------------------
    ; Set Inital Filename
    ;--------------------------------------------------------------------------
    .IF lpszFileName != NULL
        Invoke _FD_ConvertStringToWide, lpszFileName
        mov lpszWideFile, eax
        
        Invoke IFileSaveDialog_SetFileName, pIFSD, lpszWideFile
        .IF eax != S_OK
            IFDEF DEBUG32
            PrintText 'FileSaveDialogA SetFileName Failed'
            ENDIF
            ;jmp FileSaveDialogA_Exit
        .ENDIF
    .ENDIF
    
    ;--------------------------------------------------------------------------
    ; Set options
    ;--------------------------------------------------------------------------
    mov dwOptions, FOS_FORCEFILESYSTEM or FOS_FORCESHOWHIDDEN
    .IF bWarn == TRUE
        or dwOptions, FOS_OVERWRITEPROMPT
    .ENDIF
    Invoke IFileSaveDialog_SetOptions, pIFSD, dwOptions
    .IF eax != S_OK
        IFDEF DEBUG32
        PrintText 'FileSaveDialogA SetOptions Failed'
        ENDIF
        jmp FileSaveDialogA_Exit
    .ENDIF
    
    ;--------------------------------------------------------------------------
    ; Multi File Spec
    ;--------------------------------------------------------------------------
    .IF pMFS != NULL && nMFS != 0
    
        mov eax, nMFS
        mov ebx, SIZEOF COMDLG_FILTERSPEC
        mul ebx
        Invoke GlobalAlloc, GMEM_FIXED or GMEM_ZEROINIT, eax
        .IF eax == NULL
            jmp FileSaveDialogA_Exit
        .ENDIF
        mov pWideMFS, eax
        
        mov eax, pWideMFS
        mov pCurFileSpecDest, eax
        mov eax, pMFS
        mov pCurFileSpecSrc, eax
        
        mov nCount, 0
        mov eax, 0
        .WHILE eax < nMFS
            mov ebx, pCurFileSpecSrc
            mov eax, [ebx].COMDLG_FILTERSPEC.pszName
            mov lpszString, eax
            Invoke _FD_ConvertStringToWide, lpszString
           
            mov ebx, pCurFileSpecDest
            mov [ebx].COMDLG_FILTERSPEC.pszName, eax
            
            mov ebx, pCurFileSpecSrc
            mov eax, [ebx].COMDLG_FILTERSPEC.pszSpec
            mov lpszString, eax
            Invoke _FD_ConvertStringToWide, lpszString
            
            mov ebx, pCurFileSpecDest
            mov [ebx].COMDLG_FILTERSPEC.pszSpec, eax
            
            add pCurFileSpecDest, SIZEOF COMDLG_FILTERSPEC
            add pCurFileSpecSrc, SIZEOF COMDLG_FILTERSPEC
            inc nCount
            mov eax, nCount
        .ENDW
    
        Invoke IFileSaveDialog_SetFileTypes, pIFSD, nMFS, pWideMFS
        .IF eax != S_OK
            IFDEF DEBUG32
            PrintText 'FileSaveDialogA SetFileTypes Failed'
            ENDIF
            jmp FileSaveDialogA_Exit
        .ELSE
            Invoke IFileSaveDialog_SetFileTypeIndex, pIFSD, 1
        .ENDIF
    .ELSE
        Invoke IFileSaveDialog_SetFileTypes, pIFSD, 1, Addr DefaultMFSW
        .IF eax != S_OK
            IFDEF DEBUG32
            PrintText 'FileSaveDialogA SetFileTypes Failed'
            ENDIF
            jmp FileSaveDialogA_Exit
        .ELSE
            Invoke IFileSaveDialog_SetFileTypeIndex, pIFSD, 1
        .ENDIF
    .ENDIF
    
    ;--------------------------------------------------------------------------
    ; Show The Save Dialog 
    ;--------------------------------------------------------------------------
    Invoke IFileSaveDialog_Show, pIFSD, hWndOwner
    .IF eax == HRESULT_ERROR_CANCELLED
        IFDEF DEBUG32
        PrintText 'FileSaveDialogA Cancelled'
        ENDIF
        mov dwReturnResult, TRUE
        jmp FileSaveDialogA_Exit
    .ELSEIF eax != S_OK
        IFDEF DEBUG32
        PrintText 'FileSaveDialogA Show Failed'
        ENDIF
        jmp FileSaveDialogA_Exit
    .ENDIF
    IFDEF DEBUG32
    PrintText 'FileSaveDialogA Show Ok'
    ENDIF
    
    ;--------------------------------------------------------------------------
    ; Get the results: the save filename 
    ;--------------------------------------------------------------------------
    Invoke IFileSaveDialog_GetResult, pIFSD, Addr pISI
    .IF eax == S_OK
        mov eax, pISI
        mov ebx, [eax]
        Invoke [ebx].IShellItemVtbl.GetDisplayName, pISI, SIGDN_FILESYSPATH, Addr pFileName
        
        Invoke _FD_ConvertStringToAnsi, pFileName
        mov lpszAnsiFileName, eax
            
        Invoke CoTaskMemFree, pFileName
        
        mov eax, pISI
        mov ebx, [eax]
        Invoke [ebx].IShellItemVtbl.Release, pISI
    .ENDIF
    
    IFDEF DEBUG32
    Invoke lstrlenA, lpszAnsiFileName
    DbgDump lpszAnsiFileName, eax
    ENDIF
    
    mov dwReturnResult, TRUE
    
FileSaveDialogA_Exit:

    ;--------------------------------------------------------------------------
    ; Free up any objects
    ;--------------------------------------------------------------------------
    .IF pISIF != 0
        mov eax, pISIF
        mov ebx, [eax]
        Invoke [ebx].IShellItemVtbl.Release, pISIF
    .ENDIF
    
    .IF pIFSD != 0
        Invoke IFileSaveDialog_Release, pIFSD
    .ENDIF

    ;--------------------------------------------------------------------------
    ; Free up any wide strings we created
    ;--------------------------------------------------------------------------
    .IF lpszWideTitle != 0
        Invoke _FD_ConvertStringFree, lpszWideTitle
    .ENDIF
    .IF lpszWideOkLabel != 0
        Invoke _FD_ConvertStringFree, lpszWideOkLabel
    .ENDIF
    .IF lpszWideFileLabel != 0
        Invoke _FD_ConvertStringFree, lpszWideFileLabel
    .ENDIF
    .IF lpszWideFolder != 0
        Invoke _FD_ConvertStringFree, lpszWideFolder
    .ENDIF
    .IF lpszWideFile != 0
        Invoke _FD_ConvertStringFree, lpszWideFile
    .ENDIF

    ;--------------------------------------------------------------------------
    ; Free up wide conversion of MultiFileSpec strings
    ;--------------------------------------------------------------------------
    .IF pWideMFS != 0
        mov eax, pWideMFS
        mov pCurFileSpecSrc, eax
        mov nCount, 0
        mov eax, 0
        .WHILE eax < nMFS
        
            mov ebx, pCurFileSpecSrc
            mov eax, [ebx].COMDLG_FILTERSPEC.pszName
            .IF eax != 0
                mov lpszString, eax
                Invoke _FD_ConvertStringFree, lpszString
            .ENDIF
            
            mov ebx, pCurFileSpecSrc
            mov eax, [ebx].COMDLG_FILTERSPEC.pszSpec
            .IF eax != 0
                mov lpszString, eax
                Invoke _FD_ConvertStringFree, lpszString
            .ENDIF
            
            add pCurFileSpecSrc, SIZEOF COMDLG_FILTERSPEC
            inc nCount
            mov eax, nCount
        .ENDW
        Invoke GlobalFree, pWideMFS
    .ENDIF

    ;--------------------------------------------------------------------------
    ; Return pointer to save filename 
    ;--------------------------------------------------------------------------
    .IF lpdwSaveFile != 0
        mov ebx, lpdwSaveFile
        mov eax, lpszAnsiFileName
        mov [ebx], eax
    .ENDIF
    
    Invoke CoUninitialize
    mov eax, dwReturnResult
    
    ret
FileSaveDialogA ENDP

ALIGN 8
;------------------------------------------------------------------------------
; FileSaveDialogW
;
; Creates a Save dialog box that lets the user specify the drive, directory, 
; and name of a file to save.
; 
; Parameters:
; 
; * lpszTitle - pointer to a string for the title of the save dialog.
;
; * lpszOkLabel - pointer to a string for the ok button in the save dialog.
;
; * lpszFileLabel - pointer to a string for the file label in the save dialog.
;
; * lpszFolder - pointer to a string for the initial folder to start in.
;
; * nMFS - number of COMDLG_FILTERSPEC structures pointed to by pMFS.
;
; * pMFS - array of COMDLG_FILTERSPEC structures for multi file spec.
;
; * hWndOwner - handle of the parent window that owns this save dialog.
;
; * bWarn - prompt before overwriting an existing file of the same name.
;
; * lpszFileName - pointer to a string for the initial filename to use.
;
; * lpdwSaveFile - pointer to a variable that stores a pointer to a string
;   containting the save filename to use.
;
; Returns:
; 
; TRUE if successful, or FALSE otherwise.
; 
; Notes:
;
; This is the Wide/Unicode version of FileSaveDialog. All strings passed as 
; parameters are expected to be Wide/Unicode strings, and the return results 
; are stored in the lpdwSaveFile parameter as a pointer to a Wide string.
;
; For the Ansi version see the FileSaveDialogA function.
;
; FileSaveDialog Implements the common file save dialog (CLSID_FileSaveDialog)
;
; See Also:
;
; FileOpenDialogW, FolderSelectDialogW
; 
;------------------------------------------------------------------------------
FileSaveDialogW PROC USES EBX lpszTitle:DWORD, lpszOkLabel:DWORD, lpszFileLabel:DWORD, lpszFolder:DWORD, nMFS:DWORD, pMFS:DWORD, hWndOwner:DWORD, bWarn:DWORD, lpszFileName:DWORD, lpdwSaveFile:DWORD
    LOCAL pIFSD:DWORD       ; pointer to IFileSaveDialog
    LOCAL pISI:DWORD        ; pointer to IShellItem
    LOCAL pISIF:DWORD       ; pointer to IShellItem for lpszFolder
    LOCAL pISISAI:DWORD     ; pointer to IShellItem SaveAsItem for lpszInitialFile
    LOCAL dwOptions:DWORD
    LOCAL pFileName:DWORD
    LOCAL pWideFileName:DWORD
    LOCAL dwWideFileNameLength:DWORD
    LOCAL dwReturnResult:DWORD
    
    .IF lpdwSaveFile == 0
        mov eax, FALSE
        ret
    .ENDIF
    
    ;--------------------------------------------------------------------------
    ; Initialize
    ;--------------------------------------------------------------------------
    mov dwReturnResult, FALSE
    mov dwOptions, 0
    mov pIFSD, 0
    mov pISI, 0
    mov pISIF, 0
    mov pISISAI, 0
    mov pWideFileName, 0
    
    Invoke CoInitializeEx, NULL, COINIT_APARTMENTTHREADED
    
    Invoke IFileSaveDialogInit, Addr pIFSD
    .IF eax == FALSE
        IFDEF DEBUG32
        PrintText 'FileSaveDialogW IFileSaveDialogInit Failed'
        ENDIF
        jmp FileSaveDialogW_Exit
    .ENDIF
    
    ;--------------------------------------------------------------------------
    ; Set Title
    ;--------------------------------------------------------------------------
    .IF lpszTitle != NULL
        Invoke IFileSaveDialog_SetTitle, pIFSD, lpszTitle
        .IF eax != S_OK
            IFDEF DEBUG32
            PrintText 'FileSaveDialogW SetTitle Failed'
            ENDIF
            jmp FileSaveDialogW_Exit
        .ENDIF
    .ENDIF
    
    ;--------------------------------------------------------------------------
    ; Set Ok Label
    ;--------------------------------------------------------------------------
    .IF lpszOkLabel != NULL
        Invoke IFileSaveDialog_SetOkButtonLabel, pIFSD, lpszOkLabel
        .IF eax != S_OK
            IFDEF DEBUG32
            PrintText 'FileSaveDialogW SetOkButtonLabel Failed'
            ENDIF
            jmp FileSaveDialogW_Exit
        .ENDIF
    .ENDIF
    
    ;--------------------------------------------------------------------------
    ; Set File Label
    ;--------------------------------------------------------------------------
    .IF lpszFileLabel != NULL
        Invoke IFileSaveDialog_SetFileNameLabel, pIFSD, lpszFileLabel
        .IF eax != S_OK
            IFDEF DEBUG32
            PrintText 'FileSaveDialogW SetFileNameLabel Failed'
            ENDIF
            jmp FileSaveDialogW_Exit
        .ENDIF
    .ENDIF
    
    ;--------------------------------------------------------------------------
    ; Set Inital Folder 
    ;--------------------------------------------------------------------------
    .IF lpszFolder != NULL
        Invoke SHCreateItemFromParsingName, lpszFolder, NULL, Addr IID_IShellItem, Addr pISIF
        .IF eax != S_OK
            IFDEF DEBUG32
            PrintText 'FileSaveDialogW SHCreateItemFromParsingName lpszFolder Failed'
            ENDIF
            ;jmp FileSaveDialogW_Exit
        .ELSE
            Invoke IFileOpenDialog_SetFolder, pIFSD, pISIF
            .IF eax != S_OK
                IFDEF DEBUG32
                PrintText 'FileSaveDialogW SetFolder Failed'
                ENDIF
                ;jmp FileSaveDialogW_Exit
            .ENDIF
        .ENDIF
    .ENDIF
    
    ;--------------------------------------------------------------------------
    ; Set Inital Filename
    ;--------------------------------------------------------------------------
    .IF lpszFileName != NULL
        Invoke IFileSaveDialog_SetFileName, pIFSD, lpszFileName
        .IF eax != S_OK
            IFDEF DEBUG32
            PrintText 'FileSaveDialogW SetFileName Failed'
            ENDIF
            ;jmp FileSaveDialogW_Exit
        .ENDIF
    .ENDIF
    
    ;--------------------------------------------------------------------------
    ; Set options
    ;--------------------------------------------------------------------------
    mov dwOptions, FOS_FORCEFILESYSTEM or FOS_FORCESHOWHIDDEN
    .IF bWarn == TRUE
        or dwOptions, FOS_OVERWRITEPROMPT
    .ENDIF
    Invoke IFileSaveDialog_SetOptions, pIFSD, dwOptions
    .IF eax != S_OK
        IFDEF DEBUG32
        PrintText 'FileSaveDialogW SetOptions Failed'
        ENDIF
        jmp FileSaveDialogW_Exit
    .ENDIF
    
    ;--------------------------------------------------------------------------
    ; Multi File Spec
    ;--------------------------------------------------------------------------
    .IF pMFS != NULL && nMFS != 0
        Invoke IFileSaveDialog_SetFileTypes, pIFSD, nMFS, pMFS
        .IF eax != S_OK
            IFDEF DEBUG32
            PrintText 'FileSaveDialogW SetFileTypes Failed'
            ENDIF
            jmp FileSaveDialogW_Exit
        .ELSE
            Invoke IFileSaveDialog_SetFileTypeIndex, pIFSD, 1
        .ENDIF
    .ELSE
        Invoke IFileSaveDialog_SetFileTypes, pIFSD, 1, Addr DefaultMFSW
        .IF eax != S_OK
            IFDEF DEBUG32
            PrintText 'FileSaveDialogW SetFileTypes Failed'
            ENDIF
            jmp FileSaveDialogW_Exit
        .ELSE
            Invoke IFileSaveDialog_SetFileTypeIndex, pIFSD, 1
        .ENDIF
    .ENDIF
    
    ;--------------------------------------------------------------------------
    ; Show The Save Dialog 
    ;--------------------------------------------------------------------------
    Invoke IFileSaveDialog_Show, pIFSD, hWndOwner
    .IF eax == HRESULT_ERROR_CANCELLED
        IFDEF DEBUG32
        PrintText 'FileSaveDialogW Cancelled'
        ENDIF
        mov dwReturnResult, TRUE
        jmp FileSaveDialogW_Exit
    .ELSEIF eax != S_OK
        IFDEF DEBUG32
        PrintText 'FileSaveDialogW Show Failed'
        ENDIF
        jmp FileSaveDialogW_Exit
    .ENDIF
    IFDEF DEBUG32
    PrintText 'FileSaveDialogW Show Ok'
    ENDIF
    
    ;--------------------------------------------------------------------------
    ; Get the results: the save filename 
    ;--------------------------------------------------------------------------
    Invoke IFileSaveDialog_GetResult, pIFSD, Addr pISI
    .IF eax == S_OK
        mov eax, pISI
        mov ebx, [eax]
        Invoke [ebx].IShellItemVtbl.GetDisplayName, pISI, SIGDN_FILESYSPATH, Addr pFileName
        
        ;----------------------------------------------------------------------
        ; Allocate memory for filename and copy it over to our buffer
        ;----------------------------------------------------------------------
        
        Invoke lstrlenW, pFileName
        shl eax, 1 ; x2 for unicode chars to bytes
        mov dwWideFileNameLength, eax
        add eax, 8 ; just in case
        Invoke GlobalAlloc, GMEM_FIXED or GMEM_ZEROINIT, eax
        .IF eax == NULL
            jmp FileSaveDialogW_Exit
        .ENDIF
        mov pWideFileName, eax
        
        Invoke RtlMoveMemory, pWideFileName, pFileName, dwWideFileNameLength
        
        Invoke CoTaskMemFree, pFileName
        
        mov eax, pISI
        mov ebx, [eax]
        Invoke [ebx].IShellItemVtbl.Release, pISI
    .ENDIF
    
    IFDEF DEBUG32
    Invoke lstrlenW, pWideFileName
    shl eax, 1 ; x2 for unicode to bytes
    DbgDump pWideFileName, eax
    ENDIF
    
    mov dwReturnResult, TRUE
    
FileSaveDialogW_Exit:

    ;--------------------------------------------------------------------------
    ; Free up any objects
    ;--------------------------------------------------------------------------
    .IF pISISAI != 0
        mov eax, pISISAI
        mov ebx, [eax]
        Invoke [ebx].IShellItemVtbl.Release, pISISAI
    .ENDIF
    
    .IF pISIF != 0
        mov eax, pISIF
        mov ebx, [eax]
        Invoke [ebx].IShellItemVtbl.Release, pISIF
    .ENDIF
    
    .IF pIFSD != 0
        Invoke IFileSaveDialog_Release, pIFSD
    .ENDIF    

    ;--------------------------------------------------------------------------
    ; Return pointer to save filename 
    ;--------------------------------------------------------------------------
    .IF lpdwSaveFile != 0
        mov ebx, lpdwSaveFile
        mov eax, pWideFileName
        mov [ebx], eax
    .ENDIF
    
    Invoke CoUninitialize
    mov eax, dwReturnResult
    
    ret
FileSaveDialogW ENDP

ALIGN 8
;------------------------------------------------------------------------------
; FolderSelectDialogA
;
; Displays a dialog box that enables the user to select a folder.
; 
; Parameters:
; 
; * lpszTitle - pointer to a string for the title of the select folder dialog.
;
; * lpszOkLabel - pointer to a string for the ok button in the dialog.
;
; * lpszFileLabel - pointer to a string for the file label in the dialog.
;
; * lpszFolder - pointer to a string for the initial folder to start in.
;
; * hWndOwner - handle of the parent window that owns this dialog.
;
; * lpdwFolder - pointer to a variable thats stores a pointer to a string 
;   containing the folder that was selected by the user.
;
; Returns:
; 
; TRUE if successful, or FALSE otherwise.
; 
; Notes:
;
; This is the Ansi version of FolderSelectDialog. All strings passed as 
; parameters are expected to be Ansi strings, and the return results are stored 
; in the lpdwFolder parameter as a pointer to an Ansi string.
;
; For the Wide/Unicode version see the FolderSelectDialogW function.
;
; FolderSelectDialog Implements the IFileDialog of CLSID_FileOpenDialog
;
; See Also:
;
; FileOpenDialogA, FileSaveDialogA
; 
;------------------------------------------------------------------------------
FolderSelectDialogA PROC USES EBX lpszTitle:DWORD, lpszOkLabel:DWORD, lpszFileLabel:DWORD, lpszFolder:DWORD, hWndOwner:DWORD, lpdwFolder:DWORD
    LOCAL pIFD:DWORD        ; pointer to IFileDialog
    LOCAL pISI:DWORD        ; pointer to IShellItem
    LOCAL pISIF:DWORD       ; pointer to IShellItem for lpszFolder
    LOCAL dwOptions:DWORD
    LOCAL pFolder:DWORD
    LOCAL lpszAnsiFolder:DWORD
    LOCAL lpszWideTitle:DWORD
    LOCAL lpszWideOkLabel:DWORD
    LOCAL lpszWideFileLabel:DWORD
    LOCAL lpszWideFolder:DWORD
    LOCAL dwReturnResult:DWORD
    
    .IF lpdwFolder == 0
        mov eax, FALSE
        ret
    .ENDIF
    
    ;--------------------------------------------------------------------------
    ; Initialize
    ;--------------------------------------------------------------------------
    mov dwReturnResult, FALSE
    mov pFolder, 0
    mov lpszWideTitle, 0
    mov lpszWideOkLabel, 0
    mov lpszWideFileLabel, 0
    mov lpszWideFolder, 0
    mov lpszAnsiFolder, 0
    mov dwOptions, 0
    mov pIFD, 0
    mov pISI, 0
    mov pISIF, 0
    
    Invoke CoInitializeEx, NULL, COINIT_APARTMENTTHREADED
    
    Invoke IFileDialogInit, Addr pIFD
    .IF eax == FALSE
        IFDEF DEBUG32
        PrintText 'FolderSelectDialogA IFileDialogInit Failed'
        ENDIF
        jmp FolderSelectDialogA_Exit
    .ENDIF
    
    ;--------------------------------------------------------------------------
    ; Set Title
    ;--------------------------------------------------------------------------
    .IF lpszTitle != NULL
        Invoke _FD_ConvertStringToWide, lpszTitle
        mov lpszWideTitle, eax
    
        Invoke IFileDialog_SetTitle, pIFD, lpszWideTitle
        .IF eax != S_OK
            IFDEF DEBUG32
            PrintText 'FolderSelectDialogA SetTitle Failed'
            ENDIF
            jmp FolderSelectDialogA_Exit
        .ENDIF
    .ENDIF
    
    ;--------------------------------------------------------------------------
    ; Set Ok Label
    ;--------------------------------------------------------------------------
    .IF lpszOkLabel != NULL
        Invoke _FD_ConvertStringToWide, lpszOkLabel
        mov lpszWideOkLabel, eax
    
        Invoke IFileDialog_SetOkButtonLabel, pIFD, lpszWideOkLabel
        .IF eax != S_OK
            IFDEF DEBUG32
            PrintText 'FolderSelectDialogA SetOkButtonLabel Failed'
            ENDIF
            jmp FolderSelectDialogA_Exit
        .ENDIF
    .ENDIF
    
    ;--------------------------------------------------------------------------
    ; Set File Label
    ;--------------------------------------------------------------------------
    .IF lpszFileLabel != NULL
        Invoke _FD_ConvertStringToWide, lpszFileLabel
        mov lpszWideFileLabel, eax
    
        Invoke IFileDialog_SetFileNameLabel, pIFD, lpszWideFileLabel
        .IF eax != S_OK
            IFDEF DEBUG32
            PrintText 'FolderSelectDialogA SetFileNameLabel Failed'
            ENDIF
            jmp FolderSelectDialogA_Exit
        .ENDIF
    .ENDIF
    
    ;--------------------------------------------------------------------------
    ; Set Inital Folder 
    ;--------------------------------------------------------------------------
    .IF lpszFolder != NULL
        Invoke _FD_ConvertStringToWide, lpszFolder
        mov lpszWideFolder, eax
    
        Invoke SHCreateItemFromParsingName, lpszWideFolder, NULL, Addr IID_IShellItem, Addr pISIF
        .IF eax != S_OK
            IFDEF DEBUG32
            PrintText 'FolderSelectDialogA SHCreateItemFromParsingName lpszFolder Failed'
            ENDIF
            ;jmp FolderSelectDialogA_Exit
        .ELSE
            Invoke IFileDialog_SetFolder, pIFD, pISIF
            .IF eax != S_OK
                IFDEF DEBUG32
                PrintText 'FolderSelectDialogA SetFolder Failed'
                ENDIF
                ;jmp FolderSelectDialogA_Exit
            .ENDIF
        .ENDIF
    .ENDIF

    ;--------------------------------------------------------------------------
    ; Set options: 
    ;--------------------------------------------------------------------------
    mov dwOptions, FOS_FORCEFILESYSTEM or FOS_FORCESHOWHIDDEN or FOS_PICKFOLDERS
    Invoke IFileDialog_SetOptions, pIFD, dwOptions
    .IF eax != S_OK
        IFDEF DEBUG32
        PrintText 'FolderSelectDialogA SetOptions Failed'
        ENDIF
        jmp FolderSelectDialogA_Exit
    .ENDIF
    
    ;--------------------------------------------------------------------------
    ; Show The Open Dialog 
    ;--------------------------------------------------------------------------
    Invoke IFileDialog_Show, pIFD, hWndOwner
    .IF eax == HRESULT_ERROR_CANCELLED
        IFDEF DEBUG32
        PrintText 'FolderSelectDialogA Cancelled'
        ENDIF
        mov dwReturnResult, TRUE
        jmp FolderSelectDialogA_Exit
    .ELSEIF eax != S_OK
        IFDEF DEBUG32
        PrintText 'FolderSelectDialogA Show Failed'
        ENDIF
        jmp FolderSelectDialogA_Exit
    .ENDIF
    IFDEF DEBUG32
    PrintText 'FolderSelectDialogA Show Ok'
    ENDIF
    
    ;--------------------------------------------------------------------------
    ; Get the folder selected
    ;--------------------------------------------------------------------------
    Invoke IFileDialog_GetResult, pIFD, Addr pISI
    mov eax, pISI
    mov ebx, [eax]
    Invoke [ebx].IShellItemVtbl.GetDisplayName, pISI, SIGDN_FILESYSPATH, Addr pFolder
    
    Invoke _FD_ConvertStringToAnsi, pFolder
    mov lpszAnsiFolder, eax
    
    Invoke CoTaskMemFree, pFolder
    
    mov eax, pISI
    mov ebx, [eax]
    Invoke [ebx].IShellItemVtbl.Release, pISI
    
    IFDEF DEBUG32
    Invoke lstrlenA, lpszAnsiFolder
    DbgDump lpszAnsiFolder, eax
    ENDIF
    
    mov dwReturnResult, TRUE
    
FolderSelectDialogA_Exit:

    ;--------------------------------------------------------------------------
    ; Free up any objects
    ;--------------------------------------------------------------------------
    .IF pISIF != 0
        mov eax, pISIF
        mov ebx, [eax]
        Invoke [ebx].IShellItemVtbl.Release, pISIF
    .ENDIF
    
    .IF pIFD != 0
        Invoke IFileOpenDialog_Release, pIFD
    .ENDIF    

    ;--------------------------------------------------------------------------
    ; Return pointer to the folder selected
    ;--------------------------------------------------------------------------
    .IF lpdwFolder != 0
        mov ebx, lpdwFolder
        mov eax, lpszAnsiFolder
        mov [ebx], eax
    .ENDIF
    
    Invoke CoUninitialize
    mov eax, dwReturnResult
    ret
FolderSelectDialogA ENDP

ALIGN 8
;------------------------------------------------------------------------------
; FolderSelectDialogW
;
; Displays a dialog box that enables the user to select a folder.
; 
; Parameters:
; 
; * lpszTitle - pointer to a string for the title of the select folder dialog.
;
; * lpszOkLabel - pointer to a string for the ok button in the dialog.
;
; * lpszFileLabel - pointer to a string for the file label in the dialog.
;
; * lpszFolder - pointer to a string for the initial folder to start in.
;
; * hWndOwner - handle of the parent window that owns this dialog.
;
; * lpdwFolder - pointer to a variable thats stores a pointer to a string 
;   containing the folder that was selected by the user.
;
; Returns:
; 
; TRUE if successful, or FALSE otherwise.
; 
; Notes:
;
; This is the Wide/Unicode version of FolderSelectDialog. All strings passed as 
; parameters are expected to be Wide/Unicode strings, and the return results 
; are stored in the lpdwFolder parameter as a pointer to a Wide/Unicode string.
;
; For the Ansi version see the FolderSelectDialogA function.
;
; FolderSelectDialog Implements the IFileDialog of CLSID_FileOpenDialog
;
; See Also:
;
; FileOpenDialogW, FileSaveDialogW
; 
;------------------------------------------------------------------------------
FolderSelectDialogW PROC USES EBX lpszTitle:DWORD, lpszOkLabel:DWORD, lpszFileLabel:DWORD, lpszFolder:DWORD, hWndOwner:DWORD, lpdwFolder:DWORD
    LOCAL pIFD:DWORD        ; pointer to IFileDialog
    LOCAL pISI:DWORD        ; pointer to IShellItem
    LOCAL pISIF:DWORD       ; pointer to IShellItem for lpszFolder
    LOCAL dwOptions:DWORD
    LOCAL pFolder:DWORD
    LOCAL pWideFolder:DWORD
    LOCAL dwWideFolderLength:DWORD
    LOCAL dwReturnResult:DWORD
    
    .IF lpdwFolder == 0
        mov eax, FALSE
        ret
    .ENDIF
    
    ;--------------------------------------------------------------------------
    ; Initialize
    ;--------------------------------------------------------------------------
    mov dwReturnResult, FALSE
    mov dwOptions, 0
    mov pFolder, 0
    mov pWideFolder, 0
    mov pIFD, 0
    mov pISI, 0
    mov pISIF, 0
    
    Invoke CoInitializeEx, NULL, COINIT_APARTMENTTHREADED
    
    Invoke IFileDialogInit, Addr pIFD
    .IF eax == FALSE
        IFDEF DEBUG32
        PrintText 'FolderSelectDialogW IFileDialogInit Failed'
        ENDIF
        jmp FolderSelectDialogW_Exit
    .ENDIF
    
    ;--------------------------------------------------------------------------
    ; Set Title
    ;--------------------------------------------------------------------------
    .IF lpszTitle != NULL
        Invoke IFileDialog_SetTitle, pIFD, lpszTitle
        .IF eax != S_OK
            IFDEF DEBUG32
            PrintText 'FolderSelectDialogW SetTitle Failed'
            ENDIF
            jmp FolderSelectDialogW_Exit
        .ENDIF
    .ENDIF
    
    ;--------------------------------------------------------------------------
    ; Set Ok Label
    ;--------------------------------------------------------------------------
    .IF lpszOkLabel != NULL
        Invoke IFileDialog_SetOkButtonLabel, pIFD, lpszOkLabel
        .IF eax != S_OK
            IFDEF DEBUG32
            PrintText 'FolderSelectDialogW SetOkButtonLabel Failed'
            ENDIF
            jmp FolderSelectDialogW_Exit
        .ENDIF
    .ENDIF
    
    ;--------------------------------------------------------------------------
    ; Set File Label
    ;--------------------------------------------------------------------------
    .IF lpszFileLabel != NULL
        Invoke IFileDialog_SetFileNameLabel, pIFD, lpszFileLabel
        .IF eax != S_OK
            IFDEF DEBUG32
            PrintText 'FolderSelectDialogW SetFileNameLabel Failed'
            ENDIF
            jmp FolderSelectDialogW_Exit
        .ENDIF
    .ENDIF
    
    ;--------------------------------------------------------------------------
    ; Set Inital Folder 
    ;--------------------------------------------------------------------------
    .IF lpszFolder != NULL
        Invoke SHCreateItemFromParsingName, lpszFolder, NULL, Addr IID_IShellItem, Addr pISIF
        .IF eax != S_OK
            IFDEF DEBUG32
            PrintText 'FolderSelectDialogW SHCreateItemFromParsingName lpszFolder Failed'
            ENDIF
            ;jmp FolderSelectDialogW_Exit
        .ELSE
            Invoke IFileDialog_SetFolder, pIFD, pISIF
            .IF eax != S_OK
                IFDEF DEBUG32
                PrintText 'FolderSelectDialogW SetFolder Failed'
                ENDIF
                ;jmp FolderSelectDialogW_Exit
            .ENDIF
        .ENDIF
    .ENDIF

    ;--------------------------------------------------------------------------
    ; Set options: 
    ;--------------------------------------------------------------------------
    mov dwOptions, FOS_FORCEFILESYSTEM or FOS_FORCESHOWHIDDEN or FOS_PICKFOLDERS
    Invoke IFileDialog_SetOptions, pIFD, dwOptions
    .IF eax != S_OK
        IFDEF DEBUG32
        PrintText 'FolderSelectDialogW SetOptions Failed'
        ENDIF
        jmp FolderSelectDialogW_Exit
    .ENDIF
    
    ;--------------------------------------------------------------------------
    ; Show The Open Dialog 
    ;--------------------------------------------------------------------------
    Invoke IFileDialog_Show, pIFD, hWndOwner
    .IF eax == HRESULT_ERROR_CANCELLED
        IFDEF DEBUG32
        PrintText 'FolderSelectDialogW Cancelled'
        ENDIF
        mov dwReturnResult, TRUE
        jmp FolderSelectDialogW_Exit
    .ELSEIF eax != S_OK
        IFDEF DEBUG32
        PrintText 'FolderSelectDialogW Show Failed'
        ENDIF
        jmp FolderSelectDialogW_Exit
    .ENDIF
    IFDEF DEBUG32
    PrintText 'FolderSelectDialogW Show Ok'
    ENDIF
    
    ;--------------------------------------------------------------------------
    ; Get the folder selected
    ;--------------------------------------------------------------------------
    Invoke IFileDialog_GetResult, pIFD, Addr pISI
    mov eax, pISI
    mov ebx, [eax]
    Invoke [ebx].IShellItemVtbl.GetDisplayName, pISI, SIGDN_FILESYSPATH, Addr pFolder
    
    ;----------------------------------------------------------------------
    ; Allocate memory for folder and copy it over to our buffer
    ;----------------------------------------------------------------------
    Invoke lstrlenW, pFolder
    shl eax, 1 ; x2 for unicode chars to bytes
    mov dwWideFolderLength, eax
    add eax, 8 ; just in case
    Invoke GlobalAlloc, GMEM_FIXED or GMEM_ZEROINIT, eax
    .IF eax == NULL
        jmp FolderSelectDialogW_Exit
    .ENDIF
    mov pWideFolder, eax
    
    Invoke RtlMoveMemory, pWideFolder, pFolder, dwWideFolderLength
    
    Invoke CoTaskMemFree, pFolder
    
    mov eax, pISI
    mov ebx, [eax]
    Invoke [ebx].IShellItemVtbl.Release, pISI
    
    IFDEF DEBUG32
    Invoke lstrlenW, pWideFolder
    shl eax, 1 ; x2 for unicode to bytes
    DbgDump pWideFolder, eax
    ENDIF
    
    mov dwReturnResult, TRUE
    
FolderSelectDialogW_Exit:

    ;--------------------------------------------------------------------------
    ; Free up any objects
    ;--------------------------------------------------------------------------
    .IF pISIF != 0
        mov eax, pISIF
        mov ebx, [eax]
        Invoke [ebx].IShellItemVtbl.Release, pISIF
    .ENDIF
    
    .IF pIFD != 0
        Invoke IFileOpenDialog_Release, pIFD
    .ENDIF    

    ;--------------------------------------------------------------------------
    ; Return pointer to the folder selected
    ;--------------------------------------------------------------------------
    .IF lpdwFolder != 0
        mov ebx, lpdwFolder
        mov eax, pWideFolder
        mov [ebx], eax
    .ENDIF
    
    Invoke CoUninitialize
    mov eax, dwReturnResult

    ret
FolderSelectDialogW ENDP

ALIGN 8
;------------------------------------------------------------------------------
; IFileOpenDialogInit
;
; Initialize CLSID_FileOpenDialog and the IFileOpenDialog functions by copying 
; the vtable pointers of the IFileOpenDialog object functions to global 
; variables that are prototyped to the appropriate function.
;
; This allows for using Invoke in the other functions. Alternatively the calls
; to the functions can be made by referencing them via the iFileOpenDialog
; structure.
;
; Parameters:
; 
; * ppIFileOpenDialog - pointer to a variable to store the IFileOpenDialog pointer.
; 
; Returns:
; 
; TRUE if successful, or FALSE otherwise.
; 
; Notes:
;
; This is a convenience function, and the object functions can be made by ref
; to the structure directly instead.
;
; See Also:
;
; IFileSaveDialogInit, IFileDialogInit, IShellItemInit, IShellItemArrayInit
; 
;------------------------------------------------------------------------------
IFileOpenDialogInit PROC USES EBX ppIFileOpenDialog:DWORD
    LOCAL pfd:DWORD
    
    .IF ppIFileOpenDialog == NULL
        jmp IFileOpenDialogInit_Error
    .ENDIF
    
    mov pfd, 0
    
    Invoke CoCreateInstance, Addr CLSID_FileOpenDialog, 0, CLSCTX_INPROC_SERVER, Addr IID_IFileOpenDialog, Addr pfd
    .IF eax != S_OK
        IFDEF DEBUG32
        PrintText 'IFileOpenDialogInit CoCreateInstance Failed'
        ENDIF
        jmp IFileOpenDialogInit_Error
    .ENDIF
    IFDEF DEBUG32
    PrintText 'IFileOpenDialogInit CoCreateInstance Ok'
    ENDIF
    
    .IF pfd == 0
        IFDEF DEBUG32
        PrintText 'IFileOpenDialogInit pfd == 0'
        ENDIF
        jmp IFileOpenDialogInit_Error
    .ENDIF
    IFDEF DEBUG32
    PrintText 'IFileOpenDialogInit pfd ok'
    ENDIF
    
    ; Get functions:
    mov eax, pfd
    mov ebx, [eax]
    .IF ebx == 0
        IFDEF DEBUG32
        PrintText 'IFileOpenDialogInit pfd::ebx == 0'
        ENDIF
        jmp IFileOpenDialogInit_Error
    .ENDIF
    
    mov eax, [ebx].IFileOpenDialogVtbl.QueryInterface
    mov IFileOpenDialog_QueryInterface, eax
    mov eax, [ebx].IFileOpenDialogVtbl.AddRef
    mov IFileOpenDialog_AddRef, eax
    mov eax, [ebx].IFileOpenDialogVtbl.Release
    mov IFileOpenDialog_Release, eax
    mov eax, [ebx].IFileOpenDialogVtbl.Show
    mov IFileOpenDialog_Show, eax
    mov eax, [ebx].IFileOpenDialogVtbl.SetFileTypes
    mov IFileOpenDialog_SetFileTypes, eax
    mov eax, [ebx].IFileOpenDialogVtbl.SetFileTypeIndex
    mov IFileOpenDialog_SetFileTypeIndex, eax
    mov eax, [ebx].IFileOpenDialogVtbl.GetFileTypeIndex
    mov IFileOpenDialog_GetFileTypeIndex, eax
    mov eax, [ebx].IFileOpenDialogVtbl.Advise
    mov IFileOpenDialog_Advise, eax
    mov eax, [ebx].IFileOpenDialogVtbl.Unadvise
    mov IFileOpenDialog_Unadvise, eax
    mov eax, [ebx].IFileOpenDialogVtbl.SetOptions
    mov IFileOpenDialog_SetOptions, eax
    mov eax, [ebx].IFileOpenDialogVtbl.GetOptions
    mov IFileOpenDialog_GetOptions, eax
    mov eax, [ebx].IFileOpenDialogVtbl.SetDefaultFolder
    mov IFileOpenDialog_SetDefaultFolder, eax
    mov eax, [ebx].IFileOpenDialogVtbl.SetFolder
    mov IFileOpenDialog_SetFolder, eax
    mov eax, [ebx].IFileOpenDialogVtbl.GetFolder
    mov IFileOpenDialog_GetFolder, eax
    mov eax, [ebx].IFileOpenDialogVtbl.GetCurrentSelection
    mov IFileOpenDialog_GetCurrentSelection, eax
    mov eax, [ebx].IFileOpenDialogVtbl.SetFileName
    mov IFileOpenDialog_SetFileName, eax
    mov eax, [ebx].IFileOpenDialogVtbl.GetFileName
    mov IFileOpenDialog_GetFileName, eax
    mov eax, [ebx].IFileOpenDialogVtbl.SetTitle
    mov IFileOpenDialog_SetTitle, eax
    mov eax, [ebx].IFileOpenDialogVtbl.SetOkButtonLabel
    mov IFileOpenDialog_SetOkButtonLabel, eax
    mov eax, [ebx].IFileOpenDialogVtbl.SetFileNameLabel
    mov IFileOpenDialog_SetFileNameLabel, eax
    mov eax, [ebx].IFileOpenDialogVtbl.GetResult
    mov IFileOpenDialog_GetResult, eax
    mov eax, [ebx].IFileOpenDialogVtbl.AddPlace
    mov IFileOpenDialog_AddPlace, eax
    mov eax, [ebx].IFileOpenDialogVtbl.SetDefaultExtension
    mov IFileOpenDialog_SetDefaultExtension, eax
    mov eax, [ebx].IFileOpenDialogVtbl.Close
    mov IFileOpenDialog_Close, eax
    mov eax, [ebx].IFileOpenDialogVtbl.SetClientGuid
    mov IFileOpenDialog_SetClientGuid, eax
    mov eax, [ebx].IFileOpenDialogVtbl.ClearClientData
    mov IFileOpenDialog_ClearClientData, eax
    mov eax, [ebx].IFileOpenDialogVtbl.SetFilter
    mov IFileOpenDialog_SetFilter, eax
    mov eax, [ebx].IFileOpenDialogVtbl.GetResults
    mov IFileOpenDialog_GetResults, eax
    mov eax, [ebx].IFileOpenDialogVtbl.GetSelectedItems
    mov IFileOpenDialog_GetSelectedItems, eax

    jmp IFileOpenDialogInit_Exit

IFileOpenDialogInit_Error:
    
    .IF ppIFileOpenDialog != 0
        mov ebx, ppIFileOpenDialog
        mov eax, 0
        mov [ebx], eax
    .ENDIF
    mov eax, FALSE
    ret
    
IFileOpenDialogInit_Exit:
    
    .IF ppIFileOpenDialog != 0
        mov ebx, ppIFileOpenDialog
        mov eax, pfd
        mov [ebx], eax
    .ENDIF
    mov eax, TRUE
    ret
IFileOpenDialogInit ENDP

ALIGN 8
;------------------------------------------------------------------------------
; IFileSaveDialogInit
;
; Initialize CLSID_FileSaveDialog and the IFileSaveDialog functions by copying 
; the vtable pointers of the IFileSaveDialog object functions to global 
; variables that are prototyped to the appropriate function.
;
; This allows for using Invoke in the other functions. Alternatively the calls
; to the functions can be made by referencing them via the iFileSaveDialog
; structure.
;
; Parameters:
; 
; * ppIFileSaveDialog - pointer to a variable to store the IFileSaveDialog pointer.
; 
; Returns:
; 
; TRUE if successful, or FALSE otherwise.
; 
; Notes:
;
; This is a convenience function, and the object functions can be made by ref
; to the structure directly instead.
;
; See Also:
;
; IFileOpenDialogInit, IFileDialogInit, IShellItemInit, IShellItemArrayInit
; 
;------------------------------------------------------------------------------
IFileSaveDialogInit PROC USES EBX ppIFileSaveDialog:DWORD
    LOCAL pfd:DWORD
    
    .IF ppIFileSaveDialog == NULL
        jmp IFileSaveDialogInit_Error
    .ENDIF
    
    mov pfd, 0
    
    Invoke CoCreateInstance, Addr CLSID_FileSaveDialog, 0, CLSCTX_INPROC_SERVER, Addr IID_IFileSaveDialog, Addr pfd
    .IF eax != S_OK
        IFDEF DEBUG32
        PrintText 'IFileSaveDialogInit CoCreateInstance Failed'
        ENDIF
        jmp IFileSaveDialogInit_Error
    .ENDIF
    IFDEF DEBUG32
    PrintText 'IFileSaveDialogInit CoCreateInstance Ok'
    ENDIF
    
    .IF pfd == 0
        IFDEF DEBUG32
        PrintText 'IFileSaveDialogInit pfd == 0'
        ENDIF
        jmp IFileSaveDialogInit_Error
    .ENDIF
    IFDEF DEBUG32
    PrintText 'IFileSaveDialogInit pfd ok'
    ENDIF
    
    ; Get functions:
    mov eax, pfd
    mov ebx, [eax]
    .IF ebx == 0
        IFDEF DEBUG32
        PrintText 'IFileSaveDialogInit pfd::ebx == 0'
        ENDIF
        jmp IFileSaveDialogInit_Error
    .ENDIF
    
    mov eax, [ebx].IFileSaveDialogVtbl.QueryInterface
    mov IFileSaveDialog_QueryInterface, eax
    mov eax, [ebx].IFileSaveDialogVtbl.AddRef
    mov IFileSaveDialog_AddRef, eax
    mov eax, [ebx].IFileSaveDialogVtbl.Release
    mov IFileSaveDialog_Release, eax
    mov eax, [ebx].IFileSaveDialogVtbl.Show
    mov IFileSaveDialog_Show, eax
    mov eax, [ebx].IFileSaveDialogVtbl.SetFileTypes
    mov IFileSaveDialog_SetFileTypes, eax
    mov eax, [ebx].IFileSaveDialogVtbl.SetFileTypeIndex
    mov IFileSaveDialog_SetFileTypeIndex, eax
    mov eax, [ebx].IFileSaveDialogVtbl.GetFileTypeIndex
    mov IFileSaveDialog_GetFileTypeIndex, eax
    mov eax, [ebx].IFileSaveDialogVtbl.Advise
    mov IFileSaveDialog_Advise, eax
    mov eax, [ebx].IFileSaveDialogVtbl.Unadvise
    mov IFileSaveDialog_Unadvise, eax
    mov eax, [ebx].IFileSaveDialogVtbl.SetOptions
    mov IFileSaveDialog_SetOptions, eax
    mov eax, [ebx].IFileSaveDialogVtbl.GetOptions
    mov IFileSaveDialog_GetOptions, eax
    mov eax, [ebx].IFileSaveDialogVtbl.SetDefaultFolder
    mov IFileSaveDialog_SetDefaultFolder, eax
    mov eax, [ebx].IFileSaveDialogVtbl.SetFolder
    mov IFileSaveDialog_SetFolder, eax
    mov eax, [ebx].IFileSaveDialogVtbl.GetFolder
    mov IFileSaveDialog_GetFolder, eax
    mov eax, [ebx].IFileSaveDialogVtbl.GetCurrentSelection
    mov IFileSaveDialog_GetCurrentSelection, eax
    mov eax, [ebx].IFileSaveDialogVtbl.SetFileName
    mov IFileSaveDialog_SetFileName, eax
    mov eax, [ebx].IFileSaveDialogVtbl.GetFileName
    mov IFileSaveDialog_GetFileName, eax
    mov eax, [ebx].IFileSaveDialogVtbl.SetTitle
    mov IFileSaveDialog_SetTitle, eax
    mov eax, [ebx].IFileSaveDialogVtbl.SetOkButtonLabel
    mov IFileSaveDialog_SetOkButtonLabel, eax
    mov eax, [ebx].IFileSaveDialogVtbl.SetFileNameLabel
    mov IFileSaveDialog_SetFileNameLabel, eax
    mov eax, [ebx].IFileSaveDialogVtbl.GetResult
    mov IFileSaveDialog_GetResult, eax
    mov eax, [ebx].IFileSaveDialogVtbl.AddPlace
    mov IFileSaveDialog_AddPlace, eax
    mov eax, [ebx].IFileSaveDialogVtbl.SetDefaultExtension
    mov IFileSaveDialog_SetDefaultExtension, eax
    mov eax, [ebx].IFileSaveDialogVtbl.Close
    mov IFileSaveDialog_Close, eax
    mov eax, [ebx].IFileSaveDialogVtbl.SetClientGuid
    mov IFileSaveDialog_SetClientGuid, eax
    mov eax, [ebx].IFileSaveDialogVtbl.ClearClientData
    mov IFileSaveDialog_ClearClientData, eax
    mov eax, [ebx].IFileSaveDialogVtbl.SetFilter
    mov IFileSaveDialog_SetFilter, eax
    mov eax, [ebx].IFileSaveDialogVtbl.SetSaveAsItem
    mov IFileSaveDialog_SetSaveAsItem, eax
    mov eax, [ebx].IFileSaveDialogVtbl.SetProperties
    mov IFileSaveDialog_SetProperties, eax
    mov eax, [ebx].IFileSaveDialogVtbl.SetCollectedProperties
    mov IFileSaveDialog_SetCollectedProperties, eax
    mov eax, [ebx].IFileSaveDialogVtbl.GetProperties
    mov IFileSaveDialog_GetProperties, eax
    mov eax, [ebx].IFileSaveDialogVtbl.ApplyProperties
    mov IFileSaveDialog_ApplyProperties, eax

    jmp IFileSaveDialogInit_Exit

IFileSaveDialogInit_Error:
    
    .IF ppIFileSaveDialog != 0
        mov ebx, ppIFileSaveDialog
        mov eax, 0
        mov [ebx], eax
    .ENDIF
    mov eax, FALSE
    ret
    
IFileSaveDialogInit_Exit:
    
    .IF ppIFileSaveDialog != 0
        mov ebx, ppIFileSaveDialog
        mov eax, pfd
        mov [ebx], eax
    .ENDIF
    mov eax, TRUE
    ret
IFileSaveDialogInit ENDP

ALIGN 8
;------------------------------------------------------------------------------
; IFileDialogInit
;
; Initialize CLSID_FileOpenDialog and the IFileDialog functions by copying 
; the vtable pointers of the IFileDialog object functions to global variables 
; that are prototyped to the appropriate function.
;
; This allows for using Invoke in the other functions. Alternatively the calls
; to the functions can be made by referencing them via the iFileDialog
; structure.
;
; Parameters:
; 
; * ppIFileDialog - pointer to a variable to store the IFileDialog pointer.
; 
; Returns:
; 
; TRUE if successful, or FALSE otherwise.
; 
; Notes:
;
; This is a convenience function, and the object functions can be made by ref
; to the structure directly instead.
;
; See Also:
;
; IFileOpenDialogInit, IFileSaveDialogInit, IShellItemInit, IShellItemArrayInit
; 
;------------------------------------------------------------------------------
IFileDialogInit PROC USES EBX ppIFileDialog:DWORD
    LOCAL pfd:DWORD
    
    .IF ppIFileDialog == NULL
        jmp IFileDialogInit_Error
    .ENDIF
    
    mov pfd, 0
    
    Invoke CoCreateInstance, Addr CLSID_FileOpenDialog, 0, CLSCTX_INPROC_SERVER, Addr IID_IFileDialog, Addr pfd
    .IF eax != S_OK
        IFDEF DEBUG32
        PrintText 'IFileDialogInit CoCreateInstance Failed'
        ENDIF
        jmp IFileDialogInit_Error
    .ENDIF
    IFDEF DEBUG32
    PrintText 'IFileDialogInit CoCreateInstance Ok'
    ENDIF
    
    .IF pfd == 0
        IFDEF DEBUG32
        PrintText 'IFileDialogInit pfd == 0'
        ENDIF
        jmp IFileDialogInit_Error
    .ENDIF
    IFDEF DEBUG32
    PrintText 'IFileDialogInit pfd ok'
    ENDIF
    
    ; Get functions:
    mov eax, pfd
    mov ebx, [eax]
    .IF ebx == 0
        IFDEF DEBUG32
        PrintText 'IFileDialogInit pfd::ebx == 0'
        ENDIF
        jmp IFileDialogInit_Error
    .ENDIF
    
    mov eax, [ebx].IFileDialogVtbl.QueryInterface
    mov IFileSaveDialog_QueryInterface, eax
    mov eax, [ebx].IFileDialogVtbl.AddRef
    mov IFileDialog_AddRef, eax
    mov eax, [ebx].IFileDialogVtbl.Release
    mov IFileDialog_Release, eax
    mov eax, [ebx].IFileDialogVtbl.Show
    mov IFileDialog_Show, eax
    mov eax, [ebx].IFileDialogVtbl.SetFileTypes
    mov IFileDialog_SetFileTypes, eax
    mov eax, [ebx].IFileDialogVtbl.SetFileTypeIndex
    mov IFileDialog_SetFileTypeIndex, eax
    mov eax, [ebx].IFileDialogVtbl.GetFileTypeIndex
    mov IFileDialog_GetFileTypeIndex, eax
    mov eax, [ebx].IFileDialogVtbl.Advise
    mov IFileDialog_Advise, eax
    mov eax, [ebx].IFileDialogVtbl.Unadvise
    mov IFileDialog_Unadvise, eax
    mov eax, [ebx].IFileDialogVtbl.SetOptions
    mov IFileDialog_SetOptions, eax
    mov eax, [ebx].IFileDialogVtbl.GetOptions
    mov IFileDialog_GetOptions, eax
    mov eax, [ebx].IFileDialogVtbl.SetDefaultFolder
    mov IFileDialog_SetDefaultFolder, eax
    mov eax, [ebx].IFileDialogVtbl.SetFolder
    mov IFileDialog_SetFolder, eax
    mov eax, [ebx].IFileDialogVtbl.GetFolder
    mov IFileDialog_GetFolder, eax
    mov eax, [ebx].IFileDialogVtbl.GetCurrentSelection
    mov IFileDialog_GetCurrentSelection, eax
    mov eax, [ebx].IFileDialogVtbl.SetFileName
    mov IFileDialog_SetFileName, eax
    mov eax, [ebx].IFileDialogVtbl.GetFileName
    mov IFileDialog_GetFileName, eax
    mov eax, [ebx].IFileDialogVtbl.SetTitle
    mov IFileDialog_SetTitle, eax
    mov eax, [ebx].IFileDialogVtbl.SetOkButtonLabel
    mov IFileDialog_SetOkButtonLabel, eax
    mov eax, [ebx].IFileDialogVtbl.SetFileNameLabel
    mov IFileDialog_SetFileNameLabel, eax
    mov eax, [ebx].IFileDialogVtbl.GetResult
    mov IFileDialog_GetResult, eax
    mov eax, [ebx].IFileDialogVtbl.AddPlace
    mov IFileDialog_AddPlace, eax
    mov eax, [ebx].IFileDialogVtbl.SetDefaultExtension
    mov IFileDialog_SetDefaultExtension, eax
    mov eax, [ebx].IFileDialogVtbl.Close
    mov IFileDialog_Close, eax
    mov eax, [ebx].IFileDialogVtbl.SetClientGuid
    mov IFileDialog_SetClientGuid, eax
    mov eax, [ebx].IFileDialogVtbl.ClearClientData
    mov IFileDialog_ClearClientData, eax
    mov eax, [ebx].IFileDialogVtbl.SetFilter
    mov IFileDialog_SetFilter, eax

    jmp IFileDialogInit_Exit

IFileDialogInit_Error:
    
    .IF ppIFileDialog != 0
        mov ebx, ppIFileDialog
        mov eax, 0
        mov [ebx], eax
    .ENDIF
    mov eax, FALSE
    ret
    
IFileDialogInit_Exit:
    
    .IF ppIFileDialog != 0
        mov ebx, ppIFileDialog
        mov eax, pfd
        mov [ebx], eax
    .ENDIF
    mov eax, TRUE
    ret
IFileDialogInit ENDP

ALIGN 8
;------------------------------------------------------------------------------
; IShellItemInit
;
; Copies the IShellItem vtable function pointers to global variables that are 
; prototyped to the appropriate function.
;
; This allows for using Invoke in the other functions. Alternatively the calls
; to the functions can be made by referencing them via the IShellItem structure
;
; Parameters:
; 
; * pIShellItem - a IShellItem pointer.
; 
; Returns:
; 
; TRUE if successful, or FALSE otherwise.
; 
; Notes:
;
; Unlike the IFileOpenDialogInit and IFileSaveDialogInit function, this 
; function does not create the IShellItem and pass back the reference to the
; parameter specified.
;
; This function requires that the IShellItem be already created, and it merely 
; copies the vtable function pointers to global variables for convenience.
;
; In most cases you probably should just use the reference of the IShellItem 
; functions via the IShellItem structure instead of using this function and the
; global variables.
;
; See Also:
;
; IFileOpenDialogInit, IFileSaveDialogInit, IFileDialogInit, IShellItemArrayInit
; 
;------------------------------------------------------------------------------
IShellItemInit PROC USES EBX pIShellItem:DWORD

    .IF pIShellItem == 0
        jmp IShellItemInit_Error
    .ENDIF
    
    ; Get functions:
    mov eax, pIShellItem
    mov ebx, [eax]
    .IF ebx == 0
        IFDEF DEBUG32
        PrintText 'IShellItemInit psi::ebx == 0'
        ENDIF
        jmp IShellItemInit_Error
    .ENDIF
    
    mov eax, [ebx].IShellItemVtbl.QueryInterface
    mov IShellItem_QueryInterface, eax
    mov eax, [ebx].IShellItemVtbl.AddRef
    mov IShellItem_AddRef, eax
    mov eax, [ebx].IShellItemVtbl.Release
    mov IShellItem_Release, eax
    mov eax, [ebx].IShellItemVtbl.BindToHandler
    mov IShellItem_BindToHandler, eax
    mov eax, [ebx].IShellItemVtbl.GetParent
    mov IShellItem_GetParent, eax
    mov eax, [ebx].IShellItemVtbl.GetDisplayName
    mov IShellItem_GetDisplayName, eax
    mov eax, [ebx].IShellItemVtbl.GetAttributes
    mov IShellItem_GetAttributes, eax
    mov eax, [ebx].IShellItemVtbl.Compare
    mov IShellItem_Compare, eax

    jmp IShellItemInit_Exit

IShellItemInit_Error:
    
    mov eax, FALSE
    ret
    
IShellItemInit_Exit:
    
    mov eax, TRUE
    ret
    
IShellItemInit ENDP

ALIGN 8
;------------------------------------------------------------------------------
; IShellItemArrayInit
;
; Copies the IShellItemArray vtable function pointers to global variables that 
; are prototyped to the appropriate function.
;
; This allows for using Invoke in the other functions. Alternatively the calls
; to the functions can be made by referencing them via the IShellItemArray
; structure.
;
; Parameters:
; 
; * pIShellItemArray - a IShellItemArray pointer.
; 
; Returns:
; 
; TRUE if successful, or FALSE otherwise.
; 
; Notes:
;
; Unlike the IFileOpenDialogInit and IFileSaveDialogInit function, this 
; function does not create the IShellItemArray and pass back the reference to 
; the parameter specified.
;
; This function requires that the IShellItemArray be already created, and it 
; merely copies vtable function pointers to global variables for convenience.
;
; In most cases you probably should just use the reference of the 
; IShellItemArray functions via the IShellItemArray structure instead of using 
; this function and the global variables.
;
; See Also:
;
; IFileOpenDialogInit, IFileSaveDialogInit, IFileDialogInit, IShellItemArrayInit
; 
;------------------------------------------------------------------------------
IShellItemArrayInit PROC USES EBX pIShellItemArray:DWORD

    .IF pIShellItemArray == 0
        jmp IShellItemArrayInit_Error
    .ENDIF

    ; Get functions:
    mov eax, pIShellItemArray
    mov ebx, [eax]
    .IF ebx == 0
        IFDEF DEBUG32
        PrintText 'IShellItemArrayInit psi::ebx == 0'
        ENDIF
        jmp IShellItemArrayInit_Error
    .ENDIF
    
    mov eax, [ebx].IShellItemArrayVtbl.QueryInterface
    mov IShellItemArray_QueryInterface, eax
    mov eax, [ebx].IShellItemArrayVtbl.AddRef
    mov IShellItemArray_AddRef, eax
    mov eax, [ebx].IShellItemArrayVtbl.Release
    mov IShellItemArray_Release, eax
    mov eax, [ebx].IShellItemArrayVtbl.BindToHandler
    mov IShellItemArray_BindToHandler, eax
    mov eax, [ebx].IShellItemArrayVtbl.GetPropertyStore
    mov IShellItemArray_GetPropertyStore, eax
    mov eax, [ebx].IShellItemArrayVtbl.GetPropertyDescriptionList
    mov IShellItemArray_GetPropertyDescriptionList, eax
    mov eax, [ebx].IShellItemArrayVtbl.GetAttributes
    mov IShellItemArray_GetAttributes, eax
    mov eax, [ebx].IShellItemArrayVtbl.GetCount
    mov IShellItemArray_GetCount, eax
    mov eax, [ebx].IShellItemArrayVtbl.GetItemAt
    mov IShellItemArray_GetItemAt, eax
    mov eax, [ebx].IShellItemArrayVtbl.EnumItems
    mov IShellItemArray_EnumItems, eax

    jmp IShellItemArrayInit_Exit

IShellItemArrayInit_Error:

    mov eax, FALSE
    ret
    
IShellItemArrayInit_Exit:

    mov eax, TRUE
    ret

IShellItemArrayInit ENDP

ALIGN 8
;------------------------------------------------------------------------------
; _FD_ConvertStringToAnsi 
;
; Converts a Wide/Unicode string to an ANSI/UTF8 string.
;
; Parameters:
; 
; * lpszWideString - pointer to a wide string to convert to an Ansi string.
; 
; Returns:
; 
; A pointer to the Ansi string if successful, or NULL otherwise.
; 
; Notes:
;
; The string that is converted should be freed when it is no longer needed with 
; a call to the _FD_ConvertStringFree function.
;
; See Also:
;
; _FD_ConvertStringToWide, _FD_ConvertStringFree
; 
;------------------------------------------------------------------------------
_FD_ConvertStringToAnsi PROC lpszWideString:DWORD
    LOCAL dwAnsiStringSize:DWORD
    LOCAL lpszAnsiString:DWORD

    .IF lpszWideString == NULL
        mov eax, NULL
        ret
    .ENDIF
    Invoke WideCharToMultiByte, CP_UTF8, 0, lpszWideString, -1, NULL, 0, NULL, NULL
    .IF eax == 0
        ret
    .ENDIF
    mov dwAnsiStringSize, eax
    ;shl eax, 1 ; x2 to get non wide char count
    add eax, 4 ; add 4 for good luck and nulls
    Invoke GlobalAlloc, GMEM_FIXED or GMEM_ZEROINIT, eax
    .IF eax == NULL
        ret
    .ENDIF
    mov lpszAnsiString, eax    
    Invoke WideCharToMultiByte, CP_UTF8, 0, lpszWideString, -1, lpszAnsiString, dwAnsiStringSize, NULL, NULL
    .IF eax == 0
        ret
    .ENDIF
    mov eax, lpszAnsiString
    ret
_FD_ConvertStringToAnsi ENDP

ALIGN 8
;------------------------------------------------------------------------------
; _FD_ConvertStringToWide
;
; Converts a Ansi string to an Wide/Unicode string.
;
; Parameters:
; 
; * lpszAnsiString - pointer to an Ansi string to convert to a Wide string.
; 
; Returns:
; 
; A pointer to the Wide string if successful, or NULL otherwise.
; 
; Notes:
;
; The string that is converted should be freed when it is no longer needed with 
; a call to the _FD_ConvertStringFree function.
;
; See Also:
;
; _FD_ConvertStringToAnsi, _FD_ConvertStringFree
; 
;------------------------------------------------------------------------------
_FD_ConvertStringToWide PROC lpszAnsiString:DWORD
    LOCAL dwWideStringSize:DWORD
    LOCAL lpszWideString:DWORD
    
    .IF lpszAnsiString == NULL
        mov eax, NULL
        ret
    .ENDIF
    Invoke MultiByteToWideChar, CP_UTF8, 0, lpszAnsiString, -1, NULL, 0
    .IF eax == 0
        ret
    .ENDIF
    mov dwWideStringSize, eax
    shl eax, 1 ; x2 to get non wide char count
    add eax, 4 ; add 4 for good luck and nulls
    Invoke GlobalAlloc, GMEM_FIXED or GMEM_ZEROINIT, eax
    .IF eax == NULL
        ret
    .ENDIF
    mov lpszWideString, eax
    Invoke MultiByteToWideChar, CP_UTF8, 0, lpszAnsiString, -1, lpszWideString, dwWideStringSize
    .IF eax == 0
        ret
    .ENDIF
    mov eax, lpszWideString
    ret
_FD_ConvertStringToWide ENDP

ALIGN 8
;------------------------------------------------------------------------------
; _FD_ConvertStringFree
;
; Frees a string created by _FD_ConvertStringToWide or _FD_ConvertStringToAnsi
;
; Parameters:
; 
; * lpString - pointer to a converted string to free.
; 
; Returns:
; 
; None.
; 
; See Also:
;
; _FD_ConvertStringToWide, _FD_ConvertStringToAnsi
; 
;------------------------------------------------------------------------------
_FD_ConvertStringFree PROC lpString:DWORD
    mov eax, lpString
    .IF eax == NULL
        mov eax, FALSE
        ret
    .ENDIF
    Invoke GlobalFree, eax
    mov eax, TRUE
    ret
_FD_ConvertStringFree ENDP



END
