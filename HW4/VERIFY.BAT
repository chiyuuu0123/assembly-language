@echo off
if exist DONE.TXT del DONE.TXT
call BUILD.BAT
if not exist BUILD.OK goto fail
MUL9.EXE > ASMOUT.TXT
if errorlevel 1 goto fail
REGTEST.EXE > REGTEST.TXT
if errorlevel 1 goto fail
echo DONE > DONE.TXT
exit
:fail
echo FAILED > DONE.TXT
exit
