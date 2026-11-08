@echo off
if exist BUILD.OK del BUILD.OK
masm FIBRUN.ASM,FIBRUN.OBJ,FIBRUN.LST; > ASM.LOG
if errorlevel 1 goto fail
link FIBRUN.OBJ,FIBRUN.EXE; > LINK.LOG
if errorlevel 1 goto fail
masm TRACE.ASM,TRACE.OBJ,TRACE.LST; > TRCASM.LOG
if errorlevel 1 goto fail
link TRACE.OBJ,TRACE.EXE; > TRCLINK.LOG
if errorlevel 1 goto fail
echo PASS > BUILD.OK
echo Fibonacci and debugger driver built successfully.
goto end
:fail
echo BUILD FAILED. See ASM.LOG and TRCASM.LOG.
:end
