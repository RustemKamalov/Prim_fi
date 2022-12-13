C:\prim_fi\START\Start_Dmon_License.vbs
sleep 2
C:\prim_fi\START\Start_dmnetserver32.vbs
sleep 2
start /b %DMGRSRV%
sleep 2
c:\Dmon\utils\dmwinsrvutil2.exe -n -q
sleep 3
start /b C:\Dmon\bin\MMG\exec.exe C:\prim_fi\bin.win\server2_start.bat
