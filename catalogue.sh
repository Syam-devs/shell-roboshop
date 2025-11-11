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

id roboshop &>>$LOG_FILE
if [ $? -eq 0 ]
then 
    echo " user already exist "
else
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop 
    VALIDATE $? " user  add "
fi

mkdir -p /app &>>$LOG_FILE
VALIDATE $? "cread app dir"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip  &>>$LOG_FILE
VALIDATE $? "store catalogue zipfile nodejs"
cd /app 
unzip -o /tmp/catalogue.zip &>>$LOG_FILE
VALIDATE $? "unzip"

cd /app 
npm install &>>$LOG_FILE
VALIDATE $? "install npm package nodejs"

cp /$SRC_DIR/catalogue.service /etc/systemd/system/catalogue.service

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "reload nodejs"

systemctl enable catalogue &>>$LOG_FILE 
systemctl start catalogue &>>$LOG_FILE

VALIDATE $? "start nodejs"

cp /$SRC_DIR/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOG_FILE

dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "install mongodb-mongosh"

mongosh --host 172.31.31.82 </app/db/master-data.js &>>$LOG_FILE
VALIDATE $? "load data mongodb"

END_DATE=$(date +%S)
TIME_TAKEN=$(( $END_DATE - $START_DATE ))

echo "the time taken to complete this script : $TIME_TAKEN " | tee -a $LOG_FILE