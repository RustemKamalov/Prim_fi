#! /bin/sh

# Change fonts from dos to win (OEM-866 to Windows-1251) in .pict and dynamics .txt files

# $1: pict file with or without .pict ending
#FILE=$(echo $1 | sed 's/\.pict//')
# a hulye dmtxttopict miatt kell a filenevben a /-t \-re cserelni
FILE=$(echo $1 | sed 's/\.pict//' | sed 's%/%\\%')
PICT_FILE=$FILE.pict
TXTDYN_FILE=$FILE.txt

# Check if .pict.ori or .txt.ori file exists
if test -f $PICT_FILE.ori
then
  echo $PICT_FILE.ori exists, not converting
  exit
fi

if test -f $TXTDYN_FILE.ori
then
  echo $TXTDYN_FILE.ori exists, not converting
  exit
fi

# Convert .pict file
# warning! dmpicttotxt and dmtxttopict need filenames ending with .txt or .pict
#echo /Dmon/utils/dmpicttotxt $PICT_FILE $PICT_FILE.txt
/Dmon/utils/dmpicttotxt $PICT_FILE $PICT_FILE.txt

#itt egy-ket dmpicttotxt bugot is kiszurunk
sh /prim_fi/bin/cirdos2win <$PICT_FILE.txt | \
grep -v 'file:C:.*pictc_pict.cpp' | \
sed 's/\(FMT:.*fmt=[cdm]\)t/\1/' >$PICT_FILE.new.txt

mv $PICT_FILE $PICT_FILE.ori
#echo /Dmon/utils/dmtxttopict $PICT_FILE.new.txt $PICT_FILE
/Dmon/utils/dmtxttopict $PICT_FILE.new.txt $PICT_FILE 2>$PICT_FILE.err >$PICT_FILE.res

OK=0
if  grep -q "CKSUM" $PICT_FILE.err
  then
    OK=1
fi
if  grep -q "error" $PICT_FILE.res
  then
    OK=0
fi

if [ $OK -eq 0 ]
  then
    echo error changing font in $FILE
  else
    rm -v $PICT_FILE.txt $PICT_FILE.new.txt
fi


# Convert dynamics .txt file
mv $TXTDYN_FILE $TXTDYN_FILE.ori
sh /prim_fi/bin/cirdos2win <$TXTDYN_FILE.ori >$TXTDYN_FILE

#Compile pict
#echo /Dmon/bin/dmmonedit -i$FILE /prim_fi/config/monx.ini
/Dmon/bin/dmmonedit -i$FILE /prim_fi/config/monx.ini

