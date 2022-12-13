BEGIN { 
    if (tmpl=="") {
        print "error:no tmpl file";
        exit(-1);
        }
    if (out=="") {
        print "error:no out (math_marsh.gv) file";
        exit(-1);
        }
    if (ARGC<2) {
        print "error:no infile (gvmap)";
        exit(-1);
    }
    print("#/@Marshroute status") > out;
    print("Marshroute gv math file open:", out);
    err=0;
}


/^MR_GV[^ ]*Input/ {
    GVInputTag=$1;
    GVStatTag=$2;
    sub(/Name$/,"",GVStatTag);
    PLCID=GVStatTag;
    sub(/_.*$/,"_",PLCID);
    found=0;
    while (getline < tmpl) {
        if (match($0,"^# GVInput for.*" PLCID)) {
            found=1;
            print $0 >> out;
        }
        else if (found!=0) {
            if (match($0,"^# GVInput for.*")) { break; }
            gsub(/\$GVInput/,GVInputTag);
            gsub(/\$GIStat/,GVStatTag);
            print $0 >> out;
        }
    }
    close(tmpl)
    if (found!=0) {
        print(GVInputTag, GVStatTag, "math done with", PLCID);
    }
    else {
        print(GVInputTag, GVStatTag, "ERROR! Not found", PLCID);
        err++;
    }
}


END {
    if (err!=0) {
        print("#Marshroute status end,", err, "errors!") > out;
        print("Marshroute gv math file", out, "done," err, "errors!");
    }
    else {
        print("#Marshroute status end") > out;
        print("Marshroute gv math file", out, "done, no errors");
    }
}
