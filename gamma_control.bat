@echo off
title Gamma Control
setlocal enabledelayedexpansion

:menu
cls
echo ============================================
echo           SCREEN GAMMA CONTROL
echo         (Primary Monitor Only)
echo ============================================
echo.
echo  [1] Increase Gamma (Brighter - 1.2)
echo  [2] Decrease Gamma (Darker - 0.8)
echo  [3] Slightly Brighter (1.1)
echo  [4] Slightly Darker (0.9)
echo  [5] Set Custom Gamma (0.5 - 2.0)
echo  [6] Reset to Default (1.0)
echo  [7] Exit
echo.
echo ============================================
echo.
set /p choice="Enter your choice (1-7): "

if "%choice%"=="1" set "gval=1.2" & goto apply
if "%choice%"=="2" set "gval=0.8" & goto apply
if "%choice%"=="3" set "gval=1.1" & goto apply
if "%choice%"=="4" set "gval=0.9" & goto apply
if "%choice%"=="5" goto custom
if "%choice%"=="6" set "gval=1.0" & goto apply
if "%choice%"=="7" goto exitprog
goto menu

:custom
echo.
set /p gval="Enter gamma value (0.5 to 2.0, default is 1.0): "
goto apply

:apply
echo.
powershell -ExecutionPolicy Bypass -File "%~dp0SetGamma.ps1" -gamma %gval%
echo.
pause
goto menu

:exitprog
echo.
echo Resetting gamma to default before exit...
powershell -ExecutionPolicy Bypass -File "%~dp0SetGamma.ps1" -gamma 1.0
echo.
echo Done. Goodbye!
timeout /t 2 >nul
exit /b
