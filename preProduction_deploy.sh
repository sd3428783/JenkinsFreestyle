#!/bin/bash -ilex
workspace="/app/jenkins_home/workspace/pre-production"
last_version=$(docker images |grep -w qcloud_backend |awk '{print $2}' |sort -rn | head -1)
echo $last_version
#new_version=$(new_version)
echo $new_version
list=($(docker images |grep -w qcloud_backend |awk '{print $2}'))
if echo "${list[@]}" | grep -w "$new_version" &>/dev/null;then
	echo "你要部署的版本仓库中已存在！"
	current_version=$(docker ps -a|grep -w pre-production |awk '{print $2}'| awk -F: '{print $3}')
    if [ $new_version = $current_version ];then
    		echo "version already exists and running"
    else
    	    docker stop pre-production
        	sleep 1
        	docker rm pre-production
        	sleep 1
			docker run -p 1337:1337 -itd --restart=always --ip 172.20.0.23 -e NODE_ENV=$NODE_PRO  -e NODE_HOST=$NODE_HOST --name  pre-production --net mynet123 -v  /app/jenkins_home/workspace/pre-production/dist:/app/public -v /app/pcloud/uploads:/app/public/uploads 192.168.64.15:5000/qcloud_backend:$new_version
	fi
else
	docker pull 192.168.64.15:5000/qcloud_backend:$new_version
    count=$(docker ps -a|grep -w pre-production |wc -l)
   	if [ $count -eq 0 ];then
        #docker ps
		docker run -p 1337:1337 -itd --restart=always --ip 172.20.0.23 -e NODE_ENV=$NODE_PRO  -e NODE_HOST=$NODE_HOST --name  pre-production --net mynet123 -v  /app/jenkins_home/workspace/pre-production/dist:/app/public -v /app/pcloud/uploads:/app/public/uploads 192.168.64.15:5000/qcloud_backend:$new_version
    elif [ $count -eq 1 ];then
        #docker images
        docker stop pre-production
        sleep 1
        docker rm pre-production
        sleep 1
		docker run -p 1337:1337 -itd --restart=always --ip 172.20.0.23 -e NODE_ENV=$NODE_PRO  -e NODE_HOST=$NODE_HOST --name  pre-production --net mynet123 -v  /app/jenkins_home/workspace/pre-production/dist:/app/public -v /app/pcloud/uploads:/app/public/uploads 192.168.64.15:5000/qcloud_backend:$new_version
    else
        echo "Please check in manualy!"
    fi
fi
echo "Completing!"
