Dim oShell
Set oShell=WScript.CreateObject("WSCript.shell")
oShell.run "cmd /c %DMBIN%\dmlic.exe -l -c -p 1", 0
Set oShell = Nothing
