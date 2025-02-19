#!/bin/bash
log_folder="var/log/shell-script"
script_name=$( echo $0 | cut -d "." -f1)
time_stamp=$(date +%Y-%m-%d-%H-%M-%S)
log_file="$log_folder/$script_name-$time_stamp.log"
mkdir -p $log_folder
userid=$( id -u )

R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"



check_root () {
    if [ $? -ne 0 ]
    then
        echo -e "$R you dont have root access $N"
        exit 1
    fi
}

validate () {
    if [ $? -ne 0 ]
    then 
        echo -e "$R FAILED $N"
    else
        echo -e "$G SUCCESS $N"
    fi 
}

check_root

echo -e "$G script started at $(date) $N"

dnf install mysql-server -y &>>log_file
validate $? "installing mysql-server"

systemctl enable mysqld &>>log_file
validate $? "enabling mysql-server"

systemctl start mysqld &>>log_file
validate $? "starting mnysql-server"

mysql -h mysql.khanishkcosmetics.store -u root -pExpenseApp@1 -e 'show databases;' &>>$log_file
if [ $? -ne 0 ]
then
    echo -e "mysql root password was not setup,setting up now"
    mysql_secure_installation --set-root-pass ExpenseApp@1 &>>log_file
    validate $? "setting up root password"
else
    echo "password is already setup"
fi 


