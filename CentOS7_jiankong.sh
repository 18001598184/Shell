#!/bin/bash
##############################################
#Author: Wangzhengyu - 18001598184@163.com
#QQ:94136676
#Last modified: 2018-11-05 13:00
#Filename: jiankong.sh
#Description: 
##############################################
#获取cpu使用率
#cpuUsage=`top -n 1 | awk -F ‘[ %]+‘ ‘NR==3 {print $2}‘`
#Used by CentOS6.5
#cpuUsage=`top -bn 1|awk -F '[, %]+' 'NR==3 {print 100-$8}'`
#Used by CentOS7
cpuUsage=`top -bn 1|awk -F '[, %]+' 'NR==3 {print 100-$9}'`
#获取磁盘使用率
#data_name="/dev/sda3"
#diskUsage=`df -h | grep $data_name | awk -F '[ %]+' '{print $5}'`
#diskUsage=`df -h|awk -F '[ %]+' '/\/home$/{print $5}'`
diskUsage=`df -h|awk -F '[ %]+' '/\/$/{print $5}'`
logFile=./jiankong.log
#Used by CentOS6.5
#IP=`/sbin/ifconfig eth0 | grep "inet addr" | cut -f 2 -d ":" | cut -f 1 -d " "`
#Used by CentOS7
IP=`/sbin/ifconfig -a|grep -o -e 'inet [0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}'|grep -v "127.0.0"|awk '{print $2}'`
#获取内存情况
mem_total=`free -m | awk -F '[ :]+' 'NR==2{print $2}'`
mem_used=`free -m | awk -F '[ :]+' 'NR==3{print $3}'`
#统计内存使用率
mem_used_persent=`awk 'BEGIN{printf "%.0f\n",('$mem_used'/'$mem_total')*100}'`
#获取报警时间
now_time=`date '+%F %T'`
a=`echo "${cpuUsage} > 80"|bc`
b=`echo "${diskUsage} > 80"|bc`
c=`echo "${mem_used_persent} > 80"|bc`
function send_mail(){
        mail -s "Monitor Alarming" 18001598184@163.com < ./jiankong.log
}
function check(){
#浮点数比较大小不能使用此种判断方法
#        if [[ ${cpuUsage} > 80 ]] || [[ ${diskUsage} > 80 ]] || [[ ${mem_used_persent} > 80 ]];then
#浮点数比较大小采用以下判断方法
        if [[ $a -eq 1 ]] || [[ $b -eq 1 ]] || [[ $c -eq 1 ]];then
                echo "<<${IP}>>Alarming time:${now_time}" | tee -a $logFile
                echo "CPUUsage:${cpuUsage}% --> DiskUsage:${diskUsage}% --> Memory_used_persent:${mem_used_persent}%" | tee -a $logFile
                send_mail
        fi
}
function main(){
        check
}
main
