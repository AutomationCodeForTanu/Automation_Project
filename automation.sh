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
