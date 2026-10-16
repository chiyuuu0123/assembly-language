@echo off
if exist BUILD.OK del BUILD.OK
call BUILD.BAT
if not exist BUILD.OK goto fail
if not exist RUNTEST.BAT goto fail
call RUNTEST.BAT
:fail
echo Verification could not start. Check build logs and run CHECK.py prepare.
echo FAILED > DONE.TXT
exit
