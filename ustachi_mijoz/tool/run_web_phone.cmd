@echo off
setlocal
rem Web ilovani telefon o'lchamidagi Chrome "app" oynasida ishga tushiradi
rem (address bar yo'q, emulyatorga o'xshaydi).
rem Konsolda: r = hot reload, R = hot restart, q = chiqish.
rem "run_web_phone.cmd reset" - saqlangan brauzer profilini tozalaydi.

set "APP_DIR=%~dp0.."
set "PROFILE=%LOCALAPPDATA%\ustachi_web_phone"
set "PORT=5555"
set "WIN_W=430"
set "WIN_H=728"
set "UA=Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Mobile Safari/537.36"

if /i "%~1"=="reset" rmdir /s /q "%PROFILE%" 2>nul

rem Chrome ba'zan saqlangan oyna o'lchamini tiklaydi - kafolat uchun majburan o'lchaymiz.
start "" /min powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0resize_web_phone.ps1" -Match "ustachi_web_phone" -Width %WIN_W% -Height %WIN_H% -X 60 -Y 0

rem Standart manzil 10.0.2.2 — bu ANDROID EMULYATORI manzili, brauzerga
rem yetib bormaydi (2026-09-19: ilova serverga ulana olmay qolgandi).
rem Webda lokal backend 127.0.0.1 bo'ladi.
set "LOCAL_API=http://127.0.0.1:8000"

cd /d "%APP_DIR%"
flutter run -d chrome --web-port=%PORT% ^
  --dart-define=API_BASE_URL=%LOCAL_API% ^
  --dart-define=SOCKET_BASE_URL=%LOCAL_API% ^
  --web-browser-flag="--user-data-dir=%PROFILE%" ^
  --web-browser-flag="--app=http://localhost:%PORT%" ^
  --web-browser-flag="--window-size=%WIN_W%,%WIN_H%" ^
  --web-browser-flag="--window-position=60,0" ^
  --web-browser-flag="--touch-events=enabled" ^
  --web-browser-flag="--user-agent=%UA%"

endlocal
