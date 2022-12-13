#/bin/sh
# dmdynedit utility for D-mon Monitor Editor (ScadaSys Ltd.)
#-----------------------------------------------------------------------
# $1: name of the temporoary text file in which the dynamic information
# $2: name of the object
# $3: name of the error file
#-----------------------------------------------------------------------

# 2004.09.07    WG:     V5.5.2.3
#      megnezi, hogy milyen oprendeszer alatt fut
#      valamint a TEXT_EDITOR variable alapjan indit text editort
#	   err file betoltes javitva (.err)
# 2004.09.07    WG:     V5.10.1.3
#      rtp pterm

VER_NO="V5.10.1.3"
DMBIN=${DMBIN-"/Dmon/bin"}
DMUTILS=${DMUTILS-"$DMBIN/../utils"}

if test $3'X' = 'X'
then
    echo "dmdynedit.sh utility for D-mon Monitor Editor\nVersion: $VER_NO \n"
    echo "\tThis utility can be launched only from the D-mon Monitor Editor"
    exit
fi

if test _$OS = _Windows_NT
then
  #TEXT_EDITOR=${TEXT_EDITOR-"vpw.exe"}
  TEXT_EDITOR=${TEXT_EDITOR-"mew32.exe"}
fi

if test _$SYSNAME = _qnx4
then
	PTERM=${PTERM-"pterm.rc"}
#	PTERM=${PTERM-"pterm_ru_RU_102.rc"}
	TEXT_EDITOR=${TEXT_EDITOR-"vedit"}
	OS=qnx4
fi

if test _$SYSNAME = _nto
then
	PTERM=${PTERM-"pterm.rc"}
	TEXT_EDITOR=${TEXT_EDITOR-"med"}
	OS=Rtp
fi


if test $2'X' = 'X'
then
    echo "dmdyninfo utility for D-mon Monitor Editor\nVersion: $VER_NO \n"
    echo "\tThis utility can be launched only from the D-mon Monitor Editor"
    exit
fi
menu() {
    rm dmMenu.ret 2> /dev/null
    dynchk_copy=" "
    dynchk_copy=`awk -F, -f ${DMUTILS}/dmdynchk_copy.awk objname=$2 $1`
    chk_clipboard=""
    for file in `ls C_* 2>/dev/null`
    do
        chk_clipboard=$chk_clipboard"-"`basename $file .dyncopy.txt`
    done

    dmmenu_title="Object:"$2
    dmmenu_list=""
    dmmenu_list=$dmmenu_list"Undo|U;"
    dmmenu_list=$dmmenu_list"Edit|E;"
    dmmenu_list=$dmmenu_list"View|V;"
    dmmenu_list=$dmmenu_list"Copy|C;"
    dmmenu_list=$dmmenu_list"Paste|P;"
    dmmenu_list=$dmmenu_list"Delete|D;"
    dmmenu_list=$dmmenu_list"Copy...@("
        dmmenu_list_tmp=$dmmenu_list
        dmmenu_list=$dmmenu_list"All-Without-ParameterList|C_ALLWITHOUTPARL"
        if test "x$dynchk_copy" = "xPARL"
        then
            dmmenu_list=$dmmenu_list_tmp
            dmmenu_list=$dmmenu_list"Parameter-List|C_PARL"
            dynchk_copy="x"
        fi
        if test "x$dynchk_copy" = "x"
        then
            dmmenu_list=${dmmenu_list_tmp}"Nothing-to-Copy-Exit"
        fi

        case $dynchk_copy in
            *PARL*)
                dmmenu_list=$dmmenu_list";Parameter-List|C_PARL"
                ;;
        esac
        case $dynchk_copy in
            *VALF*)
                dmmenu_list=$dmmenu_list";Value-Function|C_VALF"
                ;;
        esac
        case $dynchk_copy in
            *TXTD*)
                dmmenu_list=$dmmenu_list";Text-Data|C_TXTD"
                ;;
        esac
        case $dynchk_copy in
            *TXTF*)
                dmmenu_list=$dmmenu_list";Text-Function|C_TXTF"
                ;;
        esac
        case $dynchk_copy in
            *POLY*)
                dmmenu_list=$dmmenu_list";Polygon-Data|C_POLY"
                ;;
        esac
        case $dynchk_copy in
            *COLD*)
                dmmenu_list=$dmmenu_list";Color-Data|C_COLD"
                ;;
        esac
        case $dynchk_copy in
            *COLF*)
                dmmenu_list=$dmmenu_list";Color-Function|C_COLF"
                ;;
        esac
        case $dynchk_copy in
            *BLND*)
                dmmenu_list=$dmmenu_list";Blink-Data|C_BLND"
                ;;
        esac
        case $dynchk_copy in
            *BLNF*)
                dmmenu_list=$dmmenu_list";Blink-Function|C_BLNF"
                ;;
        esac
        case $dynchk_copy in
            *TRND*)
                dmmenu_list=$dmmenu_list";Trend-Data|C_TRND"
                ;;
        esac
        case $dynchk_copy in
            *TRNF*)
                dmmenu_list=$dmmenu_list";Trend-Function|C_TRNF"
                ;;
        esac
        case $dynchk_copy in
            *XPSF*)
                dmmenu_list=$dmmenu_list";XPosition-Function|C_XPSF"
                ;;
        esac
        case $dynchk_copy in
            *YPSF*)
                dmmenu_list=$dmmenu_list";YPosition-Function|C_YPSF"
                ;;
        esac
        case $dynchk_copy in
            *OPTD*)
                dmmenu_list=$dmmenu_list";Option-Data|C_OPTD"
                ;;
        esac
        case $dynchk_copy in
            *OPTF*)
                dmmenu_list=$dmmenu_list";Option-Function|C_OPTF"
                ;;
        esac
        case $dynchk_copy in
            *SELD*)
                dmmenu_list=$dmmenu_list";Select-Data|C_SELD"
                ;;
        esac
        case $dynchk_copy in
            *HLPD*)
                dmmenu_list=$dmmenu_list";Help-File-Data|C_HLPD"
                ;;
        esac
        case $dynchk_copy in
            *KEYD*)
                dmmenu_list=$dmmenu_list";Keyboard-Code|C_KEYD"
                ;;
        esac
        case $dynchk_copy in
            *KBDG*)
                dmmenu_list=$dmmenu_list";Keyboard-Groups|C_KBDG"
                ;;
        esac
        dmmenu_list=$dmmenu_list");"
    dmmenu_list=$dmmenu_list"Paste...@("
        if [ "X$chk_clipboard" = "X" ]
        then
            dmmenu_list=$dmmenu_list"Nothing-to-Paste-Exit|X"
        else
            dmmenu_list=$dmmenu_list"All-Without-Parameter-List|P_ALL_WITHOUT_PARL"
        fi
        case $chk_clipboard in
            *PARL*)
                dmmenu_list=$dmmenu_list";Parameter-List|P_PARL"
                ;;
        esac
        case $chk_clipboard in
            *VALF*)
                dmmenu_list=$dmmenu_list";Value-Function|P_VALF"
                ;;
        esac
        case $chk_clipboard in
            *TXTD*)
                dmmenu_list=$dmmenu_list";Text-Data|P_TXTD"
                ;;
        esac
        case $chk_clipboard in
            *TXTF*)
                dmmenu_list=$dmmenu_list";Text-Function|P_TXTF"
                ;;
        esac
        case $chk_clipboard in
            *POLY*)
                dmmenu_list=$dmmenu_list";Polygon-Data|P_POLY"
                ;;
        esac
        case $chk_clipboard in
            *COLD*)
                dmmenu_list=$dmmenu_list";Color-Data|P_COLD"
                ;;
        esac
        case $chk_clipboard in
            *COLF*)
                dmmenu_list=$dmmenu_list";Color-Function|P_COLF"
                ;;
        esac
        case $chk_clipboard in
            *BLND*)
                dmmenu_list=$dmmenu_list";Blink-Data|P_BLND"
                ;;
        esac
        case $chk_clipboard in
            *BLNF*)
                dmmenu_list=$dmmenu_list";Blink-Function|P_BLNF"
                ;;
        esac
        case $chk_clipboard in
            *TRND*)
                dmmenu_list=$dmmenu_list";Trend-Data|P_TRND"
                ;;
        esac
        case $chk_clipboard in
            *TRNF*)
                dmmenu_list=$dmmenu_list";Trend-Function|P_TRNF"
                ;;
        esac
        case $chk_clipboard in
            *XPSF*)
                dmmenu_list=$dmmenu_list";XPosition-Function|P_XPSF"
                ;;
        esac
        case $chk_clipboard in
            *YPSF*)
                dmmenu_list=$dmmenu_list";YPosition-Function|P_YPSF"
                ;;
        esac
        case $chk_clipboard in
            *OPTD*)
                dmmenu_list=$dmmenu_list";Option-Data|P_OPTD"
                ;;
        esac
        case $chk_clipboard in
            *OPTF*)
                dmmenu_list=$dmmenu_list";Option-Function|P_OPTF"
                ;;
        esac
        case $chk_clipboard in
            *SELD*)
                dmmenu_list=$dmmenu_list";Select-Data|P_SELD"
                ;;
        esac
        case $chk_clipboard in
            *HLPD*)
                dmmenu_list=$dmmenu_list";Help-File-Data|P_HLPD"
                ;;
        esac
        case $chk_clipboard in
            *KEYD*)
                dmmenu_list=$dmmenu_list";Keyboard-Code|P_KEYD"
                ;;
        esac
        case $chk_clipboard in
            *KBDG*)
                dmmenu_list=$dmmenu_list";Keyboard-Groups|P_KBDG"
                ;;
        esac
        dmmenu_list=$dmmenu_list");"
    dmmenu_list=$dmmenu_list"Clipboard...@("
        if [ "X$chk_clipboard" = "X" ]
        then
            dmmenu_list=$dmmenu_list"Clipboard-Empty-Exit|X"
        else
            dmmenu_list=$dmmenu_list"View-All|CL_ALL"
        fi
        case $chk_clipboard in
            *PARL*)
                dmmenu_list=$dmmenu_list";View-Parameter-List|CL_PARL"
                ;;
        esac
        case $chk_clipboard in
            *VALF*)
                dmmenu_list=$dmmenu_list";View-Value-Function|CL_VALF"
                ;;
        esac
        case $chk_clipboard in
            *TXTD*)
                dmmenu_list=$dmmenu_list";View-Text-Data|CL_TXTD"
                ;;
        esac
        case $chk_clipboard in
            *TXTF*)
                dmmenu_list=$dmmenu_list";View-Text-Function|CL_TXTF"
                ;;
        esac
        case $chk_clipboard in
            *POLY*)
                dmmenu_list=$dmmenu_list";View-Polygon-Data|CL_POLY"
                ;;
        esac
        case $chk_clipboard in
            *COLD*)
                dmmenu_list=$dmmenu_list";View-Color-Data|CL_COLD"
                ;;
        esac
        case $chk_clipboard in
            *COLF*)
                dmmenu_list=$dmmenu_list";View-Color-Function|CL_COLF"
                ;;
        esac
        case $chk_clipboard in
            *BLND*)
                dmmenu_list=$dmmenu_list";View-Blink-Data|CL_BLND"
                ;;
        esac
        case $chk_clipboard in
            *BLNF*)
                dmmenu_list=$dmmenu_list";View-Blink-Function|CL_BLNF"
                ;;
        esac
        case $chk_clipboard in
            *TRND*)
                dmmenu_list=$dmmenu_list";View-Trend-Data|CL_TRND"
                ;;
        esac
        case $chk_clipboard in
            *TRNF*)
                dmmenu_list=$dmmenu_list";View-Trend-Function|CL_TRNF"
                ;;
        esac
        case $chk_clipboard in
            *XPSF*)
                dmmenu_list=$dmmenu_list";View-XPosition-Function|CL_XPSF"
                ;;
        esac
        case $chk_clipboard in
            *YPSF*)
                dmmenu_list=$dmmenu_list";View-YPosition-Function|CL_YPSF"
                ;;
        esac
        case $chk_clipboard in
            *OPTD*)
                dmmenu_list=$dmmenu_list";View-Option-Data|CL_OPTD"
                ;;
        esac
        case $chk_clipboard in
            *OPTF*)
                dmmenu_list=$dmmenu_list";View-Option-Function|CL_OPTF"
                ;;
        esac
        case $chk_clipboard in
            *SELD*)
                dmmenu_list=$dmmenu_list";View-Select-Data|CL_SELD"
                ;;
        esac
        case $chk_clipboard in
            *HLPD*)
                dmmenu_list=$dmmenu_list";View-Help-File-Data|CL_HLPD"
                ;;
        esac
        case $chk_clipboard in
            *KEYD*)
                dmmenu_list=$dmmenu_list";View-Keyboard-Code|CL_KEYD"
                ;;
        esac
        case $chk_clipboard in
            *KBDG*)
                dmmenu_list=$dmmenu_list";View-Keyboard-Groups|CL_KBDG"
                ;;
        esac
        if [ "X$chk_clipboard" = "X" ]
        then
            dmmenu_list=$dmmenu_list"Clipboard-Empty-Exit|X"
        else
            dmmenu_list=$dmmenu_list";Delete-All|CL_DELETE"
        fi
        dmmenu_list=$dmmenu_list");"
    dmmenu_list=$dmmenu_list"ErrorFile|ERROR;"
    dmmenu_list=$dmmenu_list"About|ABOUT;"
    dmmenu_list=$dmmenu_list"Exit|X"
    dmmenu_columns="1"
    dmmenu_options="AOL"
#echo ${DMUTILS}/dmMenu $dmmenu_title $dmmenu_columns \"$dmmenu_list\" $dmmenu_options >/dev/null
    ${DMUTILS}/dmMenu -200 -40 "cC" $dmmenu_title $dmmenu_columns \"$dmmenu_list\" $dmmenu_options
    menu_ret=`cat dmMenu.ret 2>/dev/null`
}

yes_no() {
    echo "\7"
    rm dmNotice.ret 2> /dev/null
    dmnotice_title=$1
    dmnotice_buttons="No|N;Yes|Y"
    dmnotice_options="AOL "
    dmnotice_arg=""
    ${DMUTILS}/dmNotice -200 -40 "cC" $dmnotice_title $dmnotice_buttons $dmnotice_options "Are you sure ?" $dmnotice_args
    yesno=`cat dmNotice.ret`
}
list() {
    rm dmNotice.ret 2> /dev/null
    dmnotice_title=$1
    dmnotice_buttons="Ok|O"
    dmnotice_options="AOL "
    dmnotice_arg=""
    ${DMUTILS}/dmNotice -200 -40 "cC" $dmnotice_title $dmnotice_buttons $dmnotice_options "$2" $dmnotice_args &

#    Notice -O -t $1 "$2"
}

#mkdir $HOME/Dmon 2>/dev/null
#cd $HOME/Dmon
menu $1 $2
case $menu_ret in
     E)
         ans=edit
         lineno=`grep -xn "OBJ: $2" $1 | cut -f1 -d':'`
	     	if test _$TEXT_EDITOR = _vpw.exe
		 	then
         		${TEXT_EDITOR} $1 -l$lineno
         	fi

        if test _$TEXT_EDITOR = _mew32.exe
      then
            echo ${TEXT_EDITOR} /NI $1 /L$lineno
            ${TEXT_EDITOR} /NI $1 /L$lineno
          fi

         	if test _$TEXT_EDITOR = _TextPad.exe
  		 	then
	        	${TEXT_EDITOR} -q $1"($lineno,0)"
	 		fi

	     	if test _$TEXT_EDITOR = _vedit
		 	then
         		pterm -C $HOME/.photon/$PTERM ${TEXT_EDITOR} $1 -l$lineno
         	fi

	     	if test _$TEXT_EDITOR = _med
		 	then
         		pterm -C $HOME/.ph/pterm/$PTERM med +$lineno $1
         	fi

         	if test _$TEXT_EDITOR = _ws
 		 	then
         		pterm -C $HOME/.ph/pterm/$PTERM ws $1 -l$lineno
 	 		fi
		 ;;
     C)
         ans=copy
         rm C_* 2> /dev/null
         awk -F, -f ${DMUTILS}/dmdyncopy.awk copy_type="ALL" objname=$2 $1> dyncopy.txt
         ;;
     C_ALLWITHOUTPARL)
         ans=copy_all_without_parlist
         rm C_* 2> /dev/null
         awk -F, -f ${DMUTILS}/dmdyncopy.awk  copy_type="ALL" objname=$2 $1> dyncopy.txt
         rm C_PARL 2> /dev/null
         ;;
     C_*)
         ans=copy_$2
         awk -F, -f ${DMUTILS}/dmdyncopy.awk objname=$2 copy_type=$menu_ret $1 > dyncopy.txt
         ;;
     P)
         ans=paste
         if test -r dyncopy.txt
         then
             yes_no "Paste->"$2
             if [ "$yesno" = "y" ] || [ "$yesno" = "Y" ]; then
                 awk -F, -f ${DMUTILS}/dmdyncopy.awk  copy_type="NOTHING" objname=$2 $1 > dynobject.txt
                 awk -F, -f ${DMUTILS}/dmdyndelete.awk objname=$2 $1 > dyndelete.txt
                 awk -F, -f ${DMUTILS}/dmdynpaste.awk objname=$2 dyncopy.txt dyndelete.txt > dynpaste.txt
                 cp dynpaste.txt $1
             fi
         else
             Notice -a -E "Can not paste, copy file does not exist !"
         fi
         ;;
     P_ALL_WITHOUT_PARL)
         ans=paste-all-without-parameterlist
         yes_no "Paste...All-Without-Parameter-List->"$2
         if [ "$yesno" = "y" ] || [ "$yesno" = "Y" ]; then
            awk -F, -f ${DMUTILS}/dmdyncopy.awk  copy_type="OBJECT" objname=$2 $1 > dynobject.txt
            awk -F, -f ${DMUTILS}/dmdyndelete.awk objname=$2 $1 > dyndelete.txt
            cp M_PARL dyncopy.txt_tmp 2>/dev/null
            for file in `ls C_*|sort`
            do
               if test "$file" != "C_PARL"
               then
                   cat $file >> dyncopy.txt_tmp
               fi
            done
            awk -F, -f ${DMUTILS}/dmdynpaste.awk objname=$2 dyncopy.txt_tmp dyndelete.txt > dynpaste.txt
            cp dynpaste.txt $1
         fi
         ;;
     P_*)
         ans=paste_$2
         s=`echo $menu_ret | awk -F, -f ${DMUTILS}/dmsubstr.awk first=3`
         yes_no "Paste..."$s"->"$2
         if [ "$yesno" = "y" ] || [ "$yesno" = "Y" ]; then
            rm M_???? 2>/dev/null
            rm dyncopy_txt_tmp 2>/dev/null
            awk -F, -f ${DMUTILS}/dmdyncopy.awk  copy_type="OBJECT" objname=$2 $1 > dynobject.txt
            awk -F, -f ${DMUTILS}/dmdyndelete.awk objname=$2 $1 > dyndelete.txt
            cp "C_"$s "M_"$s
            cp "M_PARL" dyncopy.txt_tmp
            rm "M_PARL"
            for file in `ls M_????|sort`
            do
                cat $file >> dyncopy.txt_tmp
            done
            awk -F, -f ${DMUTILS}/dmdynpaste.awk objname=$2 dyncopy.txt_tmp dyndelete.txt > dynpaste.txt
            cp dynpaste.txt $1
         fi
         ;;
     V)
         ans=view
         list "View:"$2 "`awk -F, -f ${DMUTILS}/dmdynshow.awk objname=$2 $1`"
         ;;
     CL_ALL)
         ans=clipboard...all
         list "Clipboard...View-All" "`cat dyncopy.txt`"
         ;;
     CL_DELETE)
         ans=clipboard...detete
         yes_no "Clipboard...Delete-All"
         if [ "$yesno" = "y" ] || [ "$yesno" = "Y" ]; then
             rm C_*
         fi
         ;;
     CL_*)
         ans=clipboard...$menu_ret
         filename=`echo $menu_ret | awk -F, -f ${DMUTILS}/dmsubstr.awk first=4 `
         list "Clipboard...View-"$filename "`cat C_$filename`"
         ;;
     U)
         ans=undo
         if test -r dynobject.txt
         then
             yes_no "Undo:"$2
             if [ "$yesno" = "y" ] || [ "$yesno" = "Y" ]; then
                 awk -F, -f ${DMUTILS}/dmdyndelete.awk objname=$2 $1 > dyndelete.txt
                 awk -F, -f ${DMUTILS}/dmdynundo.awk objname=$2 dynobject.txt dyndelete.txt > dynundo.txt
                 cp dynundo.txt $1
             fi
         else
             Notice -a -E "Can not undo, object file does not exist !"
         fi
         ;;
     D)
         ans=delete_$2
         yes_no "Delete:"$2
         if [ "$yesno" = "y" ] || [ "$yesno" = "Y" ]; then
             awk -F, -f ${DMUTILS}/dmdyncopy.awk copy_type="NOTHING" objname=$2 $1 > dynobject.txt
             awk -F, -f ${DMUTILS}/dmdyndelete.awk objname=$2 $1 > dyndelete.txt
             cp dyndelete.txt $1
         fi
         ;;
     ERROR)
         ans=error_file

	     	if test _$TEXT_EDITOR = _vpw.exe
		 	then
         		${TEXT_EDITOR} -b $3.err
         	fi

        if test _$TEXT_EDITOR = _mew32.exe
      then
            ${TEXT_EDITOR} /RO $3.err
          fi

          if test _$TEXT_EDITOR = _TextPad.exe
  		 	then
            ${TEXT_EDITOR} -q $3.err
		 	fi

	     	if test _$TEXT_EDITOR = _vedit
		 	then
         		pterm -C $HOME/.photon/$PTERM ${TEXT_EDITOR} -q $3.err
         	fi

	     	if test _$TEXT_EDITOR = _med
		 	then
		 		pterm -C $HOME/.photon/$PTERM ${TEXT_EDITOR} $3.err
         	fi
         	if test _$TEXT_EDITOR = _ws
 		 	then
         		pterm -C $HOME/.photon/$PTERM ${TEXT_EDITOR} $3.err
 		 	fi
         ;;
     ABOUT)
         ans=about
         list "About..." "DYNINFO Utility for D-mon Monitor Editor\n\nVersion: $VER_NO \n\nAddress: ScadaSys Ltd.\n         H-1016 Budapest\n         Czako utca 7.\n    Tel: +36 (1) 212-7052\n E-mail: walter@scadasys.hu"
         ;;
     X)
         exit 1
         ;;
esac
rm M_???? 2>/dev/null
rm *.ret 2>/dev/null
rm *.txt_tmp 2>/dev/null
exit
