#!/bin/sh
#	              Written by Laszlo Ocskai, MMG AM Nova Ltd.
#
#
#

usage="  Usage:  $0 <pict_txt>"

if test ! -s $1
then
	 echo -e "\n  Error: pict2txt file does not exists.\n" 1>&2
	 echo -e "  $1"
	 echo -e "$usage" 1>&2
	 exit 1
fi


cat $1 | awk '
		BEGIN {
		}
		{

			if( $0 ~ /^[ \t]*#/ ) {
					next
			}
			if( $0 ~ /^[ \t]*[^:]+:[^0-9]*[0-9]+.*$/ ) {
				cn=gensub(/^[ \t]*[^:]+:[^0-9]*([0-9]+).*$/,"\\1",1)
   			print cn
   			do {
	 			  if( getline <= 0 ) {
		  	    exit
			    }
				}
  			while( $0 !~ /[ \t]*END[ \t]*/ )
			}

		}


		'

