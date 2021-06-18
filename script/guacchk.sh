#!/usr/bin/env bash

#echo "------------------"
#log="myscript-$(date +%Y$m%d%H%M%S).log"

#Logs directory
log=logs/guacchk.log

for (( ;; ))
do
	GUAC=$(top -b -n 1 | egrep 'guacd')
	if [ "${#GUAC[0]}" -le 0 ]
	then
		echo "[$(date)]: Guac is not running" >> $log
	else
		echo "[$(date)]: Guac is running" >> $log
	fi
	sleep 2s
done

