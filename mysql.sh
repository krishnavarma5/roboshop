#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MONGODB_HOST=mongodb.76sdevops.website

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

dnf module disable mysql -y &>> $LOGFILE

VALIDATE $? "Disable current Mysql Version"

cp mysql.repo /etc/yum.repos.d/mysql.repo

VALIDATE $? "copied my sql repo"

dnf install mysql-community-server -y

VALIDATE $? "Installing MySQL server"

systemctl enable mysqld

VALIDATE $? "enabling MySQL server"

systemctl start mysqld

VALIDATE $? "starting MySQL server"

mysql_secure_installation --set-root-pass RoboShop@1

VALIDATE $? "setting MySQL root password"