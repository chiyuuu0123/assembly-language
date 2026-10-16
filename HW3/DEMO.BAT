@echo off
if exist BUILD.OK del BUILD.OK
call BUILD.BAT
if not exist BUILD.OK goto end
cls
echo === Assignment 3: 1 + 2 + ... + 100 ===
echo.
echo [1] Result in register AX:
SUM_REG.EXE
echo [2] Result in data segment TOTAL:
SUM_DATA.EXE
echo [3] Result in stack local SS:[BP-2]:
SUM_STK.EXE
echo.
echo [4] Interactive sum from 1 to n:
SUM_IN.EXE
:end
