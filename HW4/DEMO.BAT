@echo off
call BUILD.BAT
if not exist BUILD.OK goto end
cls
MUL9.EXE
echo.
echo === Experiment 2: check the 9-by-9 table ===
FIX9.EXE
echo.
echo Type MUL9 or FIX9 to run again. REGTEST checks experiment 1.
:end
