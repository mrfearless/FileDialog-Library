.. _IFileDialogInit:

===============
IFileDialogInit
===============

Initialize CLSID_FileOpenDialog and the IFileDialog functions by copying the vtable pointers of the IFileDialog object functions to global variables that are prototyped to the appropriate function. This allows for using Invoke in the other functions. Alternatively the calls to the functions can be made by referencing them via the iFileDialog structure.

::

   IFileDialogInit PROTO ppIFileDialog:DWORD


**Parameters**

* ``ppIFileDialog`` - pointer to a variable to store the IFileDialog pointer.


**Returns**

TRUE if successful, or FALSE otherwise.


**Notes**

This is a convenience function, and the object functions can be made by ref to the structure directly instead.


**See Also**

:ref:`IFileOpenDialogInit<IFileOpenDialogInit>`, :ref:`IFileSaveDialogInit<IFileSaveDialogInit>`, :ref:`IShellItemInit<IShellItemInit>`, :ref:`IShellItemArrayInit<IShellItemArrayInit>`
