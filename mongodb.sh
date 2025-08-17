#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script stareted executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e " $R $2 Failed..$N"
        exit 1
    else
        echo -e " $G Success..$N"
    fi
}

if [ $ID -ne 0 ]
then    
    echo -e "$R ERROR:: Please run this script with root access $N"
    exit 1 
else
     echo "You are root user"
fi

cp mongo.repo /etc/yum.repos.d/mongo.repo 

VALIDATE $? "Copied MongoDB Repo"

dnf install mongodb-org -y &

VALIDATE $? "Installing MongoDB"

systemctl enable mongod

VALIDATE $? "Enabling MongoDB"

systemctl start mongod 

VALIDATE $? "Starting MongoDB"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf 

VALIDATE $? "Remote access to MongoDB"

systemctl restart mongod 

VALIDATE $? "Restarting MongoDB"

    
