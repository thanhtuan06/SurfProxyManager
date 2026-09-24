@echo off
rem Chay co cua so console de xem log truc tiep (dung khi can go loi)
cd /d "%~dp0"
where py >nul 2>nul && (py -3 app.py --open) || (python app.py --open)
pause
