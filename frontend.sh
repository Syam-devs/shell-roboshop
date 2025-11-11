USERID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOG_FOLDER="/var/log/shell-script-logs"
SCRIPT_NAME=$(echo $@ | cut -d '.' -f1)
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

dnf module disable nginx -y &>>$LOG_FILE
VALIDATE $? "diable nginx"

dnf module enable nginx:1.24 -y &>>$LOG_FILE
VALIDATE $? "enable nginx"

dnf install nginx -y &>>$LOG_FILE
VALIDATE $? "install nginx"

systemctl enable nginx &>>$LOG_FILE
VALIDATE $? "enable nginx"

systemctl start nginx &>>$LOG_FILE
VALIDATE $? "start nginx"

rm -rf /usr/share/nginx/html/* &>>$LOG_FILE
VALIDATE $? "remove defaul files in nginx"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOG_FILE
VALIDATE $? "zip nginx"

cd /usr/share/nginx/html 
unzip /tmp/frontend.zip &>>$LOG_FILE
VALIDATE $? "unzip nginx"

cp /$SRC_DIR/nginx.conf /etc/nginx/nginx.conf &>>$LOG_FILE
VALIDATE $? "add nginx.conf"

systemctl restart nginx &>>$LOG_FILE
VALIDATE $? "restart nginx"

END_DATE=$(date +%S)
TIME_TAKEN=$(( $END_DATE - $START_DATE ))

echo "the time taken to complete this script : $TIME_TAKEN " | tee -a $LOG_FILE