@echo off
setlocal
chcp 65001>nul

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Нужны права Администратора
    echo Нажми Enter, и я их запрошу...
    pause > nul
    powershell -Command "Start-Process '%~f0' -Verb runAs"
    echo Спасибо!
    exit /b
)

if not exist "C:\Program Files\MSP_PerformanceSender" mkdir "C:\Program Files\MSP_PerformanceSender"

curl -L "https://raw.githubusercontent.com/MetasoftPro/MSP_PerformanceSender/refs/heads/main/LastVersion.txt" -o "C:\Program Files\MSP_PerformanceSender\OnlineVersion.txt" -s

set "PERFORMANCE_MONITOR_ONLINE_VERSION=-1"
for /f "usebackq delims=" %%A in ("C:\Program Files\MSP_PerformanceSender\OnlineVersion.txt") do (
    set "PERFORMANCE_MONITOR_ONLINE_VERSION=%%A"
    goto :done1
)
:done1
del "C:\Program Files\MSP_PerformanceSender\OnlineVersion.txt"



set "PERFORMANCE_MONITOR_THIS_VERSION=-1"
if exist "C:\Program Files\MSP_PerformanceSender\ThisVersion.txt" (
    for /f "usebackq delims=" %%A in ("C:\Program Files\MSP_PerformanceSender\ThisVersion.txt") do (
        set "PERFORMANCE_MONITOR_THIS_VERSION=%%A"
        goto :done2
    )
    :done2
    echo. >nul
)

set "PERFORMANCE_MONITOR_NEEDS_UPDATE=0"



if %PERFORMANCE_MONITOR_ONLINE_VERSION% gtr %PERFORMANCE_MONITOR_THIS_VERSION% (
    set PERFORMANCE_MONITOR_NEEDS_UPDATE=1
)
if %PERFORMANCE_MONITOR_THIS_VERSION% equ -1 (
    set PERFORMANCE_MONITOR_NEEDS_UPDATE=1
)

if %PERFORMANCE_MONITOR_NEEDS_UPDATE% neq 1 (
    goto :noupdatepm
)

if exist "C:\Program Files\MSP_PerformanceSender\MSP_PerformanceSender.exe" del "C:\Program Files\MSP_PerformanceSender\MSP_PerformanceSender.exe"

echo Качаю MSP_PerformanceSender.exe...
curl -L "https://github.com/MetasoftPro/MSP_PerformanceSender/raw/refs/heads/main/MSP_PerformanceSender.exe" -o "C:\Program Files\MSP_PerformanceSender\MSP_PerformanceSender.exe" -s

echo %PERFORMANCE_MONITOR_ONLINE_VERSION% > "C:\Program Files\MSP_PerformanceSender\ThisVersion.txt"

goto :upddone
:noupdatepm

echo Версия самая свежая!

:upddone

echo wss://pc:zFLVjVU8sozO18q@gci-metrika.metasoftpro.ru/server > "C:\Program Files\MSP_PerformanceSender\WhereToSend.txt"

reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" /v "MSP_PerformanceSender" /t REG_SZ /d "\"C:\Program Files\MSP_PerformanceSender\MSP_PerformanceSender.exe\"" /f

echo Запускаю MSP_PerformanceSender.exe...
start "" "C:\Program Files\MSP_PerformanceSender\MSP_PerformanceSender.exe"

endlocal
