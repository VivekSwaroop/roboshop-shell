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

dnf module disable nodejs 

VALIDATE $? "Disabling current NodeJS"

dnf module enable nodejs:18 

VALIDATE $? "Enabling NodeJS:18"

dnf install nodejs 

VALIDATE $? "Installing NodeJS:18"

id roboshop #if roboshop user does not exist, then it is failure
if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "roboshop user creation"
else
    echo -e "roboshop user already exist $Y SKIPPING $N"
fi

mkdir -p /app

VALIDATE $? "creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip 

VALIDATE $? "Downloading catalogue application"

cd /app 

unzip -o /tmp/catalogue.zip 
VALIDATE $? "unzipping catalogue"

npm install 

VALIDATE $? "Installing dependencies"

# use absolute, because catalogue.service exists there
cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service 

VALIDATE $? "Copying catalogue service file"

systemctl daemon-reload

VALIDATE $? "catalogue daemon reload"

systemctl enable catalogue

VALIDATE $? "Enable catalogue"

systemctl start catalogue 

VALIDATE $? "Starting catalogue"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo

VALIDATE $? "copying mongodb repo"

dnf install mongodb-org-shell -y 

VALIDATE $? "Installing MongoDB client"

mongo --host $MONGDB_HOST </app/schema/catalogue.js 

VALIDATE $? "Loading catalouge data into MongoDB"