#!/bin/bash
log_file="var/log/shell-practice"
script_name="$( echo $0 | cut -d "." -f1)"
time_stamp=$(date +%Y-%m-%d-%H-%M-%S)
log_folder="$log_file/$script_name-$time_stamp.log"
mkdir -p $log_file

R="\e[31m"
G="\e[32m"
y="\e[33m"
N="\e[0m"

userid=$( id -u )

check_root () {
    if [ $userid -ne 0 ]
    then 
        echo -e "$R you are not having root access $N"
        exit 1
    fi 
}

validate () {

    if [ $? -ne 0 ]
    then
        echo -e " $R failed $N"
    else
        echo -e " $G SUCCESS $N "
    fi 
}

check_root

dnf module disable nodejs -y &>>$log_folder
validate $? "disabling nodejs"

dnf module enable nodejs:20 -y &>>$log_folder
validate $? "enabling nodejs:20"

dnf install nodejs -y &>>$log_folder
validate $? "installing nodejs"

id expense &>>$log_folder
if [ $? -ne 0 ]
then 
    echo -e "$R user is not created , creaating now $N"
    useradd expense &>>log_folder
    validate $? "adding user expense"
else
    echo -e "$G user already exists $N"
fi

mkdir -p /app 
validate $? "creating app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$log_folder

cd /app

rm -rf /app/*
unzip /tmp/backend.zip &>>log_folder
validate $? "extracting backend file"

npm install &>>log_folder
cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service

systemctl daemon-reload &>>log_folder
validate $? "reloading the backend service"

systemctl start backend &>>log_folder
validate $? "starting the backend service"

systemctl enable backend &>>log_folder
validate $? "enabling the ackend service"

dnf install mysql -y &>>log_folder
validate $? "installing mysql package to load schema/backend.sql"

mysql -h 172.31.37.132 -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>log_folder

systemctl restart backend &>>log_folder
validate $? "restarting backend"
















