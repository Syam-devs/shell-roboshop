USERID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOG_FOLDER="/var/log/shell-script-logs"
SCRIPT_NAME=$(echo $0 | cut -d '.' -f1)
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"
DATE=$(TZ='Asia/Kolkata' date)
START_DATE=$(date +%S)
SRC_DIR=$PWD

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
dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "install mysql-server"

systemctl enable mysqld &>>$LOG_FILE
VALIDATE $? "enable mysqld" 

systemctl start mysqld &>>$LOG_FILE
VALIDATE $? "start mysqld"

read -s -p "Password: " PASS 
mysql_secure_installation --set-root-pass $PASS

END_DATE=$(date +%S)
TIME_TAKEN=$(( $END_DATE - $START_DATE ))

echo " the time taken to complete this script : $TIME_TAKEN " | tee -a $LOG_FILE