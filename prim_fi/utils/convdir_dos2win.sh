#!/bin/sh

#convdir_dos2win dirname
#Convert all test files recursivly in directory dirname

DIRNAME=$1

for i in $(find $DIRNAME -type f)
do

  file=$(file $i | grep ' text' | sed 's/:.*$//')

	if [ "$file" != "" ]
  then
#    echo $file nem ures
		if test -f $file.dos
			then
		  	echo $file.dos exists, not converting
			else
		  	echo converting $file
				mv $file $file.dos
        sh /prim_fi/bin/cirdos2win <$file.dos >$file
		fi

  fi

done
