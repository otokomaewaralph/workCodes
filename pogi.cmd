@echo OFF
REM Author: Ralph T. Llaguno (ralph.llaguno@paymaya.com)
REM Purpose: Automate tasks to back-up VISAIN EP REPORTS
REM Updated: 07-02-2017
cls

REM ********************GLOBAL VARIABLES*********************
set sysDate=%date:~4,2%-%date:~7,2%-%date:~10,4%
set setDate=%4-%2-%3
set mainDir=C:\04-13-17(Automate_windows_scripts)v2
set logDir=%mainDir%\logs
set script_dir=%mainDir%\scripts

set IN_srcDir="C:\EP40\C400784\REPORTS\INCOMING"
set IN_dir1="C:\EP40\C400784\ACQUIRING\INCOMING\REPORTS\%4\%2\%3"
set IN_bin_ardef="C:\EP40\C400784\ACQUIRING\BIN_and_ARDEF_Files\%4\%2\%3"

set OUT_srcDir_EP_REPORT="C:\EP40\C400784\REPORTS\OUTGOING"
set OUT_srcDir_EP_OUT="C:\EP40\C400784\OUTGOING"
set OUT_dir1="C:\EP40\C400784\ACQUIRING\OUTGOING\%4\%2\%3"
set OUT_dir1_EP_REPORT="%OUT_dir1%\EP_REPORT"
set OUT_dir1_EP_OUT="%OUT_dir1%\EP_OUT"

REM ********************************************************

echo "Script triggered, Please wait ..." 
echo ___________________________________________________ >> "%logDir%\%setDate%.log" 
echo ####################################################>> "%logDir%\%setDate%.log" 
echo SCRIPT START TIME: %date% %time%
echo SCRIPT START TIME: %date% %time% >> "%logDir%\%setDate%.log" 

REM **************CHECKING SCRIPT**************
if exist C:\04-13-17(Automate_windows_scripts)v2\scripts\zuip.vbs (echo INFO: Script found) else (
echo ERROR: Script zuip.vbs is missing!
exit /b 
)


REM **************VALIDATING PARAMETERS**************
if [%1]==[] (echo ERROR: No 1st parameter found! 
goto error_parameters )
if [%2]==[] (echo ERROR: No 2nd parameter found!
goto error_parameters ) 
if [%3]==[] (echo ERROR: No 3rd parameter found!
goto error_parameters ) 
if [%4]==[] (echo ERROR: No 4th parameter found!
goto error_parameters ) 

echo INFO: Parameters %1 %2/%3/%4 has been Setted...
echo INFO: Parameters %1 %2/%3/%4 has been Setted... >> "%logDir%\%setDate%.log"

REM **************VALIDATING IF FOR VISA IN/OUT**************
if %1==VISAIN (echo INFO: BACKUP VISAIN EP Reports ongoing ...
goto VISAIN)
if %1==VISAOUT (echo INFO: BACKUP VISAOUT EP Reports ongoing ...
goto VISAOUT) 

echo ERROR: Invalid 1st Parameter. Please re-run script and Enter (VISAIN or VISAOUT) for 1st parameter.
echo ERROR: Invalid 1st Parameter. Please re-run script and Enter (VISAIN or VISAOUT) for 1st parameter. >> "%logDir%\%setDate%.log"
pause
exit /b

:VISAIN
REM **************SETTING DIRECTORY for UN-MAPPED DRIVE**************
pushd \\tsclient\Y\INCOMING\
set IN_dir2="Z:\INCOMING\%4\%2\%3"

echo INFO: VISAIN BACK-UP Triggered ... >> "%logDir%\%setDate%.log"
REM **************CREATING DIRECTORY**************
if exist %IN_dir1% (echo ERROR: Directory %IN_dir1% exists! 
goto error_logs 
) >> "%logDir%\%setDate%.log" else (mkdir %IN_dir1% 
echo INFO: Directory created: %IN_dir1%
echo INFO: Directory created: %IN_dir1%  >> "%logDir%\%setDate%.log")

if exist %IN_dir2% (echo INFO: Directory %IN_dir2% exists! 
goto error_logs 
) >> "%logDir%\%setDate%.log" else (mkdir %IN_dir2%  
echo INFO: Directory created: %IN_dir2%
echo INFO: Directory created: %IN_dir2% >> "%logDir%\%setDate%.log")

REM **************COPYING FILES to BACK-UP DIRECTORY**************
xcopy %IN_srcDir% %IN_dir1% /E /D:%sysDate% >> "%logDir%\%setDate%.log"
echo INFO: Files copied to: %IN_dir1%
ROBOCOPY %IN_dir1% %IN_dir1% /S /MOVE

REM **************COMPRESSING BACK-UP FILES**************
cscript %script_dir%\zuip.vbs C "%IN_dir1%" "%IN_dir1%.zip" >> "%logDir%\%setDate%.log"
echo INFO: Compressed directory: %IN_dir1%
rmdir %IN_dir1% /s /q
echo INFO: Deleted: %IN_dir1%
echo INFO: Deleted: %IN_dir1% >> "%logDir%\%setDate%.log"

REM **************COPYING FILES to SHARED DIRECTORY**************
xcopy /E %IN_dir1%.zip %IN_dir2% >> "%logDir%\%setDate%.log"
echo INFO: Files copied to: %IN_dir2%
popd
REM **************ENCRYPTING FILES**************
gpg -r visaonly --encrypt "%IN_dir1%.zip"
echo INFO: Encrypted: %IN_dir1%.zip
echo INFO: Encrypted: %IN_dir1%.zip >> "%logDir%\%setDate%.log"
del /f %IN_dir1%.zip
echo INFO: Deleted: %IN_dir1%.zip
echo INFO: Deleted: %IN_dir1%.zip >> "%logDir%\%setDate%.log"

REM **************ENCRYPTION for BIN and ARDEF**************
REM **************COMPRESSING BACK-UP FILES**************
cscript %script_dir%\zuip.vbs C "%IN_bin_ardef%" "%IN_bin_ardef%.zip" 
echo INFO: Compressed directory: %IN_bin_ardef%

rmdir %IN_bin_ardef% /s /q
echo INFO: Deleted: %IN_bin_ardef%

REM **************ENCRYPTING FILES**************
gpg -r visaonly --encrypt "%IN_bin_ardef%.zip"
echo INFO: Encrypted: %IN_bin_ardef%.zip
del /f %IN_bin_ardef%.zip
echo INFO: Deleted: %IN_bin_ardef%.zip



echo INFO: Return Code = 0
echo SCRIPT END TIME: %date% %time% 
echo INFO: Return Code = 0 >> "%logDir%\%setDate%.log"
echo SCRIPT END TIME: %date% %time% >> "%logDir%\%setDate%.log"
pause
exit /b

:VISAOUT

REM **************SETTING DIRECTORY for UN-MAPPED DRIVE**************
pushd \\tsclient\Y\OUTGOING\
set OUT_dir2="Z:\OUTGOING\%4\%2\%3"
REM set OUT_dir2_EP_REPORT="%OUT_dir2%\EP_REPORT"
REM set OUT_dir2_EP_OUT="%OUT_dir2%\EP_OUT"

echo INFO: VISAOUT BACK-UP Triggered ... >> "%logDir%\%setDate%.log"
REM **************CREATING DIRECTORY**************
if exist %OUT_dir1% (echo ERROR: Directory %OUT_dir1% exists! 
goto error_logs 
) >> "%logDir%\%setDate%.log"
mkdir %OUT_dir1_EP_REPORT%  
echo INFO: Directory created: %OUT_dir1_EP_REPORT%
echo INFO: Directory created: %OUT_dir1_EP_REPORT%  >> "%logDir%\%setDate%.log"
mkdir %OUT_dir1_EP_OUT%  
echo INFO: Directory created: %OUT_dir1_EP_OUT%
echo INFO: Directory created: %OUT_dir1_EP_OUT%  >> "%logDir%\%setDate%.log"

if exist %OUT_dir2% (echo ERROR: Directory %OUT_dir2% exists! 
goto error_logs 
) >> "%logDir%\%setDate%.log" else (mkdir %OUT_dir2%
echo INFO: Directory created: %OUT_dir2%
echo INFO: Directory created: %OUT_dir2% >> "%logDir%\%setDate%.log")

REM **************COPYING FILES to BACK-UP DIRECTORY**************
xcopy %OUT_srcDir_EP_REPORT% %OUT_dir1_EP_REPORT% /E /D:%sysDate% >> "%logDir%\%setDate%.log"
echo INFO: Files copied to: %OUT_dir1_EP_REPORT%
ROBOCOPY %OUT_dir1_EP_REPORT% %OUT_dir1_EP_REPORT% /S /MOVE 

xcopy %OUT_srcDir_EP_OUT% %OUT_dir1_EP_OUT% /E /D:%sysDate% >> "%logDir%\%setDate%.log"
echo INFO: Files copied to: %OUT_dir1_EP_OUT%
ROBOCOPY %OUT_dir1_EP_OUT% %OUT_dir1_EP_OUT% /S /MOVE 


REM **************COMPRESSING BACK-UP FILES**************
cscript %script_dir%\zuip.vbs C "%OUT_dir1%" "%OUT_dir1%.zip" >> "%logDir%\%setDate%.log"
echo INFO: Compressed directory: %OUT_dir1%
REM echo WARNING: Deleting back-up folder. Kindly Enter: "Y"
REM rd /s %OUT_dir1%
rmdir %OUT_dir1% /s /q
echo INFO: Deleted: %OUT_dir1%
echo INFO: Deleted: %OUT_dir1% >> "%logDir%\%setDate%.log"

REM **************COPYING FILES to SHARED DIRECTORY**************
xcopy /E %OUT_dir1%.zip %OUT_dir2% >> "%logDir%\%setDate%.log"
echo INFO: Files copied to: %OUT_dir2%
popd

REM **************ENCRYPTING FILES**************
gpg -r visaonly --encrypt "%OUT_dir1%.zip"
echo INFO: Encrypted: %OUT_dir1%.zip
echo INFO: Encrypted: %OUT_dir1%.zip >> "%logDir%\%setDate%.log"
del /f %OUT_dir1%.zip
echo INFO: Deleted: %OUT_dir1%.zip
echo INFO: Deleted: %OUT_dir1%.zip >> "%logDir%\%setDate%.log"

echo INFO: Return Code = 0
echo SCRIPT END TIME: %date% %time% 
echo INFO: Return Code = 0 >> "%logDir%\%setDate%.log"
echo SCRIPT END TIME: %date% %time% >> "%logDir%\%setDate%.log"
pause
exit /b

:error_parameters
echo ERROR: Missing parameters/. Please re-run the script and follow the correct syntax.
echo DEBUG: For example: pogi VISAIN 05 05 2025
pause 
exit /b


:error_logs
echo Error has been encountered!
echo Please see logs at %logDir%\%setDate%.log
pause

