###############################################################################
#                          profile for "prim" user
###############################################################################


if (! test -d /Dmon )
then
    ln -sf c:/Dmon /Dmon
    echo making /Dmon directory
fi

if (! test -d /prim_fi )
then
    ln -sf c:/prim_fi /prim_fi
    echo making /prim_fi directory
fi

if (! test -d /prim_devel )
then
    ln -sf c:/prim_devel /prim_devel
    echo making /prim_devel directory
fi

if (! test -d /prim_OPC )
then
    ln -sf c:/prim_OPC /prim_OPC
    echo making /prim_OPC directory
fi

# path for the application
    export DMAPP=/prim_fi

# path for D-mon binary programs
    export DMBIN=/Dmon/bin

# path for D-mon utilities
    export DMUTILS=$DMBIN/../utils

# priority offset for D-mon binary modules
    export DMPRI=0

# D-mon binary program's directories to the PATH
    export PATH=$PATH:./:/Dmon/utils:/Dmon/bin:/Dmon/apiapps:"/cygdrive/c/Program Files/Far":

if test $DMHOME"X" = "X"
then
	cd $DMAPP
fi
