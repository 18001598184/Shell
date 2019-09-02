IP=`/sbin/ifconfig eth0 | grep "inet addr" | cut -f 2 -d ":" | cut -f 1 -d " "`
count=`ps -ef|grep tomcat |grep Trs-web|grep -v "grep" |wc -l`
count_webpid=`netstat -anp|grep 8080|awk '{printf $7}'|cut -d/ -f1 |wc -l`
Trs_WEB_PID=`netstat -anp|grep 8080|awk '{printf $7}'|cut -d/ -f1`
#echo $count
#echo $count_pid
#echo $Trs_WEB_PID
if [[ $count -eq 1 ]]||[[ $count_webpid -eq 1 ]]; then
        echo "stop Trs-web process....."
        netstat -anp|grep 8080|awk '{printf $7}'|cut -d/ -f1 | xargs kill -9
	sleep 2
        echo "start Trs-web process....."
	su - sgrd -c /home/sgrd/Trs-web/bin/startup.sh
        echo "<<${IP}>>Alarming time:${now_time} Trs-wifi process is down,Now start it"|mail -s "Process Trs-wifi restart alarming" 18001598184@163.com
else
   echo "Trs-web is running....."
fi
