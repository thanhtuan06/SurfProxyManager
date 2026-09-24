' Chay Surf Proxy Manager ngam (khong cua so). Tham so /silent: khong mo trinh duyet.
Set sh = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
dir = fso.GetParentFolderName(WScript.ScriptFullName)
sh.CurrentDirectory = dir
openArg = " --open"
If WScript.Arguments.Count > 0 Then
  If LCase(WScript.Arguments(0)) = "/silent" Then openArg = ""
End If
If fso.FileExists(dir & "\SurfProxyManager.exe") Then
  sh.Run """" & dir & "\SurfProxyManager.exe""" & openArg, 0, False
  WScript.Quit
End If
On Error Resume Next
sh.Run "pyw -3 """ & dir & "\app.py""" & openArg, 0, False
If Err.Number <> 0 Then
  Err.Clear
  sh.Run "pythonw """ & dir & "\app.py""" & openArg, 0, False
  If Err.Number <> 0 Then
    MsgBox "Khong tim thay Python. Hay cai Python 3 tu python.org (tick 'Add python.exe to PATH').", 16, "Surf Proxy Manager"
  End If
End If
