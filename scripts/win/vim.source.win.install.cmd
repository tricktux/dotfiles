@echo off
mingw32-make -f Make_ming.mak ARCH=x86-64 STATIC_STDCPLUS=yes OLE=yes NETBEANS=no ^
PYTHON="C:/tools/python2" PYTHON_VER=27 DYNAMIC_PYTHON=yes ^
PYTHON3="C:\ProgramData\chocolatey\lib\python3\tools" PYTHON3_VER=35 DYNAMIC_PYTHON3=yes ^
LUA="C:\ProgramData\chocolatey\lib\lua53\tools" DYNAMIC_LUA=yes LUA_VER=53 XPM=no ^
-j8 gvim.exe

REM  These comments are taken from the Min_cyg_ming.mak file. Which is Included by the Make_ming.mak file
REM  Command must be run inside vim/src folder
REM  YOU NEED TO:
REM   - Download lua sources. Extract it and from there
REM     - *Be careful with the lua source that you extract and your current lua
REM     version
REM   - Copy lualib.h to the location of cpp -v 
REM   - Copy luaxlib.h to the location of cpp -v 
REM   - Copy lua.h to LUA folder
REM   - Copy luaconf.h to LUA folder

REM  NOTICE:
REM   Good attemp but lua and python didnt work
REM     Could be because I copied lua files that are not compatible or something
REM   Anyways switcing to vim-tux. You can do `cinst vim-tux`
REM     It is an up to date library

REM  # Set ARCH to one of i386, i486, i586, i686 as the minimum target processor.
REM  # For amd64/x64 architecture set ARCH=x86-64 .
REM  # If not set, it will be automatically detected. (Normally i686 or x86-64.)

REM  #	Python interface:
REM  #	  PYTHON=[Path to Python directory] (Set inside Make_cyg.mak or Make_ming.mak)
REM  #	  DYNAMIC_PYTHON=yes (to load the Python DLL dynamically)
REM  #	  PYTHON_VER=[Python version, eg 22, 23, ..., 27] (default is 27)

REM  #	Python3 interface:
REM  #	  PYTHON3=[Path to Python3 directory] (Set inside Make_cyg.mak or Make_ming.mak)
REM  #	  DYNAMIC_PYTHON3=yes (to load the Python3 DLL dynamically)
REM  #	  PYTHON3_VER=[Python3 version, eg 31, 32] (default is 35)

REM  #	Lua interface:
REM  #	  LUA=[Path to Lua directory] (Set inside Make_cyg.mak or Make_ming.mak)
REM  #	  DYNAMIC_LUA=yes (to load the Lua DLL dynamically)
REM  #	  LUA_VER=[Lua version, eg 51, 52] (default is 53)

REM  #########################################################
REM  ######DONT PAY ATTENTION TO MSCV BUILD##################
REM  Windows SDK Include directory. No quotation marks.
REM  set SDK_INCLUDE_DIR=C:\Program Files (x86)\Windows Kits\8.1\Include

REM  Visual Studio directory. Quotation marks.
REM  set VS_DIR="C:\Program Files (x86)\Microsoft Visual Studio 12.0"

REM  Target architecture, AMD64 (64-bit) or I386 (32-bit)
REM  set CPU=AMD64

REM  Toolchain, x86_amd64 (cross-compile 64-bit) or x86 (32-bit) or amd64 (64-bit)
REM  set TOOLCHAIN=x86_amd64

REM  TINY, SMALL, NORMAL, BIG or HUGE. NORMAL or above recommended
REM  set FEATURES=HUGE

REM  yes for gVim, no for vim
REM  set GUI=yes

REM  IDE integrations we don't need
REM  set NETBEANS=no
REM  set CSCOPE=yes

REM  UTF-8 encoding
REM  set MBYTE=yes

REM  Enable Python scripting
REM  set DYNAMIC_PYTHON=yes
REM  set PYTHON=C:\Python27
REM  set PYTHON_VER=27

REM  echo "Configuring Visual Studio..."
REM  call %VS_DIR%\VC\vcvarsall.bat %TOOLCHAIN%
