#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"


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

curl -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $LOGFILE

VALIDATE $? "Downloading cart application" 

cd /app 

unzip -o /tmp/cart.zip &>> $LOGFILE

VALIDATE $? "unzipping cart" 

npm install &>> $LOGFILE

VALIDATE $? "Installing dependencies" 

#use absolute, because cart.service exists there
cp /home/centos/roboshop/cart.service /etc/systemd/system/cart.service

VALIDATE $? "copying cart service file"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "cart daemon reload" &>> $LOGFILE

systemctl enable cart &>> $LOGFILE

VALIDATE $? "Enable cart"

systemctl start cart &>> $LOGFILE

VALIDATE $? "starting cart"

