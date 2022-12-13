#!/bin/ksh

#   s/Fi2_GF121_14/Fi2_GF588___/g
#   s/Fi2_GF121_15/Fi2_GF589___/g
#   s/Fi2_GF4A____/Fi2_GF381___/g
#   s/Fi2_GF4B____/Fi2_GF386___/g
#   s/Fi2_GF4D____/Fi2_GF383___/g
#   s/Fi2_GF4E____/Fi2_GF388___/g
#   s/Fi2_GF4G____/Fi2_GF387___/g
#   s/Fi2_GF4I____/Fi2_GF385___/g
#   s/Fi2_GF4K____/Fi2_GF390___/g
#   s/Fi2_GF4V____/Fi2_GF382___/g
#   s/Fi2_GF4Z____/Fi2_GF389___/g
#   s/Fi2_GF4ZS___/Fi2_GF384___/g

search="Fi2_GF121_14|\
Fi2_GF121_15|\
Fi2_GF4A____|\
Fi2_GF4B____|\
Fi2_GF4D____|\
Fi2_GF4E____|\
Fi2_GF4G____|\
Fi2_GF4I____|\
Fi2_GF4K____|\
Fi2_GF4V____|\
Fi2_GF4Z____|\
Fi2_GF4ZS___"

ch_scr='s/Fi2_GF121_14/Fi2_GF588___/g
        s/Fi2_GF121_15/Fi2_GF589___/g
        s/Fi2_GF4A____/Fi2_GF381___/g
        s/Fi2_GF4B____/Fi2_GF386___/g
        s/Fi2_GF4D____/Fi2_GF383___/g
        s/Fi2_GF4E____/Fi2_GF388___/g
        s/Fi2_GF4G____/Fi2_GF387___/g
        s/Fi2_GF4I____/Fi2_GF385___/g
        s/Fi2_GF4K____/Fi2_GF390___/g
        s/Fi2_GF4V____/Fi2_GF382___/g
        s/Fi2_GF4Z____/Fi2_GF389___/g
        s/Fi2_GF4ZS___/Fi2_GF384___/g'

for i in $(find /prim_fi/monitor/pict -type f)
do

#logger  file=$(echo $i | grep 'rpt')
#  file=$(file $i | grep ' text' | awk '{sub(/:/,"",$1); print $1}')
#text files   file=$(file $i | grep ' text' | sed 's/:.*$//' | grep -v '.ori$')
   file=$(file $i | grep ' text' | sed 's/:.*$//' | grep -v '.ori$')

  if [ "$file" != "" ]
  then
#    echo $file nem ures
    if grep -q -E "$search" "$file"
    then
#      echo found search in file "$file" "\a"
			echo "Convert $file ?      <Y/N>":
			read resp
      case $resp in
        y|Y)
            if test -f $file.ori
            then
              echo $file.ori exists, not converting
            else
              echo converting $file
              cp $file $file.ori
              sed "$ch_scr" $file > temp
              mv temp $file
              #if [ "$(ls -F $file.ori | grep '*')" != "" ]
              #then
              #  chmod a+x $file
              #fi
            fi

            ;;
      esac

    fi
  fi

done
