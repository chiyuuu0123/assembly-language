@echo off
call BUILD.BAT
if not exist BUILD.OK goto end
cls
echo === Assignment 5: recursive Fibonacci ===
FIBRUN.EXE
echo.
echo Type FIBRUN to try another n, or DEBUG TRACE.EXE to single-step n=4.
:end
