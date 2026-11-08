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
"%VCToolsInstallDir%bin\Hostx86\x86\cl.exe" /nologo /TC /W4 /Od /Oy- /GS- /MT /c /FAs /FaMUL9_C.COD /FoMUL9_C.OBJ MUL9_C.C
if errorlevel 1 exit /b 1
"%VCToolsInstallDir%bin\Hostx86\x86\link.exe" /nologo /OUT:MUL9_C.EXE /SUBSYSTEM:CONSOLE /INCREMENTAL:NO /MAP:MUL9_C.MAP MUL9_C.OBJ
if errorlevel 1 exit /b 1
"%VCToolsInstallDir%bin\Hostx86\x86\dumpbin.exe" /nologo /DISASM:BYTES MUL9_C.OBJ > C_RAW.TXT
if errorlevel 1 exit /b 1
"%VCToolsInstallDir%bin\Hostx86\x86\dumpbin.exe" /nologo /RELOCATIONS MUL9_C.OBJ > C_RELOC.TXT
if errorlevel 1 exit /b 1
MUL9_C.EXE > COUT.TXT
if errorlevel 1 exit /b 1
"%VCToolsInstallDir%bin\Hostx86\x86\cl.exe" /nologo /TC /W4 /Od /Oy- /GS- /MT /c /FoFIX9_C.OBJ FIX9_C.C
if errorlevel 1 exit /b 1
"%VCToolsInstallDir%bin\Hostx86\x86\link.exe" /nologo /OUT:FIX9_C.EXE /SUBSYSTEM:CONSOLE /INCREMENTAL:NO FIX9_C.OBJ
if errorlevel 1 exit /b 1
"%VCToolsInstallDir%bin\Hostx86\x86\dumpbin.exe" /nologo /DISASM:BYTES FIX9_C.OBJ > FIX_RAW.TXT
if errorlevel 1 exit /b 1
"%VCToolsInstallDir%bin\Hostx86\x86\dumpbin.exe" /nologo /RELOCATIONS FIX9_C.OBJ > FIX_REL.TXT
if errorlevel 1 exit /b 1
FIX9_C.EXE global > FIX_G.TXT
if errorlevel 1 exit /b 1
FIX9_C.EXE local > FIX_L.TXT
exit /b %errorlevel%
