#!/bin/bash
echo "Converting Pictures ..."

rm tmp 2>/dev/null

dirs=`find $DMAPP/monitor/pict -type d`
let "sum=0"

for dir in $dirs
do
    cd $dir
#    echo $dir
#    files=`find -name '*.pict' | sed 's/.pict//'`
    files=`ls *.pict | sed 's/.pict//'`
    for file in $files
		do
#			echo $file
			if test -s $file.txt
			then
				sh $DMAPP/monitor/utils/epn.sh $file.txt > $file.dnw 2> $file.mod
			  if test -s $file.mod
			  then
				  echo "Found \"1/0\" in dynamic of picture \"$file.pict\""
					echo "  in directory \"$dir\""
					echo

					cat $file.mod > $file.conv
					rm -f tmp.pict
					rm -f tmp.txt
					cp $file.pict tmp.pict
					$DMBIN/../utils/dmpicttotxt tmp.pict tmp.new 2>> $file.conv
					if test $? -ne 0
					then
						echo "Errors during dmon picture to txt conversion at \"1/0\" converted file!"
						echo -e "  picture: \"$file.pict\""
						echo -e "  directory: \"$dir\""
						echo -e "  See \"$file.conv\" in the directory of the picture!"
					fi
					cat tmp.new | awk '
					{
						if( match( $0, /^[ \t]*FMT[ \t]*:[ \t]*fmt[ \t]*=[ \t]*dt[ \t]*[\r]?$/ ) ) {
							$0=gensub( /(^[ \t]*FMT[ \t]*:[ \t]*fmt[ \t]*=[ \t]*d)t([ \t]*[\r]?$)/,"\\1\\2" , 1 , $0 )
						}
            if( match( $0, /^[ \t]*FMT[ \t]*:[ \t]*fmt[ \t]*=[ \t]*<p/ ) ) {
							next
						}
						if( match( $0, /^[ \t]*file[ \t]*:/ ) ) {
							next
						}
						print $0
					}	' > tmp.txt


  				sh $DMAPP/monitor/utils/used.sh tmp.txt > used.obj
  				sh $DMAPP/monitor/utils/epn.sh $file.txt used.obj > $file.dnw 2> $file.mod
					rm -f used.obj
					ob=`cat $file.mod | wc -l`
					let "sum=sum+$ob"

					mv tmp.txt old.txt
					sh $DMAPP/monitor/utils/depn.sh $file.mod old.txt > tmp.txt

					rm -f tmp.pict
					$DMBIN/../utils/dmtxttopict tmp.txt tmp.pict 2>>  $file.conv
					if test $? -ne 0
					then
						echo "Errors during dmon txt to picture conversion at \"1/0\" converted file!"
						echo -e "  picture: \"$file.pict\""
						echo -e "  directory: \"$dir\""
						echo -e "  See \"$file.conv\" in the directory of the picture!"
					fi
					if test -s tmp.pict
					then
							cp $file.pict $file.pict.old
    					mv tmp.pict $file.pict
#    					rm -f $file.mod
					else
  				  echo "Error: dmon has no affinity to work..."
						echo -e "  picture: \"$file.pict\""
						echo -e "  directory: \"$dir\""
						echo -e "  See \"$file.conv\" in the directory of the picture!"
						echo -e "\n  Number of found and corrected \"1/0\" objs: $ob\n"
						exit
					fi


					mv $file.txt $file.txt.old
					mv $file.dnw $file.txt

          $DMBIN/dmmonedit -i ./$file $DMAPP/config/monx.ini
					if test $? -ne 0
					then
						echo "Error: Dmon picture compilation failed at \"1/0\" converted file!"
						echo -e "  picture: \"$file.pict\""
						echo -e "  directory: \"$dir\""
#	  				mv $file.txt $file.dnw
#  					mv $file.bak $file.txt
            echo -e "\n  Number of found and corrected \"1/0\" objs: $sum\n"
						exit
					fi
#	  			mv $file.txt $file.dnw
#  				mv $file.bak $file.txt

#          echo -e "\n  Number of found and corrected \"1/0\" objs: $sum\n"
#          exit

				else
			   	rm $file.mod
				  rm $file.dnw
				fi
			fi
		done

done
echo -e "\n  Number of found and corrected \"1/0\" objs: $sum\n"
exit

#for file in $DMAPP/monitor/pict/param/*.txt
#do
#    echo $file | awk -F. '{print $1 }' >> tmp
#done

#for file in $DMAPP/monitor/pict/MAIN/*.txt
#do
#    echo $file | awk -F. '{print $1 }' >> tmp
#done

cp tmp tmp.ide
mv tmp tmp.tmp

for file in `cat tmp.tmp`
do
   if (test $DMAPP/data/cdbf.dbf -nt $file.dyn)||(test $file.dyn -ot $file.txt)||(test ! -r $file.dyn)
     then
        echo $file
        echo $file >>tmp
    fi
done


if test -s tmp
then
 for file in `cat tmp`
 do
   $DMBIN/dmmonedit -i $file $DMAPP/config/monx.ini
 done
 rm tmp
else
    echo All pictures are up to date.
fi

#if test -s tmp
#then
#    $DMBIN/dmmonedit -i -f tmp $DMAPP/config/monx.ini
#    rm tmp
#else
#    echo All pictures are up to date
#fi

rm tmp.tmp
rm tmp.ide

echo "Compiling Pictures (ready)"
