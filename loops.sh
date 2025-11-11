#!/bin/bash

USERID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOG_FOLDER="/var/log/shell-script-logs"
SCRIPT_NAME=$(echo $@ | cut -d '.' -f1)
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"
DATE=$(TZ='Asia/Kolkata' date)

mkdir -p $LOG_FOLDER

echo " script executing at $DATE " | tee -a $LOG_FILE



if [ $USERID -ne 0 ]
then
    echo -e "$R Error: $N you are not running with root user"
    exit 1
else
    echo -e "$G you are running with root user $N"
fi

VALIDATE(){
    if [ $1 -eq 0 ]
    then 
        echo -e " installing.... $2 is $G success $N " | tee -a $LOG_FILE
    else 
        echo -e " installing.... $2 is $R failure $N " | tee -a $LOG_FILE
        exit 1
    fi
}

for pack in $@
do
    dnf list module $pack &>>$LOG_FILE
    if [ $? -eq 0 ]
    then
        echo -e " $pack aready $Y installed..$N " | tee -a $LOG_FILE
    else
        echo -e " $pack $G installing.. $N" | tee -a $LOG_FILE
        dnf install $pack &>>$LOG_FILE
        VALIDATE $? $pack
    fi
done

