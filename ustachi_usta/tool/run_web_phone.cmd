@echo off
setlocal
rem Usta ilovasini telefon o'lchamidagi Chrome "app" oynasida ishga tushiradi.
rem Mijoz ilovasi 5555-portda, usta 5558-portda - ikkalasi birga tursin.
rem Konsolda: r = hot reload, R = hot restart, q = chiqish.

set "APP_DIR=%~dp0.."
set "PROFILE=%LOCALAPPDATA%\ustachi_usta_web_phone"
set "PORT=5558"
set "WIN_W=430"
set "WIN_H=728"
set "UA=Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Mobile Safari/537.36"

rem Lokal backend - webda 127.0.0.1 (10.0.2.2 Android emulyatori manzili).
set "LOCAL_API=http://127.0.0.1:8000"

cd /d "%APP_DIR%"
flutter run -d chrome --web-port=%PORT% ^
  --dart-define=API_BASE_URL=%LOCAL_API% ^
  --dart-define=SOCKET_BASE_URL=%LOCAL_API% ^
  --web-browser-flag="--user-data-dir=%PROFILE%" ^
  --web-browser-flag="--app=http://localhost:%PORT%" ^
  --web-browser-flag="--window-size=%WIN_W%,%WIN_H%" ^
  --web-browser-flag="--window-position=520,0" ^
  --web-browser-flag="--touch-events=enabled" ^
  --web-browser-flag="--user-agent=%UA%"

endlocal
