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

PAY=( "python3" "gcc" "python3-devel" )
for package in $PAY
do
    dnf list module $PAY
    if [ $? -eq 0 ]
    then 
        echo "$Y already upadated $N "
    else
        dnf install $package &>>$LOG_FILE
        VALIDATE $? " install $PAY"
    fi
done

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

curl -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip  &>>$LOG_FILE
VALIDATE $? "store payment zipfile nodejs"
cd /app 
unzip -o /tmp/payment.zip &>>$LOG_FILE
VALIDATE $? "unzip"

cd /app 
pip3 install -r requirements.txt &>>$LOG_FILE
VALIDATE $? "install pip install requirements.txt"

cp /$SRC_DIR/payment.service /etc/systemd/system/payment.service
VALIDATE $? "upload payment.repo"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "reload payment"

systemctl enable payment &>>$LOG_FILE 
systemctl start payment &>>$LOG_FILE
VALIDATE $? "start payment"

END_DATE=$(date +%S)
TIME_TAKEN=$(( $END_DATE - $START_DATE ))

echo " the time taken to complete this script : $TIME_TAKEN " | tee -a $LOG_FILE