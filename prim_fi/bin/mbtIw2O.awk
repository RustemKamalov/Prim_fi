BEGIN {
    if (pipefile=="") {
        print "error:no pipefile";
        exit(-1);
        }
    if (outfile=="") {
        print "error:no outfile";
        exit(-1);
        }
    # check if pipefile Exists
    if ((getline < pipefile) != 1) {
        print "error: Can't open pipefile", pipefile;
        exit(-1);
    }
    close(pipefile);

    #temporary objfile
    objfile="obj.temp"
    templine=""
    #if templine not empty then always contains \n at the end: use printf

    txtfile=ARGV[1];
    found_obj=0;
    found_iw=0;
    found_com=0;

    print "mbtIw2O: converting", txtfile, "to", outfile, "using pipe_file", pipefile
    print "#File converted by mbtIw2O" > outfile

    #Field Separator for pipefile
    old_FS=FS
    FS="[ \t]*,[ \t]*"
    #read database tags into array
    num_of_tags=0
    while (getline < pipefile) {
        if ( !match($0, /^[ \t*][#/]/) && $1!="" ) {
            data_tags[num_of_tags]=$1
            tag_types[num_of_tags]=$2
            num_of_tags++
        }
    }

    print num_of_tags " data_tags found in pipe_file", pipefile

    FS=old_FS
}

/^M:.*n=[0-9]+/ {
    if ($0 ~ /o=Iw/) {
        print templine "#Error: mbtIw2O: found n= and o=Iw\n" $0 >> objfile
        print "#Error: found n= and o=Iw" $0
    }
    else {
        print templine "#mbtIw2O: found n=", $0 >> objfile
        print "found n=", $0
        templine=""
        match($0, /n=[0-9]+/)
        num=int(substr($0, RSTART+2, RLENGTH-2))
        sub(/n=[0-9]+/, "")
        match($0, /S=[^ \t]+/)
        tagstr=substr($0, RSTART, RLENGTH)
        tag=substr(tagstr, 3)

        if ( !match($0, /#database/) ) {
            match(tag, /[0-9]+$/)
            tagnum=substr(tag, RSTART)
            tagnumform="%0" RLENGTH "d"
            sub(/[0-9]+$/, "", tag)
            for (i=1; i<num; i++) {
                tagnum=sprintf(tagnumform, tagnum+1)
                tagstr=tagstr "," tag tagnum
            }
        }
        else {
            sub(/#database/, "")
            tag_type=""
            for (data_num=0; data_num<num_of_tags; data_num++) {
                if ( data_tags[data_num]==tag ) {
                    tag_type=tag_types[data_num]
                    break
                }
            }
            if (tag_type=="") {
                print templine "#Error: mbtIw2O: Tag", tag, "not found in pipefile", pipefile >> objfile
                print "#Error: Tag", tag, "not found in pipefile", pipefile
                next
            }
            for (i=1; i<num; i++) {
                data_num++
                new_tag=""
                while (data_num<num_of_tags) {
                    if (tag_type==tag_types[data_num]) {
                        new_tag=data_tags[data_num]
                        break
                    }
                    data_num++
                }
                if (new_tag=="") {
                    print templine "#Error: mbtIw2O: not found", i, ". tag_type:", tag_type, "after Tag" tag, "in pipefile", pipefile >> objfile
                    print "#Error: mbtIw2O: not found", i, ". tag_type:", tag_type, "after Tag" tag, "in pipefile", pipefile
                    next
                }
                tagstr=tagstr "," new_tag
            }
        }
        sub(/S=[^ \t]+/, tagstr)
        print $0 >> objfile
    }
    next
}

/^M:.*o=Iw/ {
    found_iw=1
}

/^[ \t]*FUNC:[ \t]*ELSE[ \t]*Q0[ \t]*;/ {
    found_com=1
}

/^[ \t]*PARL:[ \t]*P0=.._ChDtTrg[0-9][0-9][0-9]/ {
    found_trg=1
}

/^M:.*p=|^#@End/ {
    print templine $0 >> objfile
    templine=""
    next
}


function comment_obj() {
# comment original lines, insert o=O objects in "always_write" mode
    close(objfile)
    print "#mbtIw2O: found o=Iw and FUNC: ELSE Q0;: commenting object" \
        >> outfile

    # comment object and collect obj_head
    obj_head_cp=0
    while (getline < objfile) {
        print "#"$0 >> outfile
        if ($0 ~ /^M:/) { obj_head_cp=0 }
        else if ($0 ~ /^OBJ:/) {
            print "found o=Iw and FUNC: ELSE Q0;: commenting object", $0
            $2=$2 "_tagname_to_change"
            obj_head=$0
            obj_head_cp=1
        }
        else if ($1 ~ /^PARL:/) {
            #it is impossible
        }
        else if ($1 ~ /^CYCL:/) {
            obj_head=obj_head "\n  CYCL: v=0"
        }
        else if ($1 ~ /^FUNC:/) {
            obj_head=obj_head "\n  PARL: parl_to_change" \
                "\n  FUNC: IF P0 && S1 :Q1; ELSE Q0;"
        }
        else if (obj_head_cp && ($0 !~ /^#/) && ($0 !~ /^[ \t]*$/)) {
            obj_head=obj_head "\n" $0
        }
    }
    close(objfile)

    print "inserting o=O objects in \"always_write\" mode"
    print "#mbtIw2O: inserting o=O objects in \"always_write\" mode" >> outfile
    addrfound=0
    while (getline < objfile) {
        if ($0 ~ /^M:.*o=Iw.*S=[^?]/) {
            sub(/o=Iw/,"o=O");
            sub(/d=[0-9][0-9]*/,"");
            gsub(/[,][?]/,"");
            match($0, /S=[^ \t]+/)
            tagname=substr($0, RSTART+2, RLENGTH-2)
            Mx=substr(tagname,1,index(tagname,"_"));
            obj_head_ch=obj_head
            sub(/tagname_to_change/, tagname, obj_head_ch)
            sub(/parl_to_change/, "P0=" Mx "MB1_Enable P1=" tagname, obj_head_ch)
            print obj_head_ch >> outfile
            print $0 >> outfile
        }
        else if ($0 ~ /^#@Address:/) {
            if (addrfound==1) {
                print("#Warning: more #@Address: found, missing #@End") \
                    >> outfile
            }
            print $0 >> outfile
            addrfound=1;
        }
        else if ($0 ~ /^#@End/) {
            if (addrfound!=1) {
                print "#Warning: unexpected #@End found" >> outfile
            }
            print $0 >> outfile
            addrfound=0;
        }
    }
    close(objfile)
    if (addrfound==1) {
        print("#Warning: missing #@End")  >> outfile
    }
}


function change_obj() {
# change original lines (o=Iw->o=I),
# insert o=O objects in "always_writeS" mode
# TagName gets 'S' (Send) to the end !!!

    close(objfile)
    print "#mbtIw2O: found o=Iw and not found FUNC: ELSE Q0;: changing object" \
        >> outfile

    # change object and collect obj_head
    obj_head_cp=0
    while (getline < objfile) {
        sub(/o=Iw/, "o=I");
        print $0 >> outfile
        if ($0 ~ /^M:/) { obj_head_cp=0 }
        else if ($0 ~ /^OBJ:/) {
            print "found o=Iw and not found FUNC: ELSE Q0;: changing object", $0
            $2=$2 "_tagname_to_change"
            obj_head=$0
            obj_head_cp=1
        }
        else if ($1 ~ /^PARL:/) {
            obj_head=obj_head "\n  PARL: parl_to_change"
        }
        else if ($1 ~ /^CYCL:/) {
            obj_head=obj_head "\n  CYCL: v=0"
        }
        else if ($1 ~ /^FUNC:/) {
            obj_head=obj_head "\n  FUNC: IF P0 && S1 :Q1; ELSE Q0;"
        }
        else if (obj_head_cp && ($0 !~ /^#/) && ($0 !~ /^[ \t]*$/)) {
            obj_head=obj_head "\n" $0
        }
    }
    close(objfile)

    print "inserting o=O objects in \"always_writeS\" mode"
    print "#mbtIw2O: inserting o=O objects in \"always_writeS\" mode" >> outfile
    addrfound=0
    while (getline < objfile) {
        if ($0 ~ /^M:.*o=Iw.*S=[^?]/) {
            sub(/o=Iw/,"o=O");
            sub(/d=[0-9][0-9]*/,"");
            gsub(/[,][?]/,"");
            match($0, /S=[^ \t]+/)
            tagname=substr($0, RSTART+2, RLENGTH-2) "S"
            sub(/S=[^ \t]+/, "S=" tagname)
            if (Mx=="") {
                print("#Warning: Object has no MB Enable tag, using prefix from tagname") >> outfile
                Mx=substr(tagname,1,index(tagname,"_"));
            }
            obj_head_ch=obj_head
            sub(/tagname_to_change/, tagname, obj_head_ch)
            sub(/parl_to_change/, "P0=" Mx "MB1_Enable P1=" tagname, obj_head_ch)
            print obj_head_ch >> outfile
            print $0 >> outfile
        }
        else if ($0 ~ /^#@Address:/) {
            if (addrfound==1) {
                print("#Warning: more #@Address: found, missing #@End") \
                    >> outfile
            }
            print $0 >> outfile
            addrfound=1;
        }
        else if ($0 ~ /^#@End/) {
            if (addrfound!=1) {
                print "#Warning: unexpected #@End found" >> outfile
            }
            print $0 >> outfile
            addrfound=0;
        }
    }
    close(objfile)
    if (addrfound==1) {
        print("#Warning: missing #@End")  >> outfile
    }
}


function copy_obj() {
# simply copy object
    close(objfile);
    while (getline < objfile) {
        print $0 >> outfile
    }
    close(objfile);
}


/^OBJ:/ {
    objline=$0;
    if (found_obj==0) {
        found_obj=1;
    }
    else {
        if (found_iw==1) {
            if (found_com==1) {
                comment_obj();
            }
            else if (found_trg==1) {
                change_obj();
            }
            else {
                change_obj();
                # if there is no ChDtTrg maybe another solution needed
                #notrg_obj();
            }
        }
        else {
            copy_obj()
        }
        found_trg=0;
        found_com=0;
        found_iw=0;
    }
    if (templine!="") {
        printf "%s", templine >> outfile
        templine=""
    }
    print objline > objfile
    Mx=""
    next
}

/^[ \t]*PARL:/ {
    if ( match($0, /P[0-9+]+=[^ _]+_MB[12]*_Enable/) ) {
        Mx=substr($0, RSTART, RLENGTH)
        match(Mx, /=[^ _]+_/)
        Mx=substr(Mx, RSTART+1, RLENGTH-1)
    }
    else {
        print("#Warning: Object without MB Enable tag") >> outfile
    }
}

{
    if (found_obj==0) { print $0 >> outfile }
    else { templine=templine $0 "\n" }
}


END {
    if (found_obj) {
        if (found_iw==1) {
            if (found_com==1) {
                comment_obj();
            }
            else if (found_trg==1) {
                change_obj();
            }
            else {
                notrg_obj();
            }
        }
        else {
            copy_obj()
        }
    }
    printf "%s", templine >> outfile

    close(objfile);
    print "mbtIw2O: ", txtfile, "to", outfile, "done"
    system("rm " objfile);
    close(outfile);
    errno=0; warno=0;
    while (getline < outfile) {
        if ($0 ~ /^#Error/) { errno++ }
        else if ($0 ~ /^#Warning/) { warno++ }
    }
    close(outfile);
    print errno " errors, " warno " warnings"
    if ((errno)!=0) { exit -1 }
}

