#!/bin/bash

USERID=$(id -u)

if [ $USERID -ne 0 ]
then
    echo "Error:you are not running with root user"
    exit 1
else
    echo "you are running with root user"
fi

dnf list module mysql
if [ $? -eq 0 ]
then 
    echo "mysql is already installed"
else
    echo "mysql is not istalled need to install"
    dnf install mysql -y
    if [ $? -eq 0 ]
    then 
        echo "installing.... mysql is success"
    else 
        echo "installing.... mysql is failure"
        exit 1
    fi
fi

# if [ $? -eq 0 ]
# then 
#     echo "installing.... mysql is success"
# else 
#     echo "installing.... mysql is failure"
#     exit 1
# fi
