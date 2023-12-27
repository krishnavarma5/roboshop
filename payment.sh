#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"


TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script started executing at $TIMESTAMP" &>> $LOGFILE

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

dnf install python36 gcc python3-devel -y

id roboshop # if roboshop user does not exist, then it is failure
if [ $? -ne 0 ]
then 
   useradd roboshop
   VALIDATE $? "Roboshop user creation"
else 
   echo -e "Roboshop user already exist $Y SKIPPING $N"
fi   

mkdir -p /app

VALIDATE $? "creating app directory"
 
curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip

cd /app 

unzip -o /tmp/payment.zip

pip3.6 install -r requirements.txt

cp home/centos/roboshop/payment.service /etc/systemd/system/payment.service

systemctl daemon-reload

systemctl enable payment

systemctl start payment