@echo off
if exist BUILD.OK del BUILD.OK
masm MUL9.ASM,MUL9.OBJ,MUL9.LST; > ASM.LOG
if errorlevel 1 goto fail
link MUL9.OBJ,MUL9.EXE; > LINK.LOG
if errorlevel 1 goto fail
masm REGTEST.ASM,REGTEST.OBJ,REGTEST.LST; > TESTASM.LOG
if errorlevel 1 goto fail
link REGTEST.OBJ,REGTEST.EXE; > TESTLINK.LOG
if errorlevel 1 goto fail
echo PASS > BUILD.OK
echo Multiplication table and register checks built successfully.
goto end
:fail
echo BUILD FAILED. Read ASM.LOG and TESTASM.LOG.
:end
