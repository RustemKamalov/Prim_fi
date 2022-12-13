# temporary fake
set ServerName=PC31-FS-MASTER

# temporary fake
# set ServerName=PC32-FS-RESERVE

net use s: /DELETE /Y
subst s: /d

if %ServerName%==%ComputerName% (
  subst s: \prim_fi_data
) else (
  net use s: \\%ServerName%\prim_fi_data /user:prim prim /persistent:no /Y
)

/Dmon/bin/dmeventview %1 %2 %3 %4 %5 %6 %7 %8
