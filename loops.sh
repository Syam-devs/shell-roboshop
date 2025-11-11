#!/bin/bash

USERID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOG_FOLDER="/var/log/shell-script-logs"
SCRIPT_NAME=$(echo $@ | cut -d '.' -f1)
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"
DATE="TZ='Asia/Kolkata' date"

mkdir -p $LOG_FOLDER

echo " script executing at $DATE " | tee -a $LOG_FILE



if [ $USERID -ne 0 ]
then
    echo "$R Error: $N you are not running with root user"
    exit 1
else
    echo "$G you are running with root user $N"
fi

VALIDATE(){
    if [ $1 -eq 0 ]
    then 
        echo "installing.... $2 is $G success $N "
    else 
        echo "installing.... $2 is $R failure $N "
        exit 1
    fi
}

for pack in $@
do
    dnf list module $pack
    if [ $? -eq 0 ]
    then
        echo " $pack aready $Y installed..$N "
    else
        echo " $pack $G installing.. $N"
        dnf install $pack
        VALIDATE $? $pack
    fi
done

