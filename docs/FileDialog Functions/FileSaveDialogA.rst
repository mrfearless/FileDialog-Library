.. _FileSaveDialogA:

===============
FileSaveDialogA
===============

Creates a Save dialog box that lets the user specify the drive, directory, and name of a file to save.

::

   FileSaveDialogA PROTO lpszTitle:DWORD, lpszOkLabel:DWORD, lpszFileLabel:DWORD, lpszFolder:DWORD, nMFS:DWORD, pMFS:DWORD, hWndOwner:DWORD, bWarn:DWORD, lpszFileName:DWORD, lpdwSaveFile:DWORD


**Parameters**

* ``lpszTitle`` - pointer to a string for the title of the save dialog.

* ``lpszOkLabel`` - pointer to a string for the ok button in the save dialog.

* ``lpszFileLabel`` - pointer to a string for the file label in the save dialog.

* ``lpszFolder`` - pointer to a string for the initial folder to start in.

* ``nMFS`` - number of COMDLG_FILTERSPEC structures pointed to by pMFS.

* ``pMFS`` - array of COMDLG_FILTERSPEC structures for multi file spec.

* ``hWndOwner`` - handle of the parent window that owns this save dialog.

* ``bWarn`` - prompt before overwriting an existing file of the same name.

* ``lpszFileName`` - pointer to a string for the initial filename to use.

* ``lpdwSaveFile`` - pointer to a variable that stores a pointer to a string containting the save filename to use.


**Returns**

TRUE if successful, or FALSE otherwise.


**Notes**

This is the Ansi version of FileSaveDialog. All strings passed as parameters are expected to be Ansi strings, and the return results are stored in the lpdwSaveFile parameter as a pointer to an Ansi string.

For the Wide/Unicode version see the FileSaveDialogW function.

FileSaveDialog Implements the common file save dialog (CLSID_FileSaveDialog)

**See Also**

:ref:`FileOpenDialogA<FileOpenDialogA>`, :ref:`FolderSelectDialogA<FolderSelectDialogA>`
