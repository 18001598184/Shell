#!/bin/bash
source /etc/profile
cd /home/kafka/
KAFKA_GROUP=`bin/kafka-consumer-groups.sh --bootstrap-server 127.0.0.1:9092 --list`
kafka-consumer-groups.sh --bootstrap-server 127.0.0.1:9092 --group $KAFKA_GROUP --describe >topic.log
i=0
while read -r line
do
let i=i+1
LAG=`echo $line |awk '{print $5}'`
topic_name=`echo $line |awk '{print $1}'`
if [[ $i > 2 ]]&&[[ $LAG >100000 ]];then
echo $topic_name -- $LAG
fi
done<topic.log
