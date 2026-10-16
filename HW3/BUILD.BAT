@echo off
masm SUM_REG.ASM,SUM_REG.OBJ,SUM_REG.LST; > REGASM.LOG
if errorlevel 1 goto fail
link SUM_REG.OBJ,SUM_REG.EXE; > REGLINK.LOG
if errorlevel 1 goto fail
masm SUM_DATA.ASM,SUM_DATA.OBJ,SUM_DATA.LST; > DATAASM.LOG
if errorlevel 1 goto fail
link SUM_DATA.OBJ,SUM_DATA.EXE; > DATALINK.LOG
if errorlevel 1 goto fail
masm SUM_STK.ASM,SUM_STK.OBJ,SUM_STK.LST; > STKASM.LOG
if errorlevel 1 goto fail
link SUM_STK.OBJ,SUM_STK.EXE; > STKLINK.LOG
if errorlevel 1 goto fail
masm SUM_IN.ASM,SUM_IN.OBJ,SUM_IN.LST; > INASM.LOG
if errorlevel 1 goto fail
link SUM_IN.OBJ,SUM_IN.EXE; > INLINK.LOG
if errorlevel 1 goto fail
echo PASS > BUILD.OK
echo All four DOS programs built successfully.
goto end
:fail
if exist BUILD.OK del BUILD.OK
echo BUILD FAILED. Read the ASM and LINK logs.
:end
