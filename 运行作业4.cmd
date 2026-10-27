@echo off
cd /d "%~dp0HW4"
if not exist "..\tools\DOSBox\DOSBox.exe" (
    echo DOSBox not found. See ENVIRONMENT.md for setup instructions.
    pause
    exit /b 1
)
call BUILD_C.cmd
if errorlevel 1 (
    pause
    exit /b 1
)
start "" "..\tools\DOSBox\DOSBox.exe" -noconsole -conf DOSBOX.CONF -c "mount c ." -c "c:" -c "DEMO.BAT"
echo === Assignment 4: C version, Windows x86 ===
MUL9_C.EXE
pause
