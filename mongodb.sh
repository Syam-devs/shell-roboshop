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
START_DATE=$(date +%s)

echo " script executing at $DATE " | tee -a $LOG_FILE



if [ $USERID -ne 0 ]
then
    echo -e "$R Error: $N you are not running with root user"
    exit 1
else
    echo -e "$G you are running with root user $N"
fi

mkdir -p $LOG_FOLDER

VALIDATE(){
    if [ $1 -eq 0 ]
    then 
        echo -e " $2 is $G success $N " | tee -a $LOG_FILE
    else 
        echo -e " $2 is $R failure $N " | tee -a $LOG_FILE
        exit 1
    fi
}

dnf install mongodb-org -y &>>$LOG_FILE
VALIDATE $? "install mongodb"
systemctl enable mongod &>>$LOG_FILE
VALIDATE $? "enable mongodb"
systemctl start mongod &>>$LOG_FILE
VALIDATE $? "start mongodb"
sed -i "s/127.0.0.1/0.0.0.0/g" /etc/mongod.conf &>>$LOG_FILE
VALIDATE $? "modify mongo.conf"
systemctl restart mongod &>>$LOG_FILE
VALIDATE $? "restart mongodb"

END_DATE=$(date +%s)
TIME_TAKEN=$START_DATE-$END_DATE
echo "the time taken to complete this script : $TIME_TAKEN " | tee -a $TIME_TAKEN