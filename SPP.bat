@echo off
cls
echo [101;93mSetPriority.bat v1.0 - by GabrielWB (08/05/2017)[0m
echo This script generates three .reg files to permanently set the CPU priority of specific programs
echo Use at your own risk and discretion. No warranties.
echo:

:: Filling variables with default values (for debugging purposes)
SET process=nothing
SET priority=2
SET priorityName=nothing

:: Create three temporary files and add default registry file header and blank line
(echo Windows Registry Editor Version 5.00 & echo:) > plus.temp
(echo Windows Registry Editor Version 5.00 & echo:) > minus.temp
(echo Windows Registry Editor Version 5.00 & echo:) > wipe.temp

:: Ask user for process name for the first time
:AddProgram
echo [93mSET PROGRAM NAME[0m
echo What is the process name of the program? The correct format is [96mname.exe[0m 
echo Examples are: [1moverwatch.exe[0m / [1mhl2.exe[0m / [1mcactus.exe[0m / [1mRocketLeague.exe[0m 
echo Alternatively, type [96mQ[0m to end the script.
SET /p process=Process name: 
echo:

:: Check if the user has entered Q to end the script
IF /I "%process%" == "Q" (
	GOTO Stop
)

:: Check if the entered process name ends with .exe
if "%process:~-4%" neq ".exe" (
	echo [93mSOMETHING WENT WRONG[0m
	echo [91mERROR:[0m [96m%process%[0m is not a valid process name. A process needs to end with [96m.exe[0m
	pause
	echo.
	goto AddProgram
)

goto CpuPriority

:AddAnotherProgram
:: Ask user for another process
echo [93mSET PROGRAM NAME[0m
echo What is the process name of the program? The correct format is [96mname.exe[0m 
echo Examples are: [1moverwatch.exe[0m / [1mhl2.exe[0m / [1mcactus.exe[0m / [1mRocketLeague.exe[0m 
echo Alternatively, type [96mQ[0m to end the script, or [96mG[0m to generate the registry files.
SET /p process=Process name: 
echo:

:ValidityCheck

:: Check if the user has entered Q to end the script
IF /I "%process%" == "Q" (
	GOTO Stop
)

:: Check if the user has entered G to generate the registry files
IF /I "%process%" == "G" (
	GOTO GenerateFiles
)

:: Check if the entered process name ends with .exe
if "%process:~-4%" neq ".exe" (
	echo [93mSOMETHING WENT WRONG[0m
	echo [91mERROR:[0m [96m%process%[0m is not a valid process name. A process needs to end with [96m.exe[0m
	pause
	echo.
	goto AddAnotherProgram
)

:CpuPriority

:: Ask user for CPU priority, five possible values
:: NOTE: The [1mREALTIME[0m cpu setting cannot be set through the registry and is therefore unavailable.
echo [93mSET CPU PRIORITY[0m
echo At which priority should [96m%process%[0m run? Choose a number between [96m(1 - 5)[0m
echo [1m1. Low[0m / [1m2. Below Normal[0m / [1m3. Normal[0m / [1m4. Above Normal[0m / [1m5. High[0m
choice /c 12345 /n /m "CPU Priority= "
echo:

:: Set priority levels depending on userinput. Values for priority were retreived from CpuPriorityClass documentation
:: Don't ask me why the highest setting is only 3
IF ERRORLEVEL == 5 (
	SET "priorityString=High" 
	SET priority=3
	GOTO CheckInput
)

IF ERRORLEVEL == 4 (
	SET "priorityString=Above Normal" 
	SET priority=6
	GOTO CheckInput
)

IF ERRORLEVEL == 3 (
	SET "priorityString=Normal" 
	SET priority=2
	GOTO CheckInput
)

IF ERRORLEVEL == 2 (
	SET "priorityString=Below Normal" 
	SET priority=5
	GOTO CheckInput
)

IF ERRORLEVEL == 1 (
	SET "priorityString=Low" 
	SET priority=1
	GOTO CheckInput
)

:CheckInput
:: Asking user to doublecheck input and to confirm if correct. If declined, return to AddProgram
echo [93mCONFIRMATION[0m
echo You wish to set the priority of [96m%process%[0m to [96m%priorityString%[0m permanently.
echo Is this correct? [96m(Y/N)[0m
choice /n
echo:

IF ERRORLEVEL == 2 (
	GOTO AddProgram
)

IF ERRORLEVEL == 1 (
	GOTO WriteQueue
)

:WriteQueue
:: Write current program with priority setting to temporary files and append correct path
(echo [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\%process%\PerfOptions]) >> plus.temp
(echo "CpuPriorityClass"=dword:0000000%priority%) >> plus.temp
(echo [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\%process%\PerfOptions]) >> minus.temp
(echo "CpuPriorityClass"=-) >> minus.temp
(echo [-HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\%process%]) >> wipe.temp

:: Ask user if another program needs to be added to the queue. Return to AddProgram if requested
echo [93mPROCESS ADDED TO LIST[0m
echo The key to set [96m%process%[0m to [96m%priorityString%[0m permanently has been added to the batch list.
echo Do you wish to set another program? [96m(Y/N)[0m
choice /n
echo:
IF ERRORLEVEL == 2 GOTO GenerateFiles
IF ERRORLEVEL == 1 GOTO AddAnotherProgram

:GenerateFiles
cls
:: Contents of temporary files are written to .reg files and contents are displayed to user
type plus.temp > SPP_setSettings.reg
type minus.temp > SPP_undoSettings.reg
type wipe.temp > SPP_wipeSettings.reg

echo The following three .reg files have been generated:
echo [32m========================================================================================[0m
echo [92msetPriority_setSettings.reg[0m - To import the settings into your registry
echo [32m----------------------------------------------------------------------------------------[0m
type SPP_setSettings.reg
echo [32m========================================================================================[0m
echo:
echo [33m========================================================================================[0m
echo [93msetPriority_undoSettings.reg[0m - To remove the settings from your registry
echo [33m----------------------------------------------------------------------------------------[0m
type SPP_undoSettings.reg
echo [33m========================================================================================[0m
echo:
echo [31m========================================================================================[0m
echo [91msetPriority_wipeSettings.reg[0m - To remove ALL CREATED KEYS from your registry
echo          [97mWARNING: ONLY USE THIS FILE IF YOU KNOW WHAT YOU ARE DOING![0m
echo [97mThis file will delete ALL created keys and does NOT account for any pre-existing keys![0m
echo [31m----------------------------------------------------------------------------------------[0m
type SPP_wipeSettings.reg
echo [31m========================================================================================[0m
:Stop
:: Cleanup. Deleting temporary files and notify user of ended script
del plus.temp minus.temp wipe.temp
echo [96mThe script has ended[0m
pause
exit
