#!/bin/bash

FORMATSTRING=":: %6s :: %30s :: %6s :: %15.15s :: %6s :: %15.15s :: %6s :: %15s ::"
ADDRESSFILTER="."

while [[ $# -gt 0 ]]; do
   case $1 in
      -p|--pid)
         shift 1
         if [[ $1 =~ ^[0-9][0-9]*$ ]]; then
            PIDLIST=$1
         fi
      ;;
      -a|--address)
         shift 1
         ADDRESSFILTER="$1"
      ;;
   esac
   shift 1
done

if [[ -z $PIDLIST ]]; then
   PIDLIST=$(ps h -C php-fpm -o lwp --sort stat)
fi

printf "\x0A${FORMATSTRING}\x0A" "FPM" "FPM " "HTTP" "SOURCE IP" "SOURCE" "LOCAL IP" "LOCAL" "CONNECTION"
printf "${FORMATSTRING}\x0A\x0A" "PID" "SOCKET NAME" "PID" "ADDRESS" "PORT" "ADDRESS" "PORT" "STATUS"

for PID in $PIDLIST ; do

   LSOFSTRING="$(lsof -aXUlc php-fpm -p ${PID} -d^0-2 -u^root -f -- /dev/shm/*-php.sock 2>/dev/null | tail -n1)"
   LSOFSOCKET=$(echo $LSOFSTRING | awk '{print $8}')
   FPMSOCKETNAME=$(echo $LSOFSTRING | awk '{print $9}')

   if [[ -n $LSOFSOCKET ]]; then
      HTTPSOCKET=$(grep -A1 ${LSOFSOCKET} /proc/net/unix | awk 'BEGIN{f = 1} f && NR == 2{f = 0; print $NF}')
         HTTPPID=$(lsof -alXU -d^0-2 -c httpd 2>/dev/null | awk -v a=$HTTPSOCKET 'BEGIN{f = 1} f && $8 == a{print $2}')
         HTTPIPPORT=$(lsof -alPni:80 -sTCP:^LISTEN -p${HTTPPID} 2>/dev/null | awk '/->/{split($9,a,"->"); print a[1],"-",a[2],"-",$NF}')
      if [[ -n ${HTTPIPPORT} ]]; then
         FROMHTTPIP=$(echo $HTTPIPPORT | cut -d\- -f2 | cut -d\: -f1 | tr -d " ")
         FROMHTTPPORT=$(echo $HTTPIPPORT | cut -d\- -f2 | cut -d\: -f2 | tr -d " ")
         TOHTTPIP=$(echo $HTTPIPPORT | cut -d\- -f1 | cut -d\: -f1 | tr -d " ")
         TOHTTPPORT=$(echo $HTTPIPPORT | cut -d\- -f1 | cut -d\: -f2 | tr -d " ")
         HTTPCONSTATUS=$(echo $HTTPIPPORT | cut -d\- -f3 | cut -d\( -f2 | cut -d\) -f1 | tr -d " ")
         if [[ $FROMHTTPIP =~ $ADDRESSFILTER ]]; then
            printf "${FORMATSTRING}\x0A" "$PID" "$FPMSOCKETNAME" "$HTTPPID" "$FROMHTTPIP" "$FROMHTTPPORT" "$TOHTTPIP" "$TOHTTPPORT" "$HTTPCONSTATUS"
         fi
      fi
   fi

done

printf "\x0A"
