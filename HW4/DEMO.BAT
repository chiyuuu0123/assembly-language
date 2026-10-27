@echo off
call BUILD.BAT
if not exist BUILD.OK goto end
cls
MUL9.EXE
echo.
echo Type MUL9 to run again, or REGTEST to check register preservation.
:end
