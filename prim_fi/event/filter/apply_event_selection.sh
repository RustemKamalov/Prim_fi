#!/bin/sh


bindir=$(echo $0 | sed 's/'$(basename $0)'//g')
outfile=$(echo $1 | sed 's/.txt/_filt.txt/g')

echo "bindir: " $bindir 
echo "outfile: " $outfile 


usage="  Usage:  $0 <src_event_txt_file> \r\n  Output file name is derived from source file name"

if test "x$1" = "x"
then
	 echo -e "\n  Error: Source file was not given.\n" 1>&2
	 echo -e "$usage" 1>&2
	 exit 1
fi
if test ! -s $1
then
	 echo -e "\n  Error: Source file does not exists.\n" 1>&2
	 exit 1
fi

details=$bindir"details/*.txt"

cat $details | grep \"__ | grep -v "//" | awk '{print $1"|"}' | sort > $bindir"event_filter_selection.txt"
cat $1 | awk '
	BEGIN{
		qLineCount=0;
		selectionFile=  "'$bindir'event_filter_selection.txt" ;
		
		selectionCount=0;
		while( getline < selectionFile ){
			gsub(/\r?/,"");
			selectionLines[selectionCount]=$0;
			selectionCount++;
		}
		
		actMatch="";
		idSubsys="";
		for(i=0; i<selectionCount; i++){
			idSubsys =selectionLines[i];
			gsub(/_.*$/,"_",idSubsys);
			if(idSubsys != actMatch){
				print "# subsys filter: " idSubsys
				actMatch = idSubsys;
				selectionMap[actMatch,0]=i;
				selectionMap[actMatch,1]=i;
			} else {
				selectionMap[actMatch,1]=i;
			}
		}
	
	}
	{
		matchedLine = 0;
		gsub(/\r?/,"");
		parTag = "";
		
		if($1 ~ /^Q[0-9]+=/ ){
			matchedLine = 1;	
			if($1 ~ /Q0=/ ){
				qLineCount=0;
			}
			basicLines[qLineCount]=$0;
			modLine = $0;
			gsub(/ s=/," s=__",modLine);
			filterLines[qLineCount]=modLine;
			qLineCount++;
		}
		
		if ($1 ~ /^OBJ=/){
			matchedLine = 1;	

			if($0 ~ /PAR=/){
				parTag = $0;
				gsub(/^.* PAR=/,"",parTag);
				gsub(/ .*$/,"",parTag);
				parTag = parTag"|";
				parlessObjLine = "";
			}else{
				parlessObjLine = $0;
			}
		}

		if($1 ~ /^[ \t]*PAR=/){
			matchedLine = 1;	
			parTag = $1;
			gsub(/^.*PAR=/,"",parTag);
			gsub(/ .*$/,"",parTag);
			gsub(/,.*$/,"",parTag);
			parTag = parTag"|";
		}
		
		if (parTag != "") {
			filterDefined=0;

			idSubsys = parTag;
			gsub(/_.*$/,"_",idSubsys);
			srcStart=0+selectionMap[idSubsys,0];
			srcStop=0+selectionMap[idSubsys,1];

			for(i=srcStart; i <= srcStop; i++){

				srcMid=int((i + srcStop)/2);

				if(parTag < selectionLines[srcMid])	{
					srcStop = srcMid;
				} else if (parTag > selectionLines[srcMid]) {
					i = srcMid;
				}
	
				if(selectionLines[i] == parTag){
					filterDefined = 1;
					print "## filter defined: " parTag ": " selectionLines[i] ;
					break;
				}
				
				
			}
			if (filterDefined){
				for(i=0; i < qLineCount; i++ ){
					print(filterLines[i]);
				}
			} else {
				for(i=0; i < qLineCount; i++ ){
					print(basicLines[i]);
				}
			}
			if(parlessObjLine != ""){
				print parlessObjLine ;
				parlessObjLine = "";
			}
			print $0;
		} 
		
		if(matchedLine == 0){
			print $0;
		}
		
	}' > $outfile
