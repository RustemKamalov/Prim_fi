#!/bin/sh
#	              Written by Laszlo Ocskai, MMG AM Nova Ltd.
#

usage="  Usage:  $0 <picture_dynamic.txt> [used_indexes.txt]"

if test "x$1" = "x"
then
	 echo -e "\n  Error: Input dynamic txt file was not given.\n" 1>&2
	 echo -e "$usage" 1>&2
	 exit 1
fi
if test ! -s $1
then
	 echo -e "\n  Error: Input dynamic txt file does not exists.\n" 1>&2
	 exit 1
fi


cat $1 | awk '
		function parfil( str ) {
			while( str ~ /^\(.*\)$/ ) {
				str1=substr(str,2,length(str)-2)
 				sub(/^[ \t]*/,"",str1)
  			sub(/[ \t]*$/,"",str1)
				if( str1 ~ /^[^\(]*\)/ ) {
					return str
				}
				p=0
				for(i=1; i<=length(str1);i++) {
				  mc = substr(str1,i,1)
					if( mc == "(")
					  p++
					if( mc == ")" )
						p--
				}
				if( p!=0 ) {
					return str;
				}
				else {
					str = str1
  				sub(/^[ \t]*/,"",str)
	  			sub(/[ \t]*$/,"",str)
				}

			}
			return ( str );
		}

		BEGIN {
			pure="([\\+\\*\\$\\?\\^\\[\\]\\(\\)\\\\])"
			#print parfil( "((a+b+c)+(d))" )

			dfile =  "'$2'"
			largest=1500
			if( length(dfile) ) {
				t[0]=1
				while( getline < dfile ) {
 					t[$1] = 1
			  }
  	 		for( i=largest; i<10000; i++ ) {
 	  			if( !(i in t) ) {
 		  			largest=i
   		  		break;
 	  	  	}
 	    	}
			}
		}


		{
			gsub(/\r/,"")

			if( $0 ~ /^[ \t]*OBJ[ \t]*:/ ) {
				oline=""
			  while( $0 !~ /[ \t]*OBEND[ \t]*$/ ) {
  				oline = oline $0 "\n"
          if (getline <= 0) {
             m = "unexpected EOF or error"
             m = (m ": " ERRNO)
             print m > "/dev/stderr"
             exit
          }
    			gsub(/\r/,"")
				}
			  oline = oline $0

				noline = oline

				if( match(oline, /[ \t]*VALF:[^\n]*1\/0[ \t]*;[^\n]*\n/) ) {
					valf_x=RSTART
					valf_l=RLENGTH
#				  print "\nOriginal:\n" oline
					valfstr=substr( oline, RSTART, RLENGTH )
#				  print "\nValf line:\n" valfstr
					maxq=0
					if( match(oline, /[ \t]*OPTD:[^\n]*\n/) ) {
  					optdstr=substr( oline, RSTART, RLENGTH )
  				  #print "\nOptd line:\n" optdstr
						tempstr=optdstr
						while( match( tempstr, /Q[0-9]+[ \t]*=/ ) ) {
							 cq=gensub( /[^Q]*Q([0-9]+)[ \t]*=.*/,"\\1",1,tempstr)
							 cq+=0
							 if( cq > maxq ) {
								 maxq=cq
							 }
							 tempstr=substr( tempstr, RSTART+RLENGTH )
						}
  				  #print "\n  Optd line QMAX:\n    " maxq
						sub(/\n$/,"",optdstr)
					}
  				else {
						if ( match(noline,/\n[ \t]*SELD:[^\n]*\n/) ) {
    					noline=gensub( /\n([ \t]*)(SELD:)/, "\n\\1OPTD:\n\\1\\2", 1 , noline )
						}
						else {
    					noline=gensub( /\n([ \t]*)([^\n]+\n)([ \t]*OBEND)/, "\n\\1\\2\\1OPTD:\n\\3", "g" , noline )
						}
					}
					maxq++
					optdstr= " Q" maxq "=-d-e-m-s-H-R+X" "\n"
				  #print "\nNew Optd line:\n" optdstr
					match(noline, /OPTD:[^\n]*\n/)
					noline=substr(noline,1,RSTART+RLENGTH-1-1) optdstr substr(noline, RSTART+RLENGTH )


					if( match(oline, /[ \t]*OPTF:[^\n]*\n/) ) {
  					optfstr=substr( oline, RSTART, RLENGTH )
#   				  print "\nOptf line:\n" optfstr
					}
					else {
   					noline=gensub( /\n([ \t]*)(OPTD:[^\n]*\n)/, "\n\\1\\2\\1OPTF: ELSE Q0;\n", 1 , noline )
#						noline=gensub( /\n([ \t]*)([^\n]+\n)([ \t]*OBEND)/, "\n\\1\\2\\1OPTF: ELSE Q0;\n\\3", "g" , noline )
					}

					tmpstr=valfstr
					nvalf=""
					evalf=""
					oexpr=""
					while( match(tmpstr, /IF[^;]+;/) ) {
						l=RLENGTH
						tmpstr=substr(tmpstr,RSTART)
#						print "\n  TMPSTR: " tmpstr
  					expr=gensub( /^IF[ \t]*([^;:]+):.*/,"\\1",1, tmpstr )
						sub( /^[ \t]+/ , "", expr )
						sub( /[ \t]+$/ , "", expr )
						expr=parfil(expr)
#						print "\n  Expression: " expr
						if( match( tmpstr, /^IF[^;:]+:[ \t]*1\/0/ ) ) {
							if( length(nvalf) ){
								oexpr = oexpr "IF !(" parfil(nvalf) ") && (" expr ")" " : Q" maxq ";"
 #								print "\nNew OPTF11: " oexpr
 #								nvalf = ""
							}
							else {
								oexpr = oexpr "IF (" expr ")" " : Q" maxq ";"
#								print "\nNew OPTF12: " oexpr
#								nvalf = ""
							}
						}
						else {
						if( length(evalf) ){
						  evalf = evalf "|| (" expr ")"
						}
						else {
							evalf = "(" expr ")"
						}

							if( length(nvalf) ){
								nvalf = nvalf " || (" expr ")"
#								print "\nNew OPTF21: " nvalf
							}
							else {
								nvalf = "("expr")"
 #								print "\nNew OPTF22: " nvalf
							}
						}
						tmpstr=substr(tmpstr,l+1)
					}

  				if( match(tmpstr, /ELSE[ \t]*1\/0/) ) {
						if( length(evalf) ) {
							oexpr = oexpr "IF !(" evalf ") : Q" maxq ";"
						}
						else {
						  oexpr = "IF 1 : Q" maxq ";"
						}
					}
 					oexpr=oexpr " "


					gsub(/1\/0/,"0", valfstr )
					gsub( /\&/, "\\\\&", valfstr)
				  sub(/[ \t]*VALF:[^\n]*\n/, valfstr, noline )

					soexpr=oexpr
					gsub( /\&/, "\\\\&", oexpr)
					noline=gensub( /(OPTF:[ \t]*)/, "\\1" oexpr , 1, noline  )


#					print "New object:\n"
					print noline

					soexpr=gensub(/(:[ \t]*Q)[0-9]([ \t]*;)/,"\\10\\2","g",soexpr)


					soseld=""
					sparl=gensub(/.*\n[ \t]*(PARL:[^\n]*)\n.*/,"\\1",1,noline)
					if ( match( oline,/\n[ \t]*SELD:[^\n]*\n/) ) {
   					soseld = substr( oline, RSTART+1, RLENGTH-1 )
					}
					else {

					  tmpstr=soexpr
					  max=0
					  delete op
					  while( match( tmpstr , /[^a-bA-B0-9]P[0-9]+[^a-bA-B0-9]/ ) ) {
						  tmpstr=substr(tmpstr,RSTART)
						  ap = gensub( /^[^a-bA-B0-9]P([0-9]+)[^a-bA-B0-9].*/, "\\1", 1, tmpstr )
						  op[ap]=1
						  if( ap+0 > max ) {
							  max=ap+0
						  }
						  tmpstr=substr(tmpstr,RLENGTH)
					  }

#					  print soexpr > "/dev/stderr"

					  m=0
					  for( i=0; i <= max; i++ ) {
  					  if( i in op ) {
							  op[i]=m
						    soexpr = gensub( "([^a-bA-B0-9]P)" i "([^a-bA-B0-9])", "\\1" m "\\2", "g", soexpr )
#							  print "P" i " => P"  m > "/dev/stderr"
							  m++
	  				  }
					  }
 #					 print soexpr > "/dev/stderr"

					  tmpstr=sparl
					  while( match( tmpstr , /P[0-9]+[ \t]*=[ \t]*[^ \t]*[ \t]*/ ) ) {
						  tmpstr=substr(tmpstr,RSTART)
						  ap = gensub( /^P([0-9]+)[ \t]*=.*/, "\\1", 1, tmpstr )
  					  if( !(ap in op) ) {
#    				     printf( "x: " ap " " ) > "/dev/stderr"
						    sparl = gensub( "P" ap "[ \t]*=[ \t]*[^ \t]*[ \t]*", "", 1, sparl )
						  }
						  tmpstr=substr(tmpstr,RLENGTH)
					  }

					  for( i=0; i <= max; i++ ) {
  					  if( i in op ) {
						    sparl = gensub( "P" i "([ \t]*=)", "P" op[i] "\\1", 1, sparl )
#							   print "  P" i " => P"  op[i] > "/dev/stderr"
	  				  }
					  }
					}

					so = "\n"
					so = so "OBJ: " largest "\n"
					if( sparl !~ /PARL:[ \t]*$/) {
					  so = so "  " sparl "\n"
					}
  				so = so "  OPTD: Q1=-d-e-m-s-H-R+X" "\n"
          so = so "  OPTF: " soexpr "ELSE Q1;" "\n"
					so = so soseld
					so = so "OBEND"

					print so
#					gso=gso so

          print( gensub(/^OBJ:[ \t]*([^ \t]+)\n.*/,"\\1",1,noline) " " largest ) > "/dev/stderr"
  				for( i=largest+1; i<10000; i++ ) {
	  				if( !(i in t) ) {
		  				largest=i
			  			break;
				  	}
				  }

#				  exit
				}
				else
				{
					print oline
				}

			}
			else {
				print $0
			}


#				if( match( oline , /.*OBJ=[^ ]+.*/ ) ) {
#  				oname=gensub( /.*OBJ=([^ ]+).*/, "\\1" , 1 , oline );
#				}
#				else {
#					print "Error: No OBJ field found in record, input line: " FNR > "/dev/stderr"
#					next;
#				}
#				if( match( oline , /.*ARG=[^ ]+.*/ ) ) {
#  				split( gensub( /.*ARG=([^ ]+).*/, "\\1" , 1 , oline ), oarg, "," );
#					soarg=1
#				}
#				else {
#					soarg=0
#					if(verbose)
#  					print "Warning: No PAR field in record, input line: " FNR > "/dev/stderr"
#					warnings++
#				}
#				if( match( oline , /.*PAR=[^ ]+.*/ ) ) {
#  				split( gensub( /.*PAR=([^ ]+).*/, "\\1" , 1 , oline ), opar, "," );
#					sopar=1
#				}
#				else {
#					sopar=0
#					if(verbose)
#  					print "Warning: No PAR field in record, input line: " FNR > "/dev/stderr"
#					warnings++
#				}
#				if( match( oline , /.*TYP=[^ ]+.*/ ) ) {
#					sotype=1
#  				split( gensub( /.*TYP=([^ ]+).*/, "\\1" , 1 , oline ), otype, "," );
#				}
#				else {
#					sotype=0
#					if(verbose)
#  					print "Warning: No TYP field in record, input line: " FNR > "/dev/stderr"
#					warnings++
#				}
#
#				roname = gensub(pure,"\\\\\\1","g",oname)
#				print "Obj_name: "  oname > "/dev/stderr"
#				print "Obj_type: " otype[1] " " otype[2] > "/dev/stderr"
#				for( i=1; ; i++ ) {
#					if( i in opar )
#			  	  print "Obj_args: " i ": " opar[i] > "/dev/stderr"
#					else {
#						break;
#					}
#				}
#
#				for( i=1; ; i++ ) {
#					if( i in template ) {
#
#						if( match( template[i], "^[ \t]*OBJ[ \t]*:[ \t]*" roname "[ \t\n]+" ) ) {
#							curr_template = template[i]
#							evobjs++
#
#							if(soarg) {
#	 							base = "ARGL[ \t]*:"
#	 							inc="[ \t]+P[0-9]+[ \t]*=[ \t]*"
#	 							nlinc="[ \t]*\\\\\n[ \t]*P[0-9]+[ \t]*=[ \t]*"
#	 							subst="\\$[^ \t\n]*"
#   							existing="[ \t]+P[0-9]+[ \t]*=[ \t]*[^ \\$\t\n]+"
# 	  						nlexisting="[ \t]*\\\\\n[ \t]*[ \t]*P[0-9]+[ \t]*=[ \t]*[^ \\$\t\n]+"
#								search_str = base
#	 							for( i=1; ; i++ ) {
#	 					      if( i in oarg ) {
#					    			while( match( curr_template, search_str existing ) ) {
#				  		  			search_str = search_str existing
#  			  					}
#	  	  						while( match( curr_template, search_str nlexisting ) ) {
#	    								search_str = search_str nlexisting
#  		  						}
#
#										tmp_search = "(" search_str inc ")" subst
#	 									if( match( curr_template , tmp_search ) ) {
#    									curr_template = gensub( tmp_search, "\\1" oarg[i] , 1 , curr_template);
#    									search_str = search_str inc "[^ \\$\t\n]+"
#	 										continue;
#	 									}
#	 								  tmp_search = "(" search_str nlinc ")" subst
# 	 									if( match( curr_template , tmp_search ) ) {
#    									curr_template = gensub( tmp_search, "\\1" oarg[i] , 1 , curr_template);
#    									search_str = search_str nlinc "[^ \\$\t\n]+"
#	 									  continue;
#	 									}
#          					if(verbose)
#	 				  			    print "Warning: Template \"" oname "\" has no " i "th ARG, at input line "   FNR > "/dev/stderr"
#	 									warnings++
#	 								}
#	 							  else {
#    						    break;
#	 	  				    }
#	 		  		    }
#							}
#
#							if(sopar) {
#	 							base = "PARL[ \t]*:"
#	 							inc="[ \t]+P[0-9]+[ \t]*=[ \t]*"
#	 							nlinc="[ \t]*\\\\\n[ \t]*P[0-9]+[ \t]*=[ \t]*"
#	 							subst="\\$[^ \t\n]*"
#   							existing="[ \t]+P[0-9]+[ \t]*=[ \t]*[^ \\$\t\n]+"
# 	  						nlexisting="[ \t]*\\\\\n[ \t]*[ \t]*P[0-9]+[ \t]*=[ \t]*[^ \\$\t\n]+"
#	 							search_str = base
#	 							for( i=1; ; i++ ) {
#	 					      if( i in opar ) {
#					    			while( match( curr_template, search_str existing ) ) {
#				  		  			search_str = search_str existing
#  			  					}
#	  	  						while( match( curr_template, search_str nlexisting ) ) {
#	    								search_str = search_str nlexisting
#  		  						}
#
#										tmp_search = "(" search_str inc ")" subst
#	 									if( match( curr_template , tmp_search ) ) {
#  										curr_template = gensub( tmp_search, "\\1" opar[i] , 1 , curr_template);
#    									search_str = search_str inc "[^ \\$\t\n]+"
# 			  							continue;
#										}
#	 								  tmp_search = "(" search_str nlinc ")" subst
#   									if( match( curr_template , tmp_search ) ) {
#  										curr_template = gensub( tmp_search, "\\1" opar[i] , 1 , curr_template);
#    									search_str = search_str nlinc "[^ \\$\t\n]+"
# 			  							continue;
#										}
#           					if(verbose)
#    			  			    print "Warning: Template \"" oname "\" has no " i "th PAR, at input line "   FNR > "/dev/stderr"
#			    					warnings++
#										break;
#									}
#	 							  else {
#    						    break;
#	 	  				    }
#	 		  		    }
#							}
#
#
#							if( match(curr_template,/\n[ \t]*ARGL[ \t]*:([^\n\\]+\\[ \t]*\n)*[^\n]*\n/ )  ) {
#								arglist=substr( curr_template, RSTART, RLENGTH )
#								arglist=gensub( /(\n[ \t]*)ARGL([ \t]*):/, " \\\\\\1    \\2 ", 1, arglist)
#							  sub( /\n[ \t]*ARGL[ \t]*:([^\n\\]+\\[ \t]*\n)*[^\n]*\n/, "\n", curr_template )
#								print arglist > "/dev/stderr"
#  							if( match(curr_template,/\n[ \t]*PARL[ \t]*:([^\n\\]+\\[ \t]*\n)*[^\n]*\n/ )  ) {
#  								parlist=substr( curr_template, RSTART, RLENGTH-1 )
#									sub( /\n[ \t]*PARL[ \t]*:([^\n\\]+\\[ \t]*\n)*[^\n]*\n/ , parlist arglist, curr_template )
#								}
#							}
#
# 							base = "OEVT[ \t]*:"
# 							inc="[ \t]+Q[0-9]+[ \t]*=[ \t]*"
# 							nlinc="[ \t]*\\\\\n[ \t]*Q[0-9]+[ \t]*=[ \t]*"
# 							subst="\\$[^ \t\n]*"
# 							existing="[ \t]+Q[0-9]+[ \t]*=[ \t]*[^ \\$\t\n]+"
# 							nlexisting="[ \t]*\\\\\n[ \t]*[ \t]*Q[0-9]+[ \t]*=[ \t]*[^ \\$\t\n]+"
# 							search_str = base
# 							for(i=0;;i++) {
#								while( match( curr_template, search_str existing ) ) {
#									search_str = search_str existing
#								}
#								while( match( curr_template, search_str nlexisting ) ) {
#									search_str = search_str nlexisting
#								}
#								tmp_search = "(" search_str inc ")" subst
#								if( match( curr_template , tmp_search ) ) {
#									curr_template = gensub( tmp_search, "\\1" lq[i] , 1 , curr_template);
#									search_str = search_str inc "[^ \\$\t\n]+"
#									continue;
#								}
#							  tmp_search = "(" search_str nlinc ")" subst
#								if( match( curr_template , tmp_search ) ) {
#									curr_template = gensub( tmp_search, "\\1" lq[i] , 1 , curr_template);
#									search_str = search_str nlinc "[^ \\$\t\n]+"
#								  continue;
#								}
##      					if(verbose)
##			  			    print "Warning: Template \"" oname "\" has no " i "th OEVT output, at input line "   FNR > "/dev/stderr"
##								warnings++
#  					    break;
# 		  		    }
#
#							if( sotype ) {
#			  				tip="([ \t]*TYPE[ \t]*:[ \t]*t[0-9]+[ \t]*=[ \t]*)\\$[^ \t\r\n]*([ \t]*t[0-9]+[ \t]*=[ \t]*)\\$[^ \t\r\n]*"
#  							if( match( curr_template, tip ) ) {
#	  					    curr_template = gensub( tip, "\\1" otype[1] "\\2" otype[2] , "g" , curr_template )
#		  				  }
#								else {
#         					if(verbose)
#				  					print "Warning: Template \"" oname "\" has no type  field that is given at input line "   FNR > "/dev/stderr"
# 									warnings++
#								}
#							}
#
##              print "Template found:\n" curr_template
##							gsub( /[ \t]*\\\r?\n[ \t]*/, " ", curr_template )
#  						curr_template=gensub( /Q0([0-9]+)/, "Q\\1","g",curr_template)
#  						curr_template=gensub( /E0([0-9]+)/, "E\\1","g",curr_template)
#  						curr_template=gensub( /P0([0-9]+)/, "P\\1","g",curr_template)
#							print curr_template
#
#							break;
#						}
#
#					}
#					else{
#  					if(verbose)
#              print "\nError: No such template: \"" oname "\""> "/dev/stderr"
# 						errors++
#						break;
#					}
#				}
#			}
#
		}

	  END {
#			print gso
#	 	  print( "\n  Conversion statistics:\n    Number of converted objects:\n") > "/dev/stderr"
	  }

		'

