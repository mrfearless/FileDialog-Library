.. _Building:

========
Building
========

The FileDialog Libraries (both x86 and x64 versions) come with RadASMs project to help you build the sources. However if you wish to build the libraries manually, here are the command line options you should use.


.. _Building the FileDialog Library x86:

Building the FileDialog Library x86
-----------------------------------

The FileDialog Library x86 source consists of the following files:

* ``FileDialog.inc``
* ``FileDialog.asm``


**Building with Microsoft MASM** (``ML.EXE``):

::

   ML.EXE /c /coff /Cp /nologo /I"X:\MASM32\Include" *.asm


.. note:: ``X`` is the drive letter where the `MASM32 <http://www.masm32.com>`_ package has been installed to.


**Linking with Microsoft Library Manager** (``LIB.EXE``):

::

   LIB *.obj /out:FileDialog.lib



.. _Building the FileDialog Library x86 Debug Build:

Building the FileDialog Library x86 Debug Build
-----------------------------------------------

To build the FileDialog Library x86 with debug information, supply the additional flag options ``/Zi /Zd`` on the command line for MASM (``ML.EXE``) like so:

::

   ML.EXE /c /coff /Cp /Zi /Zd /nologo /I"X:\MASM32\Include" *.asm


.. note:: ``X`` is the drive letter where the `MASM32 <http://www.masm32.com>`_ package has been installed to.



.. _Building the FileDialog Library x64:

Building the FileDialog Library x64
-----------------------------------

The FileDialog Library x64 source consists of the following files:

* ``FileDialog.inc``
* ``FileDialog.asm``


**Building with UASM** (``UASM64.EXE``):

::

   UASM64.EXE /c -win64 -Zp8 /win64 /D_WIN64 /Cp /nologo /W2 /I"X:\UASM\Include" *.asm


.. note:: ``X`` is the drive letter where the `UASM <http://www.terraspace.co.uk/uasm.html>`_ assembler has been installed to.


**Linking with Microsoft Library Manager** (``LIB.EXE``):

::

   LIB *.obj /out:FileDialog.lib



.. _Building the FileDialog Library x64 Debug Build:

Building the FileDialog Library x64 Debug Build
-----------------------------------------------

To build the FileDialog Library x64 with debug information, supply the additional flag options ``/Zi /Zd`` on the command line for UASM (``UASM64.EXE``) like so:

::
    
   UASM64.EXE /c -win64 -Zp8 /Zi /Zd /win64 /D_WIN64 /Cp /nologo /W2 /I"X:\UASM\Include" *.asm



.. note:: ``X`` is the drive letter where the `MASM32 <http://www.masm32.com>`_ package has been installed to... note:: ``X`` is the drive letter where the `UASM <http://www.terraspace.co.uk/uasm.html>`_ assembler has been installed to.