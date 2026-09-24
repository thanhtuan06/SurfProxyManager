@echo off
rem Tu chay ngam Surf Proxy Manager moi khi dang nhap Windows (khong can quyen Admin)
set "SPM_DIR=%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$l=[Environment]::GetFolderPath('Startup')+'\SurfProxyManager.lnk';$s=(New-Object -ComObject WScript.Shell).CreateShortcut($l);$s.TargetPath='wscript.exe';$s.Arguments='\"'+$env:SPM_DIR+'start_hidden.vbs\" /silent';$s.WorkingDirectory=$env:SPM_DIR;$s.Save();Write-Host ('Da tao: '+$l)"
pause
