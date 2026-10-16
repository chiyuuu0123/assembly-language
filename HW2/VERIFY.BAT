@echo off
masm ASCII_L.ASM,ASCII_L.OBJ,ASCII_L.LST; > LOOPASM.LOG
if errorlevel 1 goto fail
link ASCII_L.OBJ,ASCII_L.EXE,ASCII_L.MAP; > LOOPLINK.LOG
if errorlevel 1 goto fail
masm ASCII_J.ASM,ASCII_J.OBJ,ASCII_J.LST; > JUMPASM.LOG
if errorlevel 1 goto fail
link ASCII_J.OBJ,ASCII_J.EXE,ASCII_J.MAP; > JUMPLINK.LOG
if errorlevel 1 goto fail
ASCII_L.EXE > LOOP.TXT
ASCII_J.EXE > JUMP.TXT
echo PASS > DONE.TXT
exit
:fail
echo BUILD FAILED > DONE.TXT
exit
