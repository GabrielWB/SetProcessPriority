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

:: Create three temporary files and add .reg file header and blank line
(echo Windows Registry Editor Version 5.00 & echo:) > plus.temp
(echo Windows Registry Editor Version 5.00 & echo:) > minus.temp
(echo Windows Registry Editor Version 5.00 & echo:) > wipe.temp

:: Ask user for process name
:AddProgram
echo [93mSET PROGRAM NAME[0m
echo What is the process name of the program? The correct format is [1mname.exe[0m 
echo Examples are: [1moverwatch.exe[0m / [1mhl2.exe[0m / [1mcactus.exe[0m / [1mRocketLeague.exe[0m 
SET /p process=
echo:

:: Ask user for CPU priority, five possible values
:: NOTE: Realtime cpu setting cannot be set through the registry and is therefore unavailable.
echo [93mSET CPU PRIORITY[0m
echo At which priority should [96m%process%[0m run? Valid levels are:
echo [1m1. Low[0m / [1m2. Below Normal[0m / [1m3. Normal[0m / [1m4. Above Normal[0m / [1m5. High[0m
choice /c 12345 /n /m "CPU Priority="
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
echo You wish to set the priority of [96m%process%[0m to [96m%priorityString%[0m permanently.
echo Is this correct? [1m(Y/N)[0m
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
echo Adding [96m%process%[0m set to [96m%priorityString%[0m to batch list.
echo Do you wish to set another program? [1m(Y/N)[0m
choice /n
echo:
IF ERRORLEVEL == 2 GOTO GenerateFiles
IF ERRORLEVEL == 1 GOTO AddProgram

:GenerateFiles
:: Contents of temporary files are written to .reg files and contents are displayed to user
type plus.temp > SPP_setSettings.reg
type minus.temp > SPP_undoSettings.reg
type wipe.temp > SPP_wipeSettings.reg

echo The following three .reg files have been generated:
echo [92msetPriority_setSettings.reg[0m - To import the settings into your registry
echo [32m========================================================================================[0m
type SPP_setSettings.reg
echo [32m========================================================================================[0m
echo:
echo [93msetPriority_undoSettings.reg[0m - To remove the settings from your registry
echo [33m========================================================================================[0m
type SPP_undoSettings.reg
echo [33m========================================================================================[0m
echo:
echo [91msetPriority_wipeSettings.reg[0m - To remove ALL CREATED KEYS from your registry
echo [101;97mWARNING: ONLY USE THIS FILE IF YOU KNOW WHAT YOU ARE DOING![0m 
echo [91mThis file will delete all created keys and does NOT account for any pre-existing keys![0m
echo [31m========================================================================================[0m
type SPP_wipeSettings.reg
echo [31m========================================================================================[0m
:Stop
:: Cleanup. Deleting temporary files and notify user of ended script
del plus.temp minus.temp wipe.temp
echo [96mThe script has ended[0m
pause
exit
