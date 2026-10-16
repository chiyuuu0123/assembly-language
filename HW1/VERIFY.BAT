@echo off
masm HELLO.ASM,HELLO.OBJ,HELLO.LST,HELLO.CRF; > ASM.LOG
if errorlevel 1 goto fail
link HELLO.OBJ,HELLO.EXE,HELLO.MAP; > LINK.LOG
if errorlevel 1 goto fail
cref HELLO.CRF,HELLO.REF; > CREF.LOG
HELLO.EXE > NORMAL.TXT
debug < MEMORY.TXT > MEMORY.LOG
echo DONE > DONE.TXT
exit
:fail
echo BUILD FAILED > DONE.TXT
exit
