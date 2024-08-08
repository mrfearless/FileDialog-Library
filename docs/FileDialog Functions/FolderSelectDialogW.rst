.. _FolderSelectDialogW:

===================
FolderSelectDialogW
===================

Displays a dialog box that enables the user to select a folder.

::

   FolderSelectDialogW PROTO lpszTitle:DWORD, lpszOkLabel:DWORD, lpszFileLabel:DWORD, lpszFolder:DWORD, hWndOwner:DWORD, lpdwFolder:DWORD


**Parameters**

* ``lpszTitle`` - pointer to a string for the title of the select folder dialog.

* ``lpszOkLabel`` - pointer to a string for the ok button in the dialog.

* ``lpszFileLabel`` - pointer to a string for the file label in the dialog.

* ``lpszFolder`` - pointer to a string for the initial folder to start in.

* ``hWndOwner`` - handle of the parent window that owns this dialog.

* ``lpdwFolder`` - pointer to a variable thats stores a pointer to a string containing the folder that was selected by the user.


**Returns**

TRUE if successful, or FALSE otherwise.


**Notes**

This is the Wide/Unicode version of FolderSelectDialog. All strings passed as parameters are expected to be Wide/Unicode strings, and the return results are stored in the lpdwFolder parameter as a pointer to a Wide/Unicode string.

For the Ansi version see the FolderSelectDialogA function.

FolderSelectDialog Implements the IFileDialog of CLSID_FileOpenDialog

**See Also**

:ref:`FileOpenDialogW<FileOpenDialogW>`, :ref:`FileSaveDialogW<FileSaveDialogW>`
