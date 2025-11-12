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
dnf install maven -y &>>$LOG_FILE
VALIDATE $? "disable nodejs"


id roboshop &>>$LOG_FILE
if [ $? -eq 0 ]
then 
    echo " user already exist "
else
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop 
    VALIDATE $? " useradd "
fi

mkdir -p /app &>>$LOG_FILE
VALIDATE $? "cread app dir"

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip  &>>$LOG_FILE
VALIDATE $? "store shipping zipfile nodejs"
cd /app 
unzip -o /tmp/shipping.zip &>>$LOG_FILE
VALIDATE $? "unzip"

cd /app 
mvn install &>>$LOG_FILE
VALIDATE $? "install mvn package"
mv target/shipping-1.0.jar shipping.jar 
VALIDATE $? "name change"

cp /$SRC_DIR/shipping.service /etc/systemd/system/shipping.service
VALIDATE $? "reload nodejs"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "reload shipping"

systemctl enable shipping &>>$LOG_FILE 
systemctl start shipping &>>$LOG_FILE
VALIDATE $? "start shipping"

dnf install mysql -y &>>$LOG_FILE
VALIDATE $? "install mysql"

read -s -p "Password: " PASS

cd /app/db/schema.sql
if [ $? -eq 0 ]
then 
    echo -e "$Y database $N .. already exist"
else
    echo "$G loading $N .. master data "
    mysql -h 172.31.3.20 -uroot -p$PASS < /app/db/schema.sql
    mysql -h 172.31.3.20 -uroot -p$PASS < /app/db/app-user.sql 
    mysql -h 172.31.3.20 -uroot -p$PASS < /app/db/master-data.sql

systemctl restart shipping &>>$LOG_FILE
VALIDATE $? "restart shipping"

END_DATE=$(date +%S)
TIME_TAKEN=$(( $END_DATE - $START_DATE ))

echo " the time taken to complete this script : $TIME_TAKEN " | tee -a $LOG_FILE