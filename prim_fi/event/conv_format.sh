#!/bin/sh
#                Written by Laszlo Ocskai, MMG AM Nova Ltd.
#
#  Usage:  conv_format.sh <template_file> <start_event_no> <record_file>
#  <template_file>      Template file of event objects
#  <record_file>        file that contains event records for templates
#  <start_event_no>     numeric value where convert script starts
#                       see syntax of Dmon event_dyn.txt
#  stdout               Dmon style event_dyn.txt
#
#  Sample template:
#
#    ####################################################################
#    # Valve type register bits
#    #
#
#    OBJ: GIOpTypeSet
#        PARL: P0=$CtrWrd P1=$ImitBit
#        ARGL: P2=$Name P3=$Node
#        OEVT: Q0=$E0 Q1=$ImitOn Q2=$ImitOff
#        FUNC: IF (S0 && (P0 & 0X0800) && !P1) : Q1;      \
#              IF (S0 && (P0 & 0X0800) &&  P1) : Q2; ELSE Q0;
#        TYPE: t1=$ t2=$
#
#  '\' char at the and of a line means that current line is continuing in next line
#  '#' char at the begining of a line means that current line is comment
#
#
#  Sample records:
#
#     # Event records:
#    Q0= E0
#    Q1= d=1 b=0 l=1 f=1 t=4 w=1 cf=26 cb=2 td=1 s=…€’%D3! %Q99: ……‚…‘’ˆ ‚ …†ˆŒ ˆŒˆ’€–ˆˆ
#     Q2= d=1 b=0 l=1 f=1 t=4 w=1 cf=26 cb=2 td=1 s=…€’%D3! %Q99: ……‚…‘’ˆ ‚ …€‹œ›‰ …†ˆŒ
#     # Object records:
#    OBJ=GIOpTypeSet \
#      ARG=M1_GI2_19_Name,MON_MIND\
#       TYP=21,2 \
#       PAR=M1_GI2_19_CtrWrd,M1_GI2_19_S2_B08
#    OBJ=GIOpTypeSet ARG=M1_GI2_20_Name,MON_MIND TYP=21,2 PAR=M1_GI2_20_CtrWrd,M1_GI2_20_S2_B08
#
#   A record with its arguments must be in the same line.
#  '\' char at the and of a line means that current line is continuing in next line
#   Evulation of an event record:
#    If "Qn=Ex" then conv script substitues templates's "OEVT: ... Qn=$something ..." fields with "OEVT: Qn=Ex"
#    If "Qn=flags..." then conv script prints out to the stdout a new "Ex=flags..." line with the next available event
#    identifier no. (started from <start_event_no>) "OEVT: ... Qn=$something ..." fields will be substitued with
#    "OEVT: ... Qn=Ex ..."
#
#   Evulation of an object record:
#     Conv sript searches its loaded templates for a template which has the same name id as the actual record's.
#       OBJ: GIOpTypeSet  <=> OBJ=GIOpTypeSet
#     Template's "PARL: Px=$something" fields will be substitued with "PAR=" values of the current object record in linear order
#     Template's "ARGL: Px=$something" fields will be substitued with "ARG=" values of the current object record in linear order
#     Template's "TYPE: tx=$something" fields will be substitued with "TYP=" values of the current object record in linear order
#
#  Output:
#    E148:  d=1 b=0 l=1 f=1 t=4 w=1 cf=26 cb=2 td=1 s=…€’%D3! %Q99: ……‚…‘’ˆ ‚ …†ˆŒ ˆŒˆ’€–ˆˆ
#    E149:  d=1 b=0 l=1 f=1 t=4 w=1 cf=26 cb=2 td=1 s=…€’%D3! %Q99: ……‚…‘’ˆ ‚ …€‹œ›‰ …†ˆŒ
#    OBJ: GIOpTypeSet
#       PARL: P0=M1_GI2_19_CtrWrd P1=M1_GI2_19_S2_B08
#        ARGL: P2=M1_GI2_19_Name P3=MON_MIND
#       OEVT: Q0=E0 Q1=E148 Q2=E149
#       FUNC: IF (S0 && (P0 & 0X0800) && !P1) : Q1;      \
#             IF (S0 && (P0 & 0X0800) &&  P1) : Q2; ELSE Q0;
#       TYPE: t1=21 t2=2
#
#
#

usage="  Usage:  $0 <template_file> <start_event_no> <record_file>"

if test "x$1" = "x"
then
   echo -e "\n  Error: Template file was not given.\n" 1>&2
   echo -e "$usage" 1>&2
   exit 1
fi
if test ! -s $1
then
   echo -e "\n  Error: Template file does not exists.\n" 1>&2
   exit 1
fi


if test "x$2" = "x"
then
   echo -e "\n  Error: Start event number was not given.\n" 1>&2
   echo -e "$usage" 1>&2
   exit 1
fi

echo $2 | grep -v [0-9] > /dev/null 2>&1
if test "$?" -eq "0"
then
   echo -e "\n  Format of 2nd argument <event_start_no> is not valid.\n" 1>&2
   echo -e "$usage" 1>&2
   exit 1
fi

if test "x$3" = "x"
then
   echo -e "\n  Error: Record file was not given.\n" 1>&2
   echo -e "$usage" 1>&2
   exit 1
fi

if test ! -s $3
then
   echo -e "\n  Error: Record file does not exists.\n" 1>&2
   exit 1
fi

flength=$(ls -l "$3" | awk '{print $5}')

 cat $3 | awk '
    BEGIN {
#      pure="([\\+\\*\\$\\?\\^\\[\\]\\(\\)\\\\])"
      template_file=  "'$1'" ;
      tmp_i = 0;
      line="";

      indef=0;
       printf( "\n Event convert utility (MMG AM Nova Kft)\n\n  Reading templates..." )> "/dev/stderr"

      while( getline < template_file ){
        gsub(/\r?/,"")
        if ( $0 ~ /^[ \t]*#.*/) {
          continue;
        }

        if( $0 ~ /^[ \t]*OBJ[ \t]*:[ \t]*[^ \t]+/ ) {
          if( indef ) {
            gsub(/(\n[ \t]*)*$/,"\n",line);

	    tempname=gensub( /^[ \t]*OBJ[ \t]*:[ \t]*([^ \t\n\r]+).*/, "\\1" , 1 , line );
#	    print tempname > "/dev/stderr"

	    template[tempname]=line;

#            print line > "/dev/stderr"
            tmp_i++;
	    line=""
          }
          else {
            indef = 1;
          }
          line = $0 "\n"
          continue;
        }
        line = line $0 "\n"
      }
      if( indef ) {
        gsub(/(\n[ \t]*)*$/,"\n",line);
	tempname=gensub( /^[ \t]*OBJ[ \t]*:[ \t]*([^ \t\n\r]+).*/, "\\1" , 1 , line );
        template[tempname]=line;
        tmp_i++;
      }

      close(template_file);

       print " done\n  Template statistics:\n    Number of loaded templates: " tmp_i > "/dev/stderr"

      verbose=1
      ge="'$2'" + 0
      lq[0]=""
      lq_n=0
      errors=0
      warnings=0
      evobjs=0
      flength='$flength'
      lengthsum=0
      percent=""
       print( "  Reading records..." ) > "/dev/stderr"
    }


    {
      lengthsum+=length($0)+1
      new_percent=sprintf("%2.0f",lengthsum/flength*100)
       if( new_percent != percent ) {
        percent=new_percent
        printf("\r    %s%% done", percent) > "/dev/stderr"
      }

      gsub(/\r?/,"")

      if( ( $0 ~ /^[ \t]*#.*/ ) ||  $0 ~ /^[ \t]*$/  ){
        print $0
        next;
      }

      if( $0 ~ /^[ \t]*Q[0-9]+[ \t]*=/ ) {
        rs="";
        lq_n= gensub( /^[ \t]*Q([0-9]+)[ \t]*=.*$/ , "\\1" , 1)
        lq_n+=0
        lq_flags=gensub( /^[ \t]*Q[0-9]+[ \t]*=(.*$)/ , "\\1" , 1)
        if( lq_flags ~ /^[ \t]*E[0-9]+/ ) {
          lq[lq_n]=gensub( /^[ \t]*(E[0-9]+).*$/ , "\\1" , 1, lq_flags )
        }
        else
        {
          rs="E" ge ": " lq_flags
          print rs
          lq[lq_n] = "E" ge
          ge++;
        }
#         print "  Q" lq_n "=" lq[lq_n]
      }


      if( $0 ~ /^[ \t]*OBJ[ \t]*=/ ) {
        oline=""
        if( $0 !~ /\\[ \t]*$/ ) {
          oline = $0
        }
        else
        {
          while( $0 ~ /\\[ \t]*\n*$/ ) {
            oline = oline gensub( /(.*)\\[ \t]*\n*$/ , "\\1", 1)
            if (getline <= 0) {
               m = "unexpected EOF or error"
               m = (m ": " ERRNO)
               print m > "/dev/stderr"
               exit
            }
            gsub(/\r?/,"")
            lengthsum+=length($0)+1
          }
          oline = oline $0
        }
        gsub( "\t", " " , oline );
        gsub( "  +", " " , oline );
        gsub( " *= *", "=" , oline );
        gsub( " *, *", "," , oline );

#        print "\n********************************************************************************\n" oline

        if( match( oline , /.*OBJ=[^ ]+.*/ ) ) {
          oname=gensub( /.*OBJ=([^ ]+).*/, "\\1" , 1 , oline );
        }
        else {
          print "Error: No OBJ field found in record, input line: " FNR > "/dev/stderr"
          next;
        }
        if( match( oline , /.*ARG=[^ ]+.*/ ) ) {
          delete oarg
          split( gensub( /.*ARG=([^ ]+).*/, "\\1" , 1 , oline ), oarg, "," );
          soarg=1
        }
        else {
          soarg=0
#          if(verbose)
#            print "\nWarning: No PAR field in record, input line: " FNR > "/dev/stderr"
#          warnings++
        }
        if( match( oline , /.*PAR=[^ ]+.*/ ) ) {
          delete opar
          split( gensub( /.*PAR=([^ ]+).*/, "\\1" , 1 , oline ), opar, "," );
          sopar=1
        }
        else {
          sopar=0
#          if(verbose)
#            print "\nWarning: No PAR field in record, input line: " FNR > "/dev/stderr"
#          warnings++
        }
        if( match( oline , /.*TYP=[^ ]+.*/ ) ) {
          sotype=1
          delete otype
          split( gensub( /.*TYP=([^ ]+).*/, "\\1" , 1 , oline ), otype, "," );
        }
        else {
          sotype=0
          if(verbose)
            print "\nWarning: No TYP field in record, input line: " FNR > "/dev/stderr"
          warnings++
        }

#        roname = gensub(pure,"\\\\\\1","g",oname)
#        print "Obj_name: "  oname > "/dev/stderr"
#        print "Obj_type: " otype[1] " " otype[2] > "/dev/stderr"
#        for( i=1; ; i++ ) {
#          if( i in opar )
#            print "\nObj_args: " i ": " opar[i] > "/dev/stderr"
#         else {
#            break;
#          }
#        }

        if( oname in template ) {

              curr_template = template[oname]
              evobjs++

              if(soarg) {
                 base = "ARGL[ \t]*:"
                 inc="[ \t]+P[0-9]+[ \t]*=[ \t]*"
                 nlinc="[ \t]*\\\\\n[ \t]*P[0-9]+[ \t]*=[ \t]*"
                 subst="\\$[^ \t\n]*"
                 existing="[ \t]+P[0-9]+[ \t]*=[ \t]*[^ \\$\t\n]+"
                 nlexisting="[ \t]*\\\\\n[ \t]*[ \t]*P[0-9]+[ \t]*=[ \t]*[^ \\$\t\n]+"
                search_str = base
                 for( i=1; ; i++ ) {
                   if( i in oarg ) {
                    while( match( curr_template, search_str existing ) ) {
                      search_str = search_str existing
                    }
                    while( match( curr_template, search_str nlexisting ) ) {
                      search_str = search_str nlexisting
                    }

                    tmp_search = "(" search_str inc ")" subst
                     if( match( curr_template , tmp_search ) ) {
                      curr_template = gensub( tmp_search, "\\1" oarg[i] , 1 , curr_template);
                      search_str = search_str inc "[^ \\$\t\n]+"
                       continue;
                     }
                     tmp_search = "(" search_str nlinc ")" subst
                      if( match( curr_template , tmp_search ) ) {
                      curr_template = gensub( tmp_search, "\\1" oarg[i] , 1 , curr_template);
                      search_str = search_str nlinc "[^ \\$\t\n]+"
                       continue;
                     }
                    if(verbose)
                       print "\nWarning: Template \"" oname "\" has no " i "th ARG, at input line "   FNR > "/dev/stderr"
                     warnings++
                   }
                   else {
                    break;
                   }
                 }
              }

              if(sopar) {
                 base = "PARL[ \t]*:"
                 inc="[ \t]+P[0-9]+[ \t]*=[ \t]*"
                 nlinc="[ \t]*\\\\\n[ \t]*P[0-9]+[ \t]*=[ \t]*"
                 subst="\\$[^ \t\n]*"
                 existing="[ \t]+P[0-9]+[ \t]*=[ \t]*[^ \\$\t\n]+"
                 nlexisting="[ \t]*\\\\\n[ \t]*[ \t]*P[0-9]+[ \t]*=[ \t]*[^ \\$\t\n]+"
                 search_str = base
                 for( i=1; ; i++ ) {
                   if( i in opar ) {
                    while( match( curr_template, search_str existing ) ) {
                      search_str = search_str existing
                    }
                    while( match( curr_template, search_str nlexisting ) ) {
                      search_str = search_str nlexisting
                    }

                    tmp_search = "(" search_str inc ")" subst
                     if( match( curr_template , tmp_search ) ) {
                      curr_template = gensub( tmp_search, "\\1" opar[i] , 1 , curr_template);
                      search_str = search_str inc "[^ \\$\t\n]+"
                      continue;
                    }
                     tmp_search = "(" search_str nlinc ")" subst
                     if( match( curr_template , tmp_search ) ) {
                      curr_template = gensub( tmp_search, "\\1" opar[i] , 1 , curr_template);
                      search_str = search_str nlinc "[^ \\$\t\n]+"
                       continue;
                    }
                     if(verbose)
                      print "\nWarning: Template \"" oname "\" has no " i "th PAR, at input line "   FNR > "/dev/stderr"
                    warnings++
                    break;
                  }
                   else {
                    break;
                   }
                 }
              }


              if( match(curr_template,/\n[ \t]*ARGL[ \t]*:([^\n\\]+\\[ \t]*\n)*[^\n]*\n/ )  ) {
                arglist=substr( curr_template, RSTART, RLENGTH )
                arglist=gensub( /(\n[ \t]*)ARGL([ \t]*):/, " \\\\\\1    \\2 ", 1, arglist)
                sub( /\n[ \t]*ARGL[ \t]*:([^\n\\]+\\[ \t]*\n)*[^\n]*\n/, "\n", curr_template )
#                print arglist > "/dev/stderr"
                if( match(curr_template,/\n[ \t]*PARL[ \t]*:([^\n\\]+\\[ \t]*\n)*[^\n]*\n/ )  ) {
                  parlist=substr( curr_template, RSTART, RLENGTH-1 )
                  sub( /\n[ \t]*PARL[ \t]*:([^\n\\]+\\[ \t]*\n)*[^\n]*\n/ , parlist arglist, curr_template )
                }
              }


               base = "OEVT[ \t]*:"
               inc="[ \t]+Q[0-9]+[ \t]*=[ \t]*"
               nlinc="[ \t]*\\\\\n[ \t]*Q[0-9]+[ \t]*=[ \t]*"
               subst="\\$[^ \t\n]*"
               existing="[ \t]+Q[0-9]+[ \t]*=[ \t]*[^ \\$\t\n]+"
               nlexisting="[ \t]*\\\\\n[ \t]*[ \t]*Q[0-9]+[ \t]*=[ \t]*[^ \\$\t\n]+"
               search_str = base
               for(i=0;;i++) {
                while( match( curr_template, search_str existing ) ) {
                  search_str = search_str existing
                }
                while( match( curr_template, search_str nlexisting ) ) {
                  search_str = search_str nlexisting
                }
                tmp_search = "(" search_str inc ")" subst
                if( match( curr_template , tmp_search ) ) {
                  curr_template = gensub( tmp_search, "\\1" lq[i] , 1 , curr_template);
                  search_str = search_str inc "[^ \\$\t\n]+"
                  continue;
                }
                tmp_search = "(" search_str nlinc ")" subst
                if( match( curr_template , tmp_search ) ) {
                  curr_template = gensub( tmp_search, "\\1" lq[i] , 1 , curr_template);
                  search_str = search_str nlinc "[^ \\$\t\n]+"
                  continue;
                }
#                if(verbose)
#                  print "\nWarning: Template \"" oname "\" has no " i "th OEVT output, at input line "   FNR > "/dev/stderr"
#                warnings++
                break;
               }

              if( sotype ) {
                tip="([ \t]*TYPE[ \t]*:[ \t]*t[0-9]+[ \t]*=[ \t]*)\\$[^ \t\r\n]*([ \t]*t[0-9]+[ \t]*=[ \t]*)\\$[^ \t\r\n]*"
                if( match( curr_template, tip ) ) {
                  curr_template = gensub( tip, "\\1" otype[1] "\\2" otype[2] , "g" , curr_template )
                }
                else {
                   if(verbose)
                    print "\nWarning: Template \"" oname "\" has no type  field that is given at input line "   FNR > "/dev/stderr"
                   warnings++
                }
              }

#              print "Template found:\n" curr_template
#              gsub( /[ \t]*\\\r?\n[ \t]*/, " ", curr_template )
              curr_template=gensub( /([: \t]+)Q0([0-9]+)/, "\\1Q\\2","g",curr_template)
              curr_template=gensub( /([: \t]+)E0([0-9]+)/, "\\1E\\2","g",curr_template)
              curr_template=gensub( /([: \t]+)P0([0-9]+)/, "\\1P\\2","g",curr_template)
              print curr_template

          }
          else{
            if(verbose)
              print "\nError: No such template: \"" oname "\""> "/dev/stderr"
             errors++
          }
      }

    }

    END {
       print "\n  Record statistics:\n    Errors: " errors " Warnings: " warnings "\n    Event objects: " evobjs > "/dev/stderr"
    }

    '

