@echo off
cd /d "%~dp0HW2"
call BUILD_C.cmd
if errorlevel 1 (
    pause
    exit /b 1
)
echo === Assignment 2 - C version (32-bit Windows) ===
ASCII_C.EXE
echo.
echo Opening the two assembly versions in DOSBox...
start "" "..\tools\DOSBox\DOSBox.exe" -noconsole -conf DOSBOX.CONF -c "mount c ." -c "c:" -c "DEMO.BAT"
echo.
pause
