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
dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "disable nodejs"
dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "disable nodejs" 
dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "install nodejs"

id roboshop1 &>>$LOG_FILE
if [ $? -eq 0 ]
then 
    echo " user already exist "
else
    useradd --system --home /userapp --shell /sbin/nologin --comment "roboshop system user" roboshop1 
    VALIDATE $? " user  add "
fi

mkdir -p /userapp &>>$LOG_FILE
VALIDATE $? "cread userapp dir"

curl -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip  &>>$LOG_FILE
VALIDATE $? "store user zipfile nodejs"
cd /userapp 
unzip -o /tmp/user.zip &>>$LOG_FILE
VALIDATE $? "unzip"

cd /userapp 
npm install &>>$LOG_FILE
VALIDATE $? "install npm package nodejs"

cp /$SRC_DIR/user.service /etc/systemd/system/user.service

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "reload nodejs"

systemctl enable user &>>$LOG_FILE 
systemctl start user &>>$LOG_FILE

VALIDATE $? "start user"

END_DATE=$(date +%S)
TIME_TAKEN=$(( $END_DATE - $START_DATE ))

echo " the time taken to complete this script : $TIME_TAKEN " | tee -a $LOG_FILE