#!/bin/env bash

#url="http://192.168.0.1/MSYFSDIBYXIWCYTC/userRpm/SystemStatisticRpm.htm?interval=60&autoRefresh=2&sortType=1&Num_per_page=5&Goto_page=1"

url="http://192.168.0.1/userRpm/LoginRpm.htm?Save=Save"
cookie="Authorization=Basic YWRtaW46MjEyMzJmMjk3YTU3YTVhNzQzODk0YTBlNGE4MDFmYzM="
session=$(curl -qH "Cookie: $cookie" $url  2>1 | grep 'http' |sed -E  's/.*href = \"http:\/\/192\.168\.0\.1\/(.*)\/userRpm\/Index.htm";.*/\1/g') 

LOG_IN='TR-IN-U.TXT'
LOG_OUT='TR-OUT-U.TXT'
LOG_TOT='TR-TOT-U.TXT'

CLOG_IN='CUR-IN-U.TXT'
CLOG_OUT='CUR-OUT-U.TXT'
CLOG_TOT='CUR-TOT-U.TXT'

if [ -z "$session" ]; then
 echo session missed
 exit 
fi


#echo $session

url="http://192.168.0.1/$session/userRpm/SystemStatisticRpm.htm"
ref="http://192.168.0.1/$session/userRpm/Index.htm"
acc="text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9"

#echo $url
#echo $ref
is=0


sumtr=0
while IFS= read -r line
do
  # take action on $line #
  if [ "$is" -eq 1 ]; then
   stat=$( echo $line | sed -E 's/",/";/g' | sed -E  's/,//g' | sed  's/"//g' )
   IFS='; ' read -r -a array <<< "$stat"
   in=${array[4]}
   echo "IN: [$in]"
   if [ "${in}" != "" ];then
    sumtr=$(( ${sumtr} + ${in}  ))
   else
    #echo "BREAK"
    break
   fi
  fi
  if [ "$line" == 'var statList = new Array(' ];then
   is=1
  fi

done <<< $( curl -qH "Cookie: $cookie" -H "Referer: $ref" -H 'Accept: $acc' $url 2>1)


in=${sumtr}

#echo IN:$in

if [ -z "${in}"  ];then
 echo "IN Traffic is missesd, exit"
 echo "IN Traffic is missesd, exit" >> log.txt
 exit
fi

if [  "${in}" == "0"  ];then
 echo "IN Traffic is 0, exit"
 echo "IN Traffic is 0, exit" >> log.txt
 exit
fi


prev_in=$(cat $CLOG_IN)

if [ -z "$prev_in" ];then
 prev_in=0
fi

echo "${in}" > $CLOG_IN

delta_in=$(( ${in} - ${prev_in} ))


traff_in=$(cat $LOG_IN)

if [ "$delta_in" -lt 0 ];then
 echo "DELTEA TRAFFIC IN LESS 0"
 delta_in=${in}
fi


tr_in=$(( ${traff_in} + ${delta_in} ))

echo "${in}" > $CLOG_IN

echo "${tr_in}" > $LOG_IN

echo "IN: ${in} bytes"

echo "------------------------"

echo "D IN: ${delta_in} bytes"


echo "------------------------"
echo "TOTAL IN: ${tr_in}B $(( ${tr_in} /1024/1024 ))M  $(( ${tr_in} /1024/1024/1024 ))G $(( ${tr_in} /1024/1024/1024/1024 ))T" 

