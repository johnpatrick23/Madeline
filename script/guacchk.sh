#!/bin/sh

#echo "------------------"
#log="myscript-$(date +%Y$m%d%H%M%S).log"

#Logs directory

set -e
cd "$(dirname "${BASH_SOURCE[0]}")"
source ./../script/parse_yaml.sh

log=madeline.log

sendemail=false
manageable=true
restartAttempt=0
guacd=1
mysql=1
nginx=1
tomcat8=1

function check_error(){
        local guacd="$1"
        local mysql="$2"
        local nginx="$3"
        local tomcat8="$4"
        local submessage=""

        if [ "$guacd" = 0 ]
        then
                submessage="${submessage}<br/>GUAC----<br/>"$(sudo systemctl status guacd || true)"<br/><br/><br/>"
        fi


        if [ "$mysql" = 0 ]
        then
                submessage="${submessage}<br/>MYSQL----<br/>"$(sudo systemctl status mysql || true)"<br/><br/><br/>"
        fi


        if [ "$nginx" = 0 ]
        then
                submessage="${submessage}<br/>NGINX----<br/>"$(sudo systemctl status nginx || true)"<br/><br/><br/>"
        fi


        if [ "$tomcat8" = 0 ]
        then
                submessage="${submessage}<br/>TOMCAT8----<br/>"$(sudo systemctl status tomcat8 || true)"<br/><br/><br/>"
        fi

        echo ${submessage}

}


for (( ;; ))
do
	echo "" >> $log
	echo "----------------------------" >> $log
	if [ -z "$(top -b -n 1 | egrep 'guacd')" ]
	then
		echo "[$(date)]: Guac is NOT running" >> $log
		sendemail=true
		guacd=0
	else
		echo "[$(date)]: Guac is running" >> $log
		guacd=1
	fi

	if [ -z "$(top -b -n 1 | egrep 'mysqld')" ]
	then
                echo "[$(date)]: mysqld is NOT running" >> $log
                sendemail=true
		mysql=0
        else
                echo "[$(date)]: mysqld is running" >> $log
		mysql=1
	fi

	if [ -z "$(top -b -n 1 | egrep 'nginx')" ]
	then
                echo "[$(date)]: nginx is NOT running" >> $log
                sendemail=true
		nginx=0
        else
                echo "[$(date)]: nginx is running" >> $log
        	nginx=1
	fi

	if [ -z "$(top -b -n 1 | egrep 'tomcat8')" ]
	then
                echo "[$(date)]: tomcat8 is NOT running" >> $log
                sendemail=true
		tomcat8=0
        else
                echo "[$(date)]: tomcat8 is running" >> $log
        	tomcat8=1
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

	echo "restartAttempt $restartAttempt"

	if [[ "$guacd" = 1 && "$mysql" = 1 && "$nginx" = 1 && "$tomcat8" = 1 ]]
        then
		restartAttempt=0
		sendemail=false
        else
		sendemail=true
		manageable=true
        fi

	if [[ "$sendemail" = true && "$manageable" = true ]]
	then
		sudo service guacd restart || true
		sudo service mysql restart || true
		sudo service nginx restart || true
		sudo service tomcat8 restart || true

		if [[ $restartAttempt = 5 || $restartAttempt = 2 || $restartAttempt = 3 || $restartAttempt = 4 ]]
		then
			manageable=false
			if [ "$sendemail" = true ] && [ "$manageable" = false ]
	                then
				status=$(check_error $guacd $mysql $nginx $tomcat8)
	                        message="Something went wrong in guac server: $(hostname)<br/><br/>After $restartAttempt attempt(s) Guac Service is still not running.<br/>Please check the server ASAP.<br/><br/>"
	                        #status="<br/>GUAC----<br/>"$(sudo systemctl status guacd || true)"<br/><br/><br/>MYSQL----<br/>"$(sudo systemctl status mysql || true)"<br/><br/><br/>NGINX----<br/>"$(sudo systemctl status nginx || true)"<br/><br/><br/>TOMCAT8----<br/>"$(sudo systemctl status tomcat8 || true)"<br/><br/>"
	                        sudo python sendemail.py -m "$message$status" -s "Guac Report"
			fi
		elif [ $restartAttempt -gt 5 ]
		then
			sendemail=false
			manageable=false
		else
			sendemail=true
			manageable=true
		fi
	fi

	echo "[$(date)]: Restart Attempt " $(( restartAttempt++ )) >> $log

	sleep 5s
done

