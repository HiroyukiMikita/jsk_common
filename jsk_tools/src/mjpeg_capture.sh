#!/bin/bash

usage_exit() {
    echo "Usage : $0 <stream_url> <output> [-p PORT(8080)] [--gtest_output file] [-t TIME(20sec)]" 1>&2
    exit 1
}

INPUT=$1
OUTPUT=$2
PORT=8080
TIME=20
TIMEOUT=30

if [ -z $INPUT -o -z $OUTPUT ] ; then
  usage_exit
fi

GETOPT=`getopt -o t:p: -l gtest_output: -- "$@"` ; [ $? != 0 ] && usage_exit
eval set -- "$GETOPT"
while true
do
  case $1 in
  --gtest_output)     OUTFILE=$2      ; shift 2 ;;
  -t)                 TIME=$2         ; shift 2 ;;
  -p)                 PORT=$2         ; shift 2 ;;
  -h)   usage_exit ;;
  --)   shift ; break ;;
  *)   shift ; break ;;
  esac
done

OUTFILE=${OUTFILE/xml:/}
touch $OUTFILE

while [ 0 -eq `netstat -antu | grep ${PORT} | wc -l` ]
do
    TIMEOUT=`expr ${TIMEOUT} - 1`
    if [ 0 -eq ${TIMEOUT} ]; then exit; fi
    sleep 1
done

vlc -I dummy $INPUT :sout="#transcode{vcodec=mp2v,vb=4096,acodec=mp2a,ab=192,scale=1,channels=2,deinterlace,audio-sync}:std{access=file, mux=ps,dst=\"$OUTPUT\"}" & (sleep $TIME && kill -INT $!)
