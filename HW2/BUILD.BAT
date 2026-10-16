@echo off
masm ASCII_L.ASM,ASCII_L.OBJ,ASCII_L.LST;
if errorlevel 1 goto fail
link ASCII_L.OBJ,ASCII_L.EXE,ASCII_L.MAP;
if errorlevel 1 goto fail
masm ASCII_J.ASM,ASCII_J.OBJ,ASCII_J.LST;
if errorlevel 1 goto fail
link ASCII_J.OBJ,ASCII_J.EXE,ASCII_J.MAP;
if errorlevel 1 goto fail
echo Both assembly programs built successfully.
goto end
:fail
echo BUILD FAILED. Read the messages above.
:end
