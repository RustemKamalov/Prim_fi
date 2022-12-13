#!/bin/sh
#	              Written by Laszlo Ocskai, MMG AM Nova Ltd.
#
#
#

usage="  Usage:  $0 <epn_mod_file> <pict_txt_to_convert>"

if test "x$1" = "x"
then
	 echo -e "\n  Error: Epn mod file was not given.\n" 1>&2
	 echo -e "$usage" 1>&2
	 exit 1
fi
if test ! -s $1
then
	 echo -e "\n  Error: Epn mod file does not exists.\n" 1>&2
	 exit 1
fi

if test ! -s $2
then
	 echo -e "\n  Error: Epn pict txt file does not exists.\n" 1>&2
	 exit 1
fi


cat $2 | awk '
    BEGIN {
			pure="([\\+\\*\\$\\?\\^\\[\\]\\(\\)\\\\])"

			mod_file=  "'$1'" ;

			indef=0;
	 	  printf( "\n Pict txt convert utility (MMG AM Nova Kft)\n\n" )> "/dev/stderr"

			for( i=0; getline < mod_file; i++ ){
				gsub(/\r/,"")
				mod[i]=$1
				oid[i]=$2
#        print( "obdzsekt: " $0 ) > "/dev/stderr"
      }

			close(mod_file);

			ado=0
		}

		{
			gsub(/\r/,"")

			if( ( $0 ~ /^[ \t]*#.*/ ) ||  $0 ~ /^[ \t]*$/  ){
				print $0
				next
			}


			if( $0 ~ /^[ \t]*DIGIT:[ \t]*/ ) {
				id=""
        fo=0
        for( i in mod ) {
#         searchstr="DG" mod[i] "_" mod[i]
          searchstr= mod[i]
				  searchstr = gensub(pure,"\\\\\\1","g",searchstr)
#            print "?:" searchstr $0 > "/dev/stderr"

#          if( match( $0,"^[ \t]*DIGIT:[ \t]*DG[0-9]+_" searchstr "[ \t]*" ) ) {
          if( match( $0, "DG[0-9]+_" searchstr "[ \t]*$" ) ) {
#            print "match:" searchstr > "/dev/stderr"
						id=oid[i]
            fo=1
						break;
				  }
			  }
        if( fo==0 ) {
          print $0
          next
        }


				oline=$0
			  while( $0 !~ /[ \t]*END[ \t]*$/ ) {
          if( getline <= 0 ){
             m = "unexpected EOF or error"
             m = (m ": " ERRNO)
             print m > "/dev/stderr"
             exit
          }
    			gsub(/\r/,"")
					oline = oline "\n" $0
				}

#				print "\n********************************************************************************\n" oline > "/dev/stderr"

				no=oline
				no = gensub( /(^[ \t]*)DIGIT:([ \t]*)DG([^\n]*\n)/ , "\\1TEXT:\\2ST" id "_" id "\n", 1 , no )
				no = gensub( /\n[ \t]*NUMBER:[^\n]*\n/, "\n", 1 , no )
				no = gensub( /\n[ \t]*FMT:[^\n]*\n/, "\n", 1 , no )
				no = gensub( /\n[ \t]*VALUE:[^\n]*\n/, "\n", 1 , no )
				no = gensub( /\n[ \t]*COLORS:[^\n]*\n/, "\n", 1 , no )
				no = gensub( /opt[ \t]*=[ \t]*r/, "", 1 , no )

				tmpstr=oline
				if( match( tmpstr, /row[ \t]*=[ \t]*[0-9]+/)) {
					tmpstr = substr( tmpstr, RSTART )
					wd=gensub(/^row[ \t]*=[ \t]*([0-9]+)[^0-9]?.*/,"\\1",1,tmpstr)
					wd+=0
					no=gensub( /(row[ \t]*=[ \t]*)[0-9]+([^0-9]?)/,"\\1" (wd+50) "\\2" , 1 , no )
				}

				cs = "****"
				tmpstr=oline
				if( match( tmpstr, /width[ \t]*=[ \t]*[0-9]+/)) {
					tmpstr = substr( tmpstr, RSTART )
					wd=gensub(/^width[ \t]*=[ \t]*([0-9]+).*/,"\\1",1,tmpstr)
					wd+=0

					cs =""
					for(j=0;(j<wd);j++){
						 cs=cs "*"
					}
				}
				hihestr="STRING:	str=\"" cs  "\""

				no = gensub( /\n([ \t]*)([^\n]*)(\n[ \t]*END[ \t]*)/, "\n\\1\\2\n\\1" hihestr "\n\\3", 1 , no )

#				print "\n***NEW***\n" no > "/dev/stderr"
				print no
				print "\n" oline
				ado++

			}
			else {

				print $0

			}

		}


	  END {
	 	  print( "  Statistics:\n    Number of added objects: " ado "\n" ) > "/dev/stderr"
	  }

		'

