@echo off
if exist DONE.TXT del DONE.TXT
call BUILD.BAT
if not exist BUILD.OK goto fail
call RUNTEST.BAT
:fail
echo FAILED > DONE.TXT
exit
