#!/bin/bash
##############################################
#Author: Wangzhengyu - 18001598184@163.com
#QQ:94136676
#Last modified: 2018-12-29 13:00
#Filename: jiankong.sh
#Description: 
##############################################
source /etc/profile
#获取cpu使用率
#cpuUsage=`top -n 1 | awk -F ‘[ %]+‘ ‘NR==3 {print $2}‘`
cpuUsage=`top -bn 1|awk -F '[, %]+' 'NR==3 {print 100-$8}'`
#获取磁盘使用率
#data_name="/dev/sda3"
#diskUsage=`df -h | grep $data_name | awk -F '[ %]+' '{print $5}'`
diskUsage=`df -h|awk -F '[ %]+' '/\/home$/{print $5}'`
#logFile=./jiankong.log
tmpFile=./tmpFile.log
IP=`/sbin/ifconfig eth0 | grep "inet addr" | cut -f 2 -d ":" | cut -f 1 -d " "`
#获取内存情况
mem_total=`free -m | awk -F '[ :]+' 'NR==2{print $2}'`
mem_used=`free -m | awk -F '[ :]+' 'NR==3{print $3}'`
#统计内存使用率
mem_used_persent=`awk 'BEGIN{printf "%.0f\n",('$mem_used'/'$mem_total')*100}'`
#获取报警时间
now_time=`date '+%F %T'`
site='ZhanJiang'
mobile='18001598184'
email_address='18001598184@163.com'
a=`echo "${cpuUsage} > 80"|bc`
b=`echo "${diskUsage} > 80"|bc`
c=`echo "${mem_used_persent} > 80"|bc`
function send_mail(){
        mail -s "${site}_Monitor Alarming" ${email_address} < ./${tmpFile}
}
function check(){
#浮点数比较大小不能使用此种判断方法
#        if [[ ${cpuUsage} > 80 ]] || [[ ${diskUsage} > 80 ]] || [[ ${mem_used_persent} > 80 ]];then
#浮点数比较大小采用以下判断方法
        if [[ $a -eq 1 ]] || [[ $b -eq 1 ]] || [[ $c -eq 1 ]];then
                echo "<<${site}_${IP}>>Alarming time:${now_time}" | tee -a $tmpFile
                echo "CPUUsage:${cpuUsage}% --> DiskUsage:${diskUsage}% --> Memory_used_persent:${mem_used_persent}%" | tee -a $tmpFile
                send_mail
        fi
#  -----------------------  4G   ------------------------#
count=`ps -ef | grep python | grep ftp_4g | grep -v "grep" | wc -l`
if [ $count -eq 0 ];then
   echo "${now_time} start ftp_4g process....."
   su - oracle -c 'cd ./pro_zm_script/pro_4g;nohup ./ftp_4g.sh &'
   echo "<<${site}_${IP}>>Alarming time:${now_time} ftp_4g process is down,Now start it"|mail -s "${site} Process ftp_4g restart alarming" ${email_address}
   su - oracle <<EOF
        sqlplus -S trs/trs123@trsdb
        insert into t_alarm_msg (phone_number,msg_body,send_type,send_flag,insert_time) values('${mobile}','${site} ftp_4g process is down,Now start it!',0,0,sysdate);
        commit;
        exit;
EOF
else
   echo "${now_time} ftp_4g is running....."
fi

count=`ps -ef | grep python | grep data_4g_db | grep -v "grep" | wc -l` 
if [ $count -eq 0 ]; then
   echo "${now_time} start data_4g_db.sh process....."
   su - oracle -c 'cd ./pro_zm_script/pro_4g;nohup ./data_4g_db.sh &'
   echo "<<${site}_${IP}>>Alarming time:${now_time} data_4g_db process is down,Now start it"|mail -s "${site} Process data_4g_db restart alarming" ${email_address}
   su - oracle <<EOF
        sqlplus -S trs/trs123@trsdb
        insert into t_alarm_msg (phone_number,msg_body,send_type,send_flag,insert_time) values('${mobile}','${site} data_4g_db process is down,Now start it!',0,0,sysdate);
        commit;
        exit;
EOF
else
   echo "${now_time} data_4g_db is running....."
fi

count=`ps -ef | grep python | grep device_4g_db | grep -v "grep" | wc -l`
if [ $count -eq 0 ]; then
   echo "${now_time} start device_4g_db.sh process....."
   su - oracle -c 'cd ./pro_zm_script/pro_4g;nohup ./device_4g_db.sh &'
   echo "<<${site}_${IP}>>Alarming time:${now_time} device_4g_db process is down,Now start it"|mail -s "${site} Process device_4g_db restart alarming" ${email_address}
   su - oracle <<EOF
        sqlplus -S trs/trs123@trsdb
        insert into t_alarm_msg (phone_number,msg_body,send_type,send_flag,insert_time) values('${mobile}','${site} device_4g_db process is down,Now start it!',0,0,sysdate);
        commit;
        exit;
EOF
else
   echo "${now_time} device_4g_db is running....."
fi

#  ---------------------  2G  --------------------------#
count=`ps -ef | grep python | grep ftp_2g | grep -v "grep" | wc -l`
if [ $count -eq 0 ]; then
   echo "${now_time} start ftp_2g.sh process....."
   su - oracle -c 'cd ./pro_zm_script/pro_2g;nohup ./ftp_2g.sh &'
   echo "<<${site}_${IP}>>Alarming time:${now_time} ftp_2g process is down,Now start it"|mail -s "${site} Process ftp_2g restart alarming" ${email_address}
   su - oracle <<EOF
        sqlplus -S trs/trs123@trsdb
        insert into t_alarm_msg (phone_number,msg_body,send_type,send_flag,insert_time) values('${mobile}','${site} ftp_2g process is down,Now start it!',0,0,sysdate);
        commit;
        exit;
EOF
else
   echo "${now_time} ftp_2g is running....."
fi

count=`ps -ef | grep python | grep data_2g_db | grep -v "grep" | wc -l`
if [ $count -eq 0 ]; then
   echo "${now_time} start data_2g_db.sh process....."
   su - oracle -c 'cd ./pro_zm_script/pro_2g;nohup ./data_2g_db.sh &'
   echo "<<${site}_${IP}>>Alarming time:${now_time} data_2g_db process is down,Now start it"|mail -s "${site} Process data_2g_db restart alarming" ${email_address}
   su - oracle <<EOF
        sqlplus -S trs/trs123@trsdb
        insert into t_alarm_msg (phone_number,msg_body,send_type,send_flag,insert_time) values('${mobile}','${site} data_2g_db process is down,Now start it!',0,0,sysdate);
        commit;
        exit;
EOF
else
   echo "${now_time} data_2g_db is running....."
fi

count=`ps -ef | grep python | grep device_2g_db | grep -v "grep" | wc -l`
if [ $count -eq 0 ]; then
   echo "${now_time} start device_2g_db.sh process....."
   su - oracle -c 'cd ./pro_zm_script/pro_2g;nohup ./device_2g_db.sh &'
   echo "<<${site}_${IP}>>Alarming time:${now_time} device_2g_db process is down,Now start it"|mail -s "${site} Process device_2g_db restart alarming" ${email_address}
   su - oracle <<EOF
        sqlplus -S trs/trs123@trsdb
        insert into t_alarm_msg (phone_number,msg_body,send_type,send_flag,insert_time) values('${mobile}','${site} device_2g_db process is down,Now start it!',0,0,sysdate);
        commit;
        exit;
EOF
else
   echo "${now_time} device_2g_db is running....."
fi

#------------------     WIFI  --------------------------#
count=`ps -ef | grep python | grep ftp_wifi | grep -v "grep" | wc -l`
if [ $count -eq 0 ]; then
   echo "${now_time} start ftp_wifi.sh process....."
   su - oracle -c 'cd ./pro_zm_script/pro_wifi;nohup ./ftp_wifi.sh &'
   echo "<<${site}_${IP}>>Alarming time:${now_time} ftp_wifi process is down,Now start it"|mail -s "${site} Process ftp_wifi restart alarming" ${email_address}
   su - oracle <<EOF
        sqlplus -S trs/trs123@trsdb
        insert into t_alarm_msg (phone_number,msg_body,send_type,send_flag,insert_time) values('${mobile}','${site} ftp_wifi process is down,Now start it!',0,0,sysdate);
        commit;
        exit;
EOF
else
   echo "${now_time} ftp_wifi is running....."
fi

count=`ps -ef | grep python | grep ftp_device_wifi | grep -v "grep" | wc -l`
if [ $count -eq 0 ]; then
   echo "${now_time} start ftp_device_wifi process....."
   su - oracle -c 'cd ./pro_zm_script/pro_wifi;nohup ./ftp_device_wifi.sh &'
   echo "<<${site}_${IP}>>Alarming time:${now_time} ftp_device_wifi process is down,Now start it"|mail -s "${site} Process ftp_device_wifi restart alarming" ${email_address}
   su - oracle <<EOF
        sqlplus -S trs/trs123@trsdb
        insert into t_alarm_msg (phone_number,msg_body,send_type,send_flag,insert_time) values('${mobile}','${site} ftp_device_wifi process is down,Now start it!',0,0,sysdate);
        commit;
        exit;
EOF
else
   echo "${now_time} ftp_device_wifi is running....."
fi

count=`ps -ef | grep python | grep data_wifi_db | grep -v "grep" | wc -l`
if [ $count -eq 0 ]; then
   echo "${now_time} start data_wifi_db process....."
   su - oracle -c 'cd ./pro_zm_script/pro_wifi;nohup ./data_wifi_db.sh &'
   echo "<<${site}_${IP}>>Alarming time:${now_time} data_wifi_db process is down,Now start it"|mail -s "${site} Process data_wifi_db restart alarming" ${email_address}
   su - oracle <<EOF
        sqlplus -S trs/trs123@trsdb
        insert into t_alarm_msg (phone_number,msg_body,send_type,send_flag,insert_time) values('${mobile}','${site} data_wifi_db process is down,Now start it!',0,0,sysdate);
        commit;
        exit;
EOF
else
   echo "${now_time} data_wifi_db is running....."
fi

count=`ps -ef | grep python | grep device_wifi_info | grep -v "grep" | wc -l`
if [ $count -eq 0 ]; then
   echo "${now_time} start device_wifi_info process....."
   su - oracle -c 'cd ./pro_zm_script/pro_wifi;nohup ./device_wifi_info.sh &'
   echo "<<${site}_${IP}>>Alarming time:${now_time} device_wifi_info process is down,Now start it"|mail -s "${site} Process device_wifi_info restart alarming" ${email_address}
   su - oracle  <<EOF
        sqlplus -S trs/trs123@trsdb
        insert into t_alarm_msg (phone_number,msg_body,send_type,send_flag,insert_time) values('${mobile}','${site} device_wifi_info process is down,Now start it!',0,0,sysdate);
        commit;
        exit;
EOF
else
   echo "${now_time} device_wifi_info is running....."
fi

#------------------  DW   --------------------------#
count=`ps -ef | grep python | grep ftp_dw | grep -v "grep" | wc -l`
if [ $count -eq 0 ]; then
   echo "${now_time} start ftp_dw process....."
   su - oracle -c 'cd ./pro_zm_script/pro_dw;nohup ./ftp_dw.sh &'
   echo "<<${site}_${IP}>>Alarming time:${now_time} ftp_dw process is down,Now start it"|mail -s "${site} Process ftp_dw restart alarming" ${email_address}
   su - oracle  <<EOF
        sqlplus -S trs/trs123@trsdb
        insert into t_alarm_msg (phone_number,msg_body,send_type,send_flag,insert_time) values('${mobile}','${site} ftp_dw process is down,Now start it!',0,0,sysdate);
        commit;
        exit;
EOF
else
   echo "${now_time} ftp_dw is running....."
fi

count=`ps -ef | grep python | grep dw_db | grep -v "grep" | wc -l`
if [ $count -eq 0 ]; then
   echo "${now_time} start dw_db process....."
   su - oracle -c 'cd ./pro_zm_script/pro_dw;nohup ./dw_db.sh &'
   echo "<<${site}_${IP}>>Alarming time:${now_time} dw_db process is down,Now start it"|mail -s "${site} Process dw_db restart alarming" ${email_address}
   su - oracle  <<EOF
        sqlplus -S trs/trs123@trsdb
        insert into t_alarm_msg (phone_number,msg_body,send_type,send_flag,insert_time) values('${mobile}','${site} dw_db process is down,Now start it!',0,0,sysdate);
        commit;
        exit;
EOF
else
   echo "${now_time} dw_db is running....."
fi

#------------------   pro_collect   --------------------------#
count=`ps -ef | grep python | grep data_sg | grep -v "grep" | wc -l`
if [ $count -eq 0 ]; then
   echo "${now_time} start data_sg process....."
   su - oracle -c 'cd ./pro_collect;nohup ./data_sg.sh &'
   echo "<<${site}_${IP}>>Alarming time:${now_time} data_sg process is down,Now start it"|mail -s "${site} Process data_sg restart alarming" ${email_address}
   su - oracle  <<EOF
        sqlplus -S trs/trs123@trsdb
        insert into t_alarm_msg (phone_number,msg_body,send_type,send_flag,insert_time) values('${mobile}','${site} data_sg process is down,Now start it!',0,0,sysdate);
        commit;
        exit;
EOF
else
   echo "${now_time} data_sg is running....."
fi

count=`ps -ef | grep python | grep data_wifi_sg | grep -v "grep" | wc -l`
if [ $count -eq 0 ]; then
   echo "${now_time} start data_wifi_sg process....."
   su - oracle -c 'cd ./pro_collect;nohup ./data_wifi_sg.sh &'
   echo "<<${site}_${IP}>>Alarming time:${now_time} data_sg process is down,Now start it"|mail -s "${site} Process data_wifi_sg restart alarming" ${email_address}
   su - oracle  <<EOF
        sqlplus -S trs/trs123@trsdb
        insert into t_alarm_msg (phone_number,msg_body,send_type,send_flag,insert_time) values('${mobile}','${site} data_wifi_sg process is down,Now start it!',0,0,sysdate);
        commit;
        exit;
EOF
else
   echo "${now_time} data_wifi_sg is running....."
fi

count=`ps -ef | grep python | grep device_sg | grep -v "grep" | wc -l`
if [ $count -eq 0 ]; then
   echo "${now_time} start device_sg process....."
   su - oracle -c 'cd ./pro_collect;nohup ./device_sg.sh &'
   echo "<<${site}_${IP}>>Alarming time:${now_time} device_sg process is down,Now start it"|mail -s "${site} Process device_sg restart alarming" ${email_address}
   su - oracle  <<EOF
        sqlplus -S trs/trs123@trsdb
        insert into t_alarm_msg (phone_number,msg_body,send_type,send_flag,insert_time) values('${mobile}','${site} device_sg process is down,Now start it!',0,0,sysdate);
        commit;
        exit;
EOF
else
   echo "${now_time} device_sg is running....."
fi


#------------------  Trs-TranRunsTX   --------------------------#
count=`ps -ef|grep tomcat |grep Trs-TranRunsTX|grep -v "grep" |wc -l`
if [ $count -eq 0 ]; then
   echo "${now_time} start Trs-TranRunsTX process....."
   sh /home/sgrd/Trs-TranRunsTX/bin/startup.sh
   echo "<<${site}_${IP}>>Alarming time:${now_time} Trs-TranRunsTX process is down,Now start it"|mail -s "${site} Process Trs-TranRunsTX restart alarming" ${email_address}
   su - oracle  <<EOF
        sqlplus -S trs/trs123@trsdb
        insert into t_alarm_msg (phone_number,msg_body,send_type,send_flag,insert_time) values('${mobile}','${site} Trs-TranRunsTX process is down,Now start it!',0,0,sysdate);
        commit;
        exit;
EOF
else
   echo "${now_time} Trs-TranRunsTX is running....."
fi

#------------------  Trs-2g   --------------------------#
count=`ps -ef|grep tomcat |grep Trs-2g|grep -v "grep" |wc -l`
if [ $count -eq 0 ]; then
   echo "${now_time} start Trs-2g process....."
   su - sgrd -c /home/sgrd/Trs-2g/bin/startup.sh
   echo "<<${site}_${IP}>>Alarming time:${now_time} Trs-2g process is down,Now start it"|mail -s "${site} Process Trs-2g restart alarming" ${email_address}
   su - oracle  <<EOF
        sqlplus -S trs/trs123@trsdb
        insert into t_alarm_msg (phone_number,msg_body,send_type,send_flag,insert_time) values('${mobile}','${site} Trs-2g process is down,Now start it!',0,0,sysdate);
        commit;
        exit;
EOF
else
   echo "${now_time} Trs-2g is running....."
fi

#------------------  Trs-4g   --------------------------#
count=`ps -ef|grep tomcat |grep Trs-4g|grep -v "grep" |wc -l`
if [ $count -eq 0 ]; then
   echo "${now_time} start Trs-4g process....."
   su - sgrd -c /home/sgrd/Trs-4g/bin/startup.sh
   echo "<<${site}_${IP}>>Alarming time:${now_time} Trs-4g process is down,Now start it"|mail -s "${site} Process Trs-4g restart alarming" ${email_address}
   su - oracle  <<EOF
        sqlplus -S trs/trs123@trsdb
        insert into t_alarm_msg (phone_number,msg_body,send_type,send_flag,insert_time) values('${mobile}','${site} Trs-4g process is down,Now start it!',0,0,sysdate);
        commit;
        exit;
EOF
else
   echo "${now_time} Trs-4g is running....."
fi

#------------------  Trs-wifi   --------------------------#
count=`ps -ef|grep tomcat |grep Trs-wifi|grep -v "grep" |wc -l`
if [ $count -eq 0 ]; then
   echo "${now_time} start Trs-wifi process....."
   su - sgrd -c /home/sgrd/Trs-wifi/bin/startup.sh
   echo "<<${site}_${IP}>>Alarming time:${now_time} Trs-wifi process is down,Now start it"|mail -s "${site} Process Trs-wifi restart alarming" ${email_address}
   su - oracle  <<EOF
        sqlplus -S trs/trs123@trsdb
        insert into t_alarm_msg (phone_number,msg_body,send_type,send_flag,insert_time) values('${mobile}','${site} Trs-wifi process is down,Now start it!',0,0,sysdate);
        commit;
        exit;
EOF
else
   echo "${now_time} Trs-wifi is running....."
fi

#------------------  Trs-dw   --------------------------#
count=`ps -ef|grep tomcat |grep Trs-dw|grep -v "grep" |wc -l`
if [ $count -eq 0 ]; then
   echo "${now_time} start Trs-dw process....."
   su - sgrd -c /home/sgrd/Trs-dw/bin/startup.sh
   echo "<<${site}_${IP}>>Alarming time:${now_time} Trs-dw process is down,Now start it"|mail -s "${site} Process Trs-dw restart alarming" ${email_address}
   su - oracle  <<EOF
        sqlplus -S trs/trs123@trsdb
        insert into t_alarm_msg (phone_number,msg_body,send_type,send_flag,insert_time) values('${mobile}','${site} Trs-dw process is down,Now start it!',0,0,sysdate);
        commit;
        exit;
EOF
else
   echo "${now_time} Trs-dw is running....."
fi

#------------------  Trs-SendMSG   --------------------------#
count=`ps -ef|grep tomcat |grep Trs-SendMSG|grep -v "grep" |wc -l`
if [ $count -eq 0 ]; then
   echo "${now_time} start Trs-SendMSG process....."
   su - sgrd -c /home/sgrd/Trs-SendMSG/bin/startup.sh
   echo "<<${site}_${IP}>>Alarming time:${now_time} Trs-SendMSG process is down,Now start it"|mail -s "${site} Process Trs-SendMSG restart alarming" ${email_address}
   su - oracle  <<EOF
        sqlplus -S trs/trs123@trsdb
        insert into t_alarm_msg (phone_number,msg_body,send_type,send_flag,insert_time) values('${mobile}','${site} Trs-SendMSG process is down,Now start it!',0,0,sysdate);
        commit;
        exit;
EOF
else
   echo "${now_time} Trs-SendMSG is running....."
fi

#------------------  Trs-autopatrolTask   --------------------------#
count=`ps -ef|grep tomcat |grep Trs-autopatrolTask|grep -v "grep" |wc -l`
if [ $count -eq 0 ]; then
   echo "${now_time} start Trs-autopatrolTask process....."
   su - sgrd -c /home/sgrd/Trs-autopatrolTask/bin/startup.sh
   echo "<<${site}_${IP}>>Alarming time:${now_time} Trs-autopatrolTask process is down,Now start it"|mail -s "${site} Process Trs-autopatrolTask restart alarming" ${email_address}
   su - oracle  <<EOF
        sqlplus -S trs/trs123@trsdb
        insert into t_alarm_msg (phone_number,msg_body,send_type,send_flag,insert_time) values('${mobile}','${site} Trs-autopatrolTask process is down,Now start it!',0,0,sysdate);
        commit;
        exit;
EOF
else
   echo "${now_time} Trs-autopatrolTask is running....."
fi

#------------------  Trs-web   --------------------------#
count=`ps -ef|grep tomcat |grep Trs-web|grep -v "grep" |wc -l`
if [ $count -eq 0 ]; then
   echo "${now_time} start Trs-web process....."
   su - sgrd -c /home/sgrd/Trs-web/bin/startup.sh
   echo "<<${site}_${IP}>>Alarming time:${now_time} Trs-web process is down,Now start it"|mail -s "${site} Process Trs-web restart alarming" ${email_address}
   su - oracle  <<EOF
        sqlplus -S trs/trs123@trsdb
        insert into t_alarm_msg (phone_number,msg_body,send_type,send_flag,insert_time) values('${mobile}','${site} Trs-web process is down,Now start it!',0,0,sysdate);
        commit;
        exit;
EOF
else
   echo "${now_time} Trs-web is running....."
fi

}
function main(){
        check
}
main