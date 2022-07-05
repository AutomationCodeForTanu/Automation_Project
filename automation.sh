#!/bin/bash
sudo -i
apt-get update
apache2 -v
if [[ $(echo $?) -eq 0 ]];
then
	echo "Apache2 is installed"
else
	apt-get install apache2
fi
service apache2 status | grep "active (running)"
if [[ $(echo $?) -eq 0 ]];
then
	echo "Process is running"
else
	apt install --reinstall apache2-bin
	service apache2 start
fi
systemctl enabled apache2
cd /var/log/apache2/
ls
find . -type f ! -name '*.log' -delete
echo "only access.log and error.log files are present"
timestamp=$(date '+%d%m%Y-%H%M%S')
name="tanu"
tarname=$name-httpd-logs-$timestamp.tar
cd /var/tmp
tar -cvf $tarname /var/log/apache2/
sizeOfFile=$(du -sh $tarname)
s3_bucket="s3-bucket-tanu"
aws s3 cp $tarname s3://$s3_bucket/$tarname
cd ~
cd /var/www/html
if [[ -f "inventory.html" ]];
then
	echo "File Present"
else
	vi inventory.html
fi
cat inventory.html | grep -i "Log Type"
if [[ $(echo $?) -eq 0 ]];
then
	echo "httpd-logs"               $timestamp                      "tar"                   $sizeOfFile >> inventory.html
else
	echo "Log Type"                 "Date Created"                  "Type"                  "Size" >> inventory.html
	echo "httpd-logs"               $timestamp                      "tar"                   $sizeOfFile >> inventory.html
fi
cat inventory.html
cd ~
cd /etc/cron.d
crontab -l | grep -i "Automation_Project_Tanu"
if [[ $(echo $?) -ne 0 ]];
then
	echo "schedule job"
	echo "30 16 * * * /root/Automation_Project_Tanu/automation.sh" >> /etc/cron.d/automation
	crontab /etc/cron.d/automation
else
	echo "Cron job is already scheduled"
fi
cd ~
