@echo off
cd /d "%~dp0HW1"
start "" "..\tools\DOSBox\DOSBox.exe" -noconsole -conf DOSBOX.CONF -c "mount c ." -c "c:" -c "DEMO.BAT"
