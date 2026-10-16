@echo off
cls
echo === Assignment 1: MASM 5.0 + DOSBox ===
echo.
call BUILD.BAT
echo.
echo === Direct memory: DEBUG E command, then G ===
debug < MEMORY.TXT
echo.
echo Both methods should print: Hello world!
echo Type DEBUG to practice the commands in MEMORY.TXT.
