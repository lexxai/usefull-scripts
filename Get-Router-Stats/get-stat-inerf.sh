#!/bin/env bash

#url="http://192.168.0.1/MSYFSDIBYXIWCYTC/userRpm/SystemStatisticRpm.htm?interval=60&autoRefresh=2&sortType=1&Num_per_page=5&Goto_page=1"

url="http://192.168.0.1/userRpm/LoginRpm.htm?Save=Save"
cookie="Authorization=Basic YWRtaW46MjEyMzJmMjk3YTU3YTVhNzQzODk0YTBlNGE4MDFmYzM="
session=$(curl -qH "Cookie: $cookie" $url  2>1 | grep 'http' |sed -E  's/.*href = \"http:\/\/192\.168\.0\.1\/(.*)\/userRpm\/Index.htm";.*/\1/g') 

LOG_IN='TR-IN.TXT'
LOG_OUT='TR-OUT.TXT'
LOG_TOT='TR-TOT.TXT'

CLOG_IN='CUR-IN.TXT'
CLOG_OUT='CUR-OUT.TXT'
CLOG_TOT='CUR-TOT.TXT'

if [ -z "${session}" ]; then
 echo session missed
 exit 
fi



#echo $session


url="http://192.168.0.1/$session/userRpm/StatusRpm.htm"
ref="http://192.168.0.1/$session/userRpm/Index.htm"
acc1="text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9"

#echo $url
#echo $ref
is=0


while IFS= read -r line
do
  # take action on $line #
  if [ "$is" -eq 1 ]; then
   stat=$( echo $line | sed -E 's/",/";/g' | sed -E  's/,//g' | sed  's/"//g' )
   IFS='; ' read -r -a array <<< "$stat"
   break
  fi
  if [ "$line" == 'var statistList = new Array(' ];then 
   is=1
  fi

done <<< $( curl -qH "Cookie: $cookie" -H "Referer: $ref" -H 'Accept: $acc' $url 2>1)


for element in "${array[@]}"
do
    echo "$element"
done

in=${array[0]}
out=${array[1]}

if [ -z "${in}"  ];then
 echo "IN Traffic is missesd, exit"
 exit
fi


total=$(( ${in} + ${out} ))

prev_in=$(cat $CLOG_IN)
prev_out=$(cat $CLOG_OUT)
#prev_tot=$(cat $CLOG_TOT)
prev_tot=$(( ${prev_in} + ${prev_out} ))

echo "${in}" > $CLOG_IN
echo "${out}" > $CLOG_OUT
echo "${total}" > $CLOG_TOT

delta_in=$(( ${in} - ${prev_in} ))
delta_out=$(( ${out} - ${prev_out} ))
delta_total=$(( ${total} - ${prev_tot} ))


traff_in=$(cat $LOG_IN)
traff_out=$(cat $LOG_OUT)
traff_tot=$(( ${traff_in} + ${traff_out} ))

if [ "$delta_in" -lt 0 ];then
 echo "DELTEA TRAFFIC IN LESS 0"
 delta_in=${in}
fi

if [ "$delta_out" -lt 0 ];then
 echo "DELTEA TRAFFIC OUT LESS 0"
 delta_out=${out}
fi

if [ "$delta_total" -lt 0 ];then
 echo "DELTEA TRAFFIC TOTAL LESS 0"
 delta_total=${tot}
fi



tr_in=$(( ${traff_in} + ${delta_in} ))
tr_out=$(( ${traff_out} + ${delta_out} ))
tr_total=$(( ${traff_tot} + ${delta_total} ))





echo "${in}" > $CLOG_IN
echo "${out}" > $CLOG_OUT
echo "${total}" > $CLOG_TOT


echo "${tr_in}" > $LOG_IN
echo "${tr_out}" > $LOG_OUT
echo "${tr_total}" > $LOG_TOT



echo "IN: ${in} bytes"
echo "OUT: ${out} bytes"
echo "TOTAL: ${total} bytes"

echo "------------------------"

echo "D IN: ${delta_in} bytes"
echo "D OUT: ${delta_out} bytes"
echo "D TOTAL: ${delta_total} bytes"


echo "------------------------"
echo -e "TOTAL IN:\t${tr_in}B \t $(( ${tr_in} / 1024 / 1024 ))M \t $(( ${tr_in} / 1024 / 1024 /1024 ))G $(( ${tr_in} /1024/1024/1024/1024 ))T" 
echo -e "TOTAL OUT:\t${tr_out}B \t $(( ${tr_out} / 1024 / 1024 ))M "
echo -e "TOTAL TOT:\t${tr_total}B \t $(( ${tr_total} /1024/1024 ))M \t $(( ${tr_total} /1024/1024/1024 ))G $(( ${tr_total} /1024/1024/1024/1024 ))T" 

