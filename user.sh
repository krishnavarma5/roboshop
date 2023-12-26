#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MONGODB_HOST=mongodb.76sdevops.website

TIMESSTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESSTAMP.log"

echo "script started executing at $TIMESSTAMP" &>> $LOGFILE

VALIDATE(){ 
   if [ $1 -ne 0 ]
   then 
       echo -e "$2 ... $R FAILED $N"
       exit 1
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

dnf module disable nodejs -y &>> $LOGFILE 

VALIDATE $? "Disabling current NodeJS" 

dnf module enable nodejs:18 -y&>> $LOGFILE

VALIDATE $? "enabling NodeJS:18" 

dnf install nodejs -y &>> $LOGFILE

VALIDATE $? "installing NodeJS:18" 

id roboshop # if roboshop user does not exist, then it is failure
if [ $? -ne 0]
then 
   useradd roboshop
   VALIDATE $? "Roboshop user creation"
else 
   echo -e "Roboshop user already exist $Y SKIPPING $N"
fi   

mkdir -p /app

VALIDATE $? "creating app directory"

curl -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $LOGFILE

VALIDATE $? "Downloading user application" 

cd /app 

unzip -o /tmp/user.zip &>> $LOGFILE

VALIDATE $? "unzipping user" 

npm install &>> $LOGFILE

VALIDATE $? "Installing dependencies" 

cp /home/centos/roboshop/user.service /etc/systemd/system/user.service

VALIDATE $? "copying user service file"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "user daemon reload" &>> $LOGFILE

systemctl enable user &>> $LOGFILE

VALIDATE $? "enable user"

systemctl start user &>> $LOGFILE

VALIDATE $? "starting user"

cp /home/centos/roboshop/mongo.repo /etc/yum.repos.d/mongo.repo

VALIDATE $? "copying mongodb repo"

dnf install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "Installing MongoDB client"

mongo --host $MONGODB_HOST </app/schema/user.js &>> $LOGFILE

VALIDATE $? "Loading user data into MongoDB"
