C:\prim_fi\START\Start_Dmon_Licensex.vbs
sleep 2
C:\prim_fi\START\Start_dmnetserver35.vbs
sleep 2
start /b %DMGRSRV%
sleep 2
c:\Dmon\utils\dmwinsrvutil2.exe -n -q
sleep 2
C:\prim_fi\monitor\pass\logout.cmd
