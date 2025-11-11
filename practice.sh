#!/bin/bash

USERID=$(id -u)

if [ $USERID -ne 0 ]
then
    echo "Error:you are not running with root user"
else
    echo "you are running with root user"
fi

