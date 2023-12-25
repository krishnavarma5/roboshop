#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MONGODB_HOST=

TIMESSTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESSTAMP.log"

echo "script started executing at $TIMESSTAMP" &>> $LOGFILE

VALIDATE(){ 
   if [ $1 -ne 0 ]
   then 
       echo -e "$2 ... $R FAILED $N"
    else 
        echo -e "$2 ... $G SUCCESS $N"
    fi
   }

if [ $ID -ne 0 ]
then
   echo -e "$R ERROR :: please run this script with root access $N"
   exit 1 # you can give other than 0
else
   echo "you are root user"
fi #fi means reverse of if, indicating condition end

dnf module disable nodejs -y

VALIDATE $? "Disabling current NodeJS" &>> $LOGFILE 

dnf module enable nodejs:18 -y

VALIDATE $? "enabling NodeJS:18" &>> $LOGFILE

dnf install nodejs -y

VALIDATE $? "installing NodeJS:18" &>> $LOGFILE

useradd roboshop

VALIDATE $? "creating roboshop user" &>> $LOGFILE

mkdir /app

VALIDATE $? "creating app directory" &>> $LOGFILE

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip

VALIDATE $? "Downloading catalogue application" &>> $LOGFILE

cd /app 

unzip /tmp/catalogue.zip

VALIDATE $? "unzipping catalogue" &>> $LOGFILE

npm install 

VALIDATE $? "Installing dependencies" &>> $LOGFILE

#use absolute, because catalogue.service exists there
cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service

VALIDATE $? "copying catalogue srvice file"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "catalogue daemon reload" &>> $LOGFILE

systemctl enable catalogue &>> $LOGFILE

VALIDATE $? "Enable catalogue"

systemctl start catalogue &>> $LOGFILE

VALIDATE $? "starting catalogue"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo

VALIDATE $? "copying mongodb repo"

dnf install mongodb-org-shell -y

VALIDATE $? "Installing MongoDB client"

mongo --host $MONGODB_HOST </app/schema/catalogue.js

VALIDATE $? "Loading catalogue data into MongoDB"



