@echo off
cd /d "%~dp0HW5"
if not exist "..\tools\DOSBox\DOSBox.exe" (
    echo DOSBox not found. See ENVIRONMENT.md.
    pause
    exit /b 1
)
call BUILD_C.cmd
if errorlevel 1 (
    pause
    exit /b 1
)
start "" "..\tools\DOSBox\DOSBox.exe" -noconsole -conf DOSBOX.CONF -c "mount c ." -c "c:" -c "DEMO.BAT"
echo === Assignment 5: C version, Windows x86 ===
FIB_C.EXE
pause
