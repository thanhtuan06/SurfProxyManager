@echo off
rem Dong goi thanh SurfProxyManager.exe (khong can cai Python tren may chay)
cd /d "%~dp0"
py -3 -m pip install --upgrade pyinstaller || goto :err
py -3 -m PyInstaller --noconfirm --noconsole --onefile --name SurfProxyManager --add-data "web;web" app.py || goto :err
copy /y dist\SurfProxyManager.exe . >nul
echo Xong: SurfProxyManager.exe (dat cung thu muc voi bin\ va data\)
pause
exit /b 0
:err
echo Dong goi that bai.
pause
