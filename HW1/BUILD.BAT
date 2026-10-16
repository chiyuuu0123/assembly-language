@echo off
masm HELLO.ASM,HELLO.OBJ,HELLO.LST,HELLO.CRF;
if errorlevel 1 goto fail
link HELLO.OBJ,HELLO.EXE,HELLO.MAP;
if errorlevel 1 goto fail
cref HELLO.CRF,HELLO.REF;
echo.
echo === Normal: assembled and linked EXE ===
HELLO.EXE
goto end
:fail
echo BUILD FAILED. Read the messages above.
:end
