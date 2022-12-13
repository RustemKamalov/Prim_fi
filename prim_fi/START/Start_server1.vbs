Dim oShell
Set oShell=WScript.CreateObject("WSCript.shell")
oShell.run "cmd /c %DMGRSRV%", 0
oShell.run "cmd /c %DMBIN%\dmserver.exe \prim_fi\config\server1.ini", 0
Set oShell = Nothing
