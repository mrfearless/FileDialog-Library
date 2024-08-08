.. _IShellItemArrayInit:

===================
IShellItemArrayInit
===================

Copies the IShellItemArray vtable function pointers to global variables that are prototyped to the appropriate function. This allows for using Invoke in the other functions. Alternatively the calls to the functions can be made by referencing them via the IShellItemArray structure.

::

   IShellItemArrayInit PROTO pIShellItemArray:DWORD


**Parameters**

* ``pIShellItemArray`` - a IShellItemArray pointer.


**Returns**

TRUE if successful, or FALSE otherwise.


**Notes**

Unlike the IFileOpenDialogInit and IFileSaveDialogInit function, this function does not create the IShellItemArray and pass back the reference to the parameter specified.

This function requires that the IShellItemArray be already created, and it merely copies vtable function pointers to global variables for convenience.

In most cases you probably should just use the reference of the IShellItemArray functions via the IShellItemArray structure instead of using this function and the global variables.


**See Also**

:ref:`IFileOpenDialogInit<IFileOpenDialogInit>`, :ref:`IFileSaveDialogInit<IFileSaveDialogInit>`, :ref:`IFileDialogInit<IFileDialogInit>`, :ref:`IShellItemArrayInit<IShellItemArrayInit>`
