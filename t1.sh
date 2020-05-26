#!/bin/bash
usage(){
  cat << EOF
  This program removes empty lines in a file and replaces lower case characters with upper case characters
  Usage: $0 [target file(s)] 
  Examples:
    $0 --help - print this help
    $0 file1
    $0 file1 file2 file3
EOF
}

if [ "$1" == "--help" ] ; then
  usage
  exit 0
fi

while [ $# -gt 0 ] ; do
  if [ -f $1 -o -h $1 -o -L $1 ] ; then
     FILES+=("$1")   
  fi
  shift   
done

(( ${#FILES[@]} == 0 )) && usage && exit 0

for f in ${FILES[@]}; do  
  unixtime=$(date +%s) ; tmpfile=tmp${unixtime}
  sed -r -e '/^\s+$/d; /^$/d; s/.*/\U&/g'  < $f > $tmpfile
  if [[ $?==0 ]] ; then
     mv $tmpfile $f
     ANSWER+=" ${f}"     
  fi    
done

if [ -n ANSWER ] ; then
  ANSWER="File(s)${ANSWER} are changed"
else 
  ANSWER="No file(s) are changed"
fi

echo $ANSWER
