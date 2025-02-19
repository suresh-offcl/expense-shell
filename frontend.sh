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

dnf install nginx -y
validate $? "installing nginx"

systemctl enable nginx
validate $? "enabling nginx"

systemctl start nginx
validate $? "starting nginx"

#removing default webpage
rm -rf /usr/share/nginx/html/*

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip

cd /usr/share/nginx/html

unzip /tmp/frontend.zip 
validate $? "unzip the frontend code"

cp /home/ec2-user/expense-shell/expense.conf /etc/nginx/default.d/expense.conf
validate $? "copying expense conf"

systemctl restart nginx 
validate $? "restarting nginx"


