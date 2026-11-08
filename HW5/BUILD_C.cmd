@echo off
setlocal
cd /d "%~dp0"
set "taskVcVars=%VCVARS32%"
for %%V in (2022 2019) do for %%E in (Community Professional Enterprise BuildTools) do if not defined taskVcVars if exist "%ProgramFiles%\Microsoft Visual Studio\%%V\%%E\VC\Auxiliary\Build\vcvars32.bat" set "taskVcVars=%ProgramFiles%\Microsoft Visual Studio\%%V\%%E\VC\Auxiliary\Build\vcvars32.bat"
for %%V in (2022 2019) do for %%E in (Community Professional Enterprise BuildTools) do if not defined taskVcVars if exist "%ProgramFiles(x86)%\Microsoft Visual Studio\%%V\%%E\VC\Auxiliary\Build\vcvars32.bat" set "taskVcVars=%ProgramFiles(x86)%\Microsoft Visual Studio\%%V\%%E\VC\Auxiliary\Build\vcvars32.bat"
if not defined taskVcVars (
    echo Visual Studio C++ tools not found. Set VCVARS32 to vcvars32.bat.
    exit /b 1
)
call "%taskVcVars%"
if errorlevel 1 exit /b 1
"%VCToolsInstallDir%bin\Hostx86\x86\cl.exe" /nologo /TC /W4 /Od /Oy- /GS- /MT /c /FAs /FaFIB_C.COD /FoFIB_C.OBJ FIB_C.C
if errorlevel 1 exit /b 1
"%VCToolsInstallDir%bin\Hostx86\x86\link.exe" /nologo /OUT:FIB_C.EXE /SUBSYSTEM:CONSOLE /INCREMENTAL:NO /MAP:FIB_C.MAP FIB_C.OBJ
if errorlevel 1 exit /b 1
"%VCToolsInstallDir%bin\Hostx86\x86\dumpbin.exe" /nologo /DISASM:BYTES FIB_C.OBJ > C_RAW.TXT
if errorlevel 1 exit /b 1
"%VCToolsInstallDir%bin\Hostx86\x86\dumpbin.exe" /nologo /RELOCATIONS FIB_C.OBJ > C_RELOC.TXT
if errorlevel 1 exit /b 1
rem Run CHECK.py check to execute the Fibonacci tests.
exit /b %errorlevel%
