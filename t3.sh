#!/bin/bash
usage(){
  cat << EOF
  This program creates directory and files in it
  Usage: $0 [-d directory_name file_name(s)] 
  Examples:
    $0 --help - print this help
    $0 -d /tmp/task_3
    $0 file1 file2 -d dire file3
    $0 -d file1 file2 file3
    $0 -d /tmp/task_3 file1 file2.sh file3
    $0 -d /tmp/task_3 -d /tmp/task_3_2 file1 file2.sh file3 - incorrect syntax, only one -d parameter is allowed 
EOF
}
 
if [ $# -eq 0 ] ; then
  usage
  exit 0   
fi


IFS='#'               
while [[ $# -gt 0 ]] ; do
  case $1 in
  --help)
        usage
        exit 0
  ;;
  -d)    
    if [ -z $DIRNAME ] ; then
       shift
       DIRNAME="$1"
       if [ "${DIRNAME:0:1}" != "/" -a ${#DIRNAME} -gt 0 ] ; then 
         DIRNAME="./$DIRNAME"
       fi
       shift
       continue
    else 
       echo '...incorrect syntax, only one -d parameter is allowed'
       exit 0
    fi
  ;;
  *)
    if [ -n $DIRNAME -a -d $DIRNAME ] ; then       
       currentFile="$DIRNAME/$1" 
       if [ -f $currentFile -o -h $currentFile -o -L $currentFile ] ; then
          MESSAGES+=("file $currentFile already exists#")
          shift  
          continue  
       fi
    fi 
        
    FILES+=("$1")    
    shift
    continue
  ;;
  esac
done


if [ -z $DIRNAME ] ; then
  echo '...incorrect syntax, directory name is missing'
  exit 0
fi


if [ -d $DIRNAME ] ; then
  echo "directory ${DIRNAME} already exists"          
else   
  echo "creating directory ${DIRNAME}" 
  mkdir -p $DIRNAME
fi


if [ ${#FILES[@]} -gt 0 ] ; then
  echo "creating files in ${DIRNAME}"
  for f in ${FILES[@]}; do  
      touch "$DIRNAME/$f"
      xPermission=''
      if [ "${f:(-3)}" == ".sh" -a ${#f} -gt 3 ] ; then
         sudo chmod +x "$DIRNAME/$f"
         xPermission=' (given permission to execute)'
      fi
      echo "$f$xPermission"
  done
fi


if [ ${#MESSAGES[@]} -gt 0 ] ; then
  for msg in ${MESSAGES[@]}; do 
     if [ ${#msg} -gt 0 ] ; then 
       echo $msg
     fi
  done
fi

