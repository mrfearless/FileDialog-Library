.. _FileOpenDialogA:

===============
FileOpenDialogA
===============

Creates an Open dialog box that lets the user specify the drive, directory, and the name of a file or set of files to be opened.

::

   FileOpenDialogA PROTO lpszTitle:DWORD, lpszOkLabel:DWORD, lpszFileLabel:DWORD, lpszFolder:DWORD, nMFS:DWORD, pMFS:DWORD, hWndOwner:DWORD, bMulti:DWORD, lpdwFiles:DWORD, lpFilesArray:DWORD


**Parameters**

* ``lpszTitle`` - pointer to a string for the title of the open dialog.

* ``lpszOkLabel`` - pointer to a string for the ok button in the open dialog.

* ``lpszFileLabel`` - pointer to a string for the file label in the open dialog.

* ``lpszFolder`` - pointer to a string for the initial folder to start in.

* ``nMFS`` - number of COMDLG_FILTERSPEC structures pointed to by pMFS.

* ``pMFS`` - array of COMDLG_FILTERSPEC structures for multi file spec.

* ``hWndOwner`` - handle of the parent window that owns this open dialog.

* ``bMulti`` - allow multiple file selection (TRUE) or single file only (FALSE)

* ``lpdwFiles`` - pointer to a variable that stores the number of files that the user selected to 'open' and the number of files in the lpFilesArray array of filenames.   

* ``lpFilesArray`` - pointer to a variable that stores a pointer to a null separated list of filenames that the user selected to 'open'. The list ends with a double null.


**Returns**

TRUE if successful, or FALSE otherwise.


**Notes**

This is the Ansi version of FileOpenDialog. All strings passed as parameters are expected to be Ansi strings, and the return results are stored in the lpFilesArray parameter as a pointer to an array of Ansi strings.

For the Wide/Unicode version see the FileOpenDialogW function.

FileOpenDialog Implements the common file open dialog (CLSID_FileOpenDialog)

**See Also**

:ref:`FileSaveDialogA<FileSaveDialogA>`, :ref:`FolderSelectDialogA<FolderSelectDialogA>`
