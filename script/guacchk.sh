#!/bin/sh

#echo "------------------"
#log="myscript-$(date +%Y$m%d%H%M%S).log"

#Logs directory

set -e
cd "$(dirname "${BASH_SOURCE[0]}")"
source ./../script/parse_yaml.sh

log=./../logs/madeline.log

sendemail=false
manageable=true
restartAttempt=1


for (( ;; ))
do
	echo "" >> $log
	echo "----------------------------" >> $log
	if [ -z "$(top -b -n 1 | egrep 'guacd')" ]
	then
		echo "[$(date)]: Guac is NOT running" >> $log
		sendemail=true
	else
		echo "[$(date)]: Guac is running" >> $log
	fi

	if [ -z "$(top -b -n 1 | egrep 'mysqld')" ]
	then
                echo "[$(date)]: mysqld is NOT running" >> $log
                sendemail=true
        else
                echo "[$(date)]: mysqld is running" >> $log
        fi

	if [ -z "$(top -b -n 1 | egrep 'nginx')" ]
	then
                echo "[$(date)]: nginx is NOT running" >> $log
                sendemail=true
        else
                echo "[$(date)]: nginx is running" >> $log
        fi

	if [ -z "$(top -b -n 1 | egrep 'tomcat8')" ]
	then
                echo "[$(date)]: tomcat8 is NOT running" >> $log
                sendemail=true
        else
                echo "[$(date)]: tomcat8 is running" >> $log
        fi

	echo "" >> $log
	echo "[$(date)]: ------{ guacd }-------------" >> $log
	echo $(sudo service guacd status) >> $log 2>&1

	echo "" >> $log
        echo "[$(date)]: ------{ mysql }-------------" >> $log
	echo $(sudo service mysql status) >> $log 2>&1

	echo "" >> $log
        echo "[$(date)]: ------{ nginx }-------------" >> $log
	echo $(sudo service nginx status) >> $log 2>&1

	echo "" >> $log
        echo "[$(date)]: ------{ tomcat8 }-----------" >> $log
	echo $(sudo service tomcat8 status) >> $log 2>&1


	if [ "$sendemail" = true ] && [ "$manageable" = true ]
	then
		sudo service guacd restart || true
		sudo service mysql restart || true
		sudo service nginx restart || true
		sudo service tomcat8 restart || true
		echo "[$(date)]: Restart Attempt " $(( restartAttempt++ )) >> $log
		sendemail=false
	else
		restartAttempt=1
		sendemail=false
		manageable=true
	fi

	if [ $restartAttempt = 5 ]
	then
		manageable=false
                if [ "$sendemail" = true ] && [ "$manageable" = false ]
                then
			message="Something went wrong in guac server: $(hostname)<br/><br/>After $restartAttempt attempt(s) Guac Service is still not running.<br/>Please check the server ASAP.<br/><br/>"
                        #sudo systemctl restart guacd
                        status="<br/>GUAC----<br/>"$(sudo systemctl status guacd || true)"<br/><br/><br/>MYSQL----<br/>"$(sudo systemctl status mysql || true)"<br/><br/><br/>NGINX----<br/>"$(sudo systemctl status nginx || true)"<br/><br/><br/>TOMCAT8----<br/>"$(sudo systemctl status tomcat8 || true)"<br/><br/>"
                        #echo $message$status
                        sudo python sendemail.py -m "$message$status" -s "Guac Report"
                fi
	fi

	sleep 5s
done

