@echo off
rem Oyna o'lchagichni fonda ishga tushiradi va darhol qaytadi.
rem %1 = chrome profil nomi (moslik uchun), %2 = kenglik, %3 = balandlik, %4 = X, %5 = Y
set "MATCH=%~1"
if "%MATCH%"=="" set "MATCH=ustachi_web_phone"
set "W=%~2"
if "%W%"=="" set "W=430"
set "H=%~3"
if "%H%"=="" set "H=728"
set "X=%~4"
if "%X%"=="" set "X=60"
set "Y=%~5"
if "%Y%"=="" set "Y=0"
start "" /min powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0resize_web_phone.ps1" -Match "%MATCH%" -Width %W% -Height %H% -X %X% -Y %Y%
