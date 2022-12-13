Dim oShell
Set oShell=WScript.CreateObject("WSCript.shell")
oShell.run "cmd /c %DMBIN%\dmnetsrv.exe \prim_fi\netserver\Netserver_node31.ini", 0
Set oShell = Nothing
