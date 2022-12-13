# original! set ServerName=PC32-FS-RESERVE
# temporary set ServerName=PC34-FS-OILP34
set ServerName=PC34-FS-OILP34

net use s: /DELETE /Y
subst s: /d

if %ServerName%==%ComputerName% (
  subst s: \prim_fi_data
) else (
  net use s: \\%ServerName%\prim_fi_data /user:prim prim /persistent:no /Y
)

/Dmon/bin/dmeventview %1 %2 %3 %4 %5 %6 %7 %8
