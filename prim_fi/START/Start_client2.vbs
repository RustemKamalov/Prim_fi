Dim oShell
Set oShell=WScript.CreateObject("WSCript.shell")
oShell.run "cmd /c %DMGRSRV%", 0
oShell.run "cmd /c %DMBIN%\dmmonitor %DMAPP%\config\mon1_2.ini", 0
oShell.run "cmd /c %DMAPP%\config\evvi1.cmd %DMAPP%\config\evview1_2.ini", 0
Set oShell = Nothing
