Dim oShell
Set oShell=WScript.CreateObject("WSCript.shell")
oShell.run "cmd /c %DMGRSRV%", 0
oShell.run "cmd /c %DMBIN%\dmmonitor %DMAPP%\config\mon2_4.ini", 0
oShell.run "cmd /c %DMAPP%\config\evvi2.cmd %DMAPP%\config\evview2_4.ini", 0
oShell.run "cmd /c %DMAPP%\monitor\pass\logout.cmd", 0
Set oShell = Nothing
