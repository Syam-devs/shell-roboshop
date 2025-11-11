#!/bin/bash

USERID=$(id -u)

LOG_FOLDER="/var/log/shell-script-logs"
SCRIPT_NAME=$($@ | cut -d '.' -f1)
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"

mkdir -p $LOG_FOLDER

echo " script executing at $(date) " &>>$LOG_FILE

PACKAGE=("nginx" "mysql" "python3")

if [ $USERID -ne 0 ]
then
    echo "Error:you are not running with root user"
    exit 1
else
    echo "you are running with root user"
fi

VALIDATE(){
    if [ $1 -eq 0 ]
    then 
        echo "installing.... $2 is success"
    else 
        echo "installing.... $2 is failure"
        exit 1
    fi
}

for pack in ${PACKAGE[@]}
do
    dnf list module $pack
    if [ $? -eq 0 ]
    then
        echo " $pack aready installed.."
    else
        echo " $pack installing.."
        dnf install $pack
        VALIDATE $? $pack
    fi
done

