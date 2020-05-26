#!/bin/bash
usage(){
  cat << EOF
  This program outputs failed authorization attempts from the log file /var/log/auth.log
  Usage: $0 [number of last failed attempts] 
  Examples:
    $0 --help - print this help
    $0 10 - shows the last 10 attempts
    $0 - shows all failed attempts from the log file
EOF
}

if [ $# -gt 1 ] ; then
  usage
  exit 0
fi

if [ "$1" == "--help" ] ; then
  usage
  exit 0
fi

if [ $# -eq 1 ] ; then
  if  [[ ! $1 =~ [1-9][0-9]* ]] ; then 
    usage
    exit 0
  fi
fi

unixtime=$(date +%s)
tmpfile=tmplogs${unixtime}

cat /var/log/auth.log | 
grep -P '^.*authentication failure;.*$' | 
sed -e 's/^\([a-zA-Z]\+\s[0-9][0-9]\s[0-9][0-9]:[0-9][0-9]:[0-9][0-9]\s\).*\(tty=\S\+\).*\(user=\S\+\).*$/\1 \2 \3/' | 
awk '{print $1" "$2" "$3" authentication failure: "$5" by "$4 "#"}' > $tmpfile 

MASS=()
IFS='#'
while read myline ; do 
  MASS+=("$myline") 
done < $tmpfile

rm $tmpfile


if [ ${#MASS[@]} -eq 0 ] ; then
  echo 'There are no records of failed login attempts in the log file'
  exit 0
fi

if [ $# -eq 0 ] ; then
  startRecord=0
else
  startRecord=$((${#MASS[@]}-$1))    
fi

if [ $startRecord -lt 0 ] ; then
  startRecord=0
  echo "There are only ${#MASS[@]} records in the log file:"
fi

for ((i=$startRecord; i < ${#MASS[@]}; i++)) ; do
 echo ${MASS[$i]}
done
