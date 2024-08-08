.. _IFileOpenDialogInit:

===================
IFileOpenDialogInit
===================

Initialize CLSID_FileOpenDialog and the IFileOpenDialog functions by copying the vtable pointers of the IFileOpenDialog object functions to global variables that are prototyped to the appropriate function. This allows for using Invoke in the other functions. Alternatively the calls to the functions can be made by referencing them via the iFileOpenDialog structure.

::

   IFileOpenDialogInit PROTO ppIFileOpenDialog:DWORD


**Parameters**

* ``ppIFileOpenDialog`` - pointer to a variable to store the IFileOpenDialog pointer.


**Returns**

TRUE if successful, or FALSE otherwise.


**Notes**

This is a convenience function, and the object functions can be made by ref to the structure directly instead.


**See Also**

:ref:`IFileSaveDialogInit<IFileSaveDialogInit>`, :ref:`IFileDialogInit<IFileDialogInit>`, :ref:`IShellItemInit<IShellItemInit>`, :ref:`IShellItemArrayInit<IShellItemArrayInit>`
