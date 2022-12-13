#! /bin/ksh
echo "Compiling Pictures ..."

rm tmp 2>/dev/null

find $DMAPP/monitor/pict -name '*.pict' | sed 's/\.pict//' > tmp

#for file in $DMAPP/monitor/pict/global/*.txt
#do
#    echo $file | awk -F. '{print $1 }' >> tmp
#done

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
   if (test $DMAPP/data/pipe.dbf -nt $file.dyn)||(test $file.dyn -ot $file.txt)||(test ! -r $file.dyn)
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
