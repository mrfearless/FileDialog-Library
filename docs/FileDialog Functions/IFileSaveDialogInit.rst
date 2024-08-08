.. _IFileSaveDialogInit:

===================
IFileSaveDialogInit
===================

Initialize CLSID_FileSaveDialog and the IFileSaveDialog functions by copying the vtable pointers of the IFileSaveDialog object functions to global variables that are prototyped to the appropriate function. This allows for using Invoke in the other functions. Alternatively the calls to the functions can be made by referencing them via the iFileSaveDialog structure.

::

   IFileSaveDialogInit PROTO ppIFileSaveDialog:DWORD


**Parameters**

* ``ppIFileSaveDialog`` - pointer to a variable to store the IFileSaveDialog pointer.


**Returns**

TRUE if successful, or FALSE otherwise.


**Notes**

This is a convenience function, and the object functions can be made by ref to the structure directly instead.


**See Also**

:ref:`IFileOpenDialogInit<IFileOpenDialogInit>`, :ref:`IFileDialogInit<IFileDialogInit>`, :ref:`IShellItemInit<IShellItemInit>`, :ref:`IShellItemArrayInit<IShellItemArrayInit>`
