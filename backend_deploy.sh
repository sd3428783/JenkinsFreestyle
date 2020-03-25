#!/bin/bash -ilex
source /etc/profile
workspace="/var/jenkins_home/workspace/pcl-qcloud-backend"
imagehead="192.168.64.15:5000/qcloud_backend"
last_version=$(docker images |grep qcloud_backend |awk '{print $2}' |sort -rn | head -1)
echo $last_version
new_version=$(echo $last_version | awk -F. -v OFS=. 'NF==1{print ++$NF}; NF>1{if(length($NF+1)>length($NF))$(NF-1)++; $NF=sprintf("%0*d", length($NF), ($NF+1)%(10^length($NF))); print}') #适用于1位小数点 
echo $new_version
cd $workspace
echo $NODE_ENV
if [ $GIT_PREVIOUS_SUCCESSFUL_COMMIT == $GIT_COMMIT ];then
        echo "no change,skip build";
        exit 0
else
		echo "git pull commit id not equals to current commit id trigger build"
		docker build -t 192.168.64.15:5000/qcloud_backend:$new_version .
		count=$(docker ps -a|grep strapi |wc -l)
		if [ $count -eq 0 ];then
			#docker ps
			docker run -p 1337:1337 -itd --restart=always -e NODE_ENV=staging -e NODE_HOST=$NODE_HOST --name  strapi --net mynet123 --ip 172.20.0.21 -v /var/jenkins_home/workspace/pcl-qcloud-frontend/dist:/app/public 192.168.64.15:5000/qcloud_backend:$new_version
			docker push 192.168.64.15:5000/qcloud_backend:$new_version
		elif [ $count -eq 1 ];then
			#docker images
			docker stop strapi
			docker rm strapi
			docker run -p 1337:1337 -itd --restart=always -e NODE_ENV=staging -e NODE_HOST=$NODE_HOST --name  strapi --net mynet123 --ip 172.20.0.21 -v /var/jenkins_home/workspace/pcl-qcloud-frontend/dist:/app/public 192.168.64.15:5000/qcloud_backend:$new_version
			docker push 192.168.64.15:5000/qcloud_backend:$new_version
		else
			echo "Please check in manualy!"
		fi
fi
