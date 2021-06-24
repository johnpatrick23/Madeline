#!/bin/sh

#echo "------------------"
#log="myscript-$(date +%Y$m%d%H%M%S).log"

#Logs directory

set -e
cd "$(dirname "${BASH_SOURCE[0]}")"
source ./../script/parse_yaml.sh

log=./../logs/guacchk.log

for (( ;; ))
do
	echo "" >> $log
	echo "----------------------------" >> $log
	if [ -z "$(top -b -n 1 | egrep 'guacd')" ]
	then
		echo "[$(date)]: Guac is NOT running" >> $log
	else
		echo "[$(date)]: Guac is running" >> $log
	fi

	if [ -z "$(top -b -n 1 | egrep 'mysqld')" ]
	then
                echo "[$(date)]: mysqld is NOT running" >> $log
        else
                echo "[$(date)]: mysqld is running" >> $log
        fi

	if [ -z "$(top -b -n 1 | egrep 'nginx')" ]
	then
                echo "[$(date)]: nginx is NOT running" >> $log
        else
                echo "[$(date)]: nginx is running" >> $log
        fi

	if [ -z "$(top -b -n 1 | egrep 'tomcat8')" ]
	then
                echo "[$(date)]: tomcat8 is NOT running" >> $log
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

	sleep 5s
done

