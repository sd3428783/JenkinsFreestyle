#!/bin/bash -ilex
workspace="/app/jenkins_home/workspace/production"
last_version=$(docker images |grep -w qcloud_backend |awk '{print $2}' |sort -rn | head -1)
current_version=$(docker ps -a | grep -w strapi | awk '{print $2}' | awk -F: '{print $3}')
list=($(docker images | grep -w qcloud_backend | awk '{print $2}'))
count=$(docker ps -a | grep -w strapi | wc -l)
echo $last_version
#new_version=$(new_version) 
echo $new_version
case $Status  in
  Deploy)
    echo "Status:$Status"
    path="${WORKSPACE}/bak/${BUILD_NUMBER}"      #创建每次要备份的目录
    if [ -d $path ];
    then
        echo "The files is already  exists "
    else
        mkdir -p  $path
    fi
    cp -r -f ${WORKSPACE}/dist/* $path        #将打包好的war包备份到相应目录,覆盖已存在的目标
    if echo "${list[@]}" | grep -w "$new_version" &>/dev/null; then
	    echo "你要部署的版本仓库中已存在！"
	    if [ $new_version = $current_version ]; then
		    echo "version already exists and running"
        else
            if [ $count -eq 0 ];then
        	#docker ps
			    docker run -p 80:1337 -itd --restart=always --ip 172.20.0.21 -e NODE_ENV=$NODE_ENV  -e NODE_HOST=$NODE_HOST --name  strapi --net mynet123 -v  /app/jenkins_home/workspace/production/dist:/app/public -v /app/pcloud:/app/public/uploads 192.168.64.15:5000/qcloud_backend:$new_version    
            elif [ $count -eq 1 ];then
        	    #docker images
        	    docker stop strapi
        	    sleep 1
        	    docker rm strapi
        	    sleep 1
			    docker run -p 80:1337 -itd --restart=always --ip 172.20.0.21 -e NODE_ENV=$NODE_ENV  -e NODE_HOST=$NODE_HOST --name  strapi --net mynet123 -v  /app/jenkins_home/workspace/production/dist:/app/public -v /app/pcloud:/app/public/uploads 192.168.64.15:5000/qcloud_backend:$new_version    
            else
                echo "Please check in manualy!"
            fi
        fi
    else
        docker pull 192.168.64.15:5000/qcloud_backend:$new_version
        if [ $count -eq 0 ];then
        	#docker ps
			docker run -p 80:1337 -itd --restart=always --ip 172.20.0.21 -e NODE_ENV=$NODE_ENV  -e NODE_HOST=$NODE_HOST --name  strapi --net mynet123 -v  /app/jenkins_home/workspace/production/dist:/app/public -v /app/pcloud:/app/public/uploads 192.168.64.15:5000/qcloud_backend:$new_version    
        elif [ $count -eq 1 ];then
        	#docker images
        	docker stop strapi
        	sleep 1
        	docker rm strapi
        	sleep 1
			docker run -p 80:1337 -itd --restart=always --ip 172.20.0.21 -e NODE_ENV=$NODE_ENV  -e NODE_HOST=$NODE_HOST --name  strapi --net mynet123 -v  /app/jenkins_home/workspace/production/dist:/app/public -v /app/pcloud:/app/public/uploads 192.168.64.15:5000/qcloud_backend:$new_version    
        else
            echo "Please check in manualy!"
        fi
    fi
    echo "Completing!"
    ;;
  Rollback)
    echo "Status:$Status"
    echo "rollback_version:$rollback_version"
    #cd ${WORKSPACE}/bak/$rollback_version            #进入备份目录
    count_img=$(docker images |grep -w qcloud_backend |grep -w $rollback_version |wc -l)
    count=$(docker ps -a|grep -w strapi |wc -l)
    if [ $count_img -eq 1 ];
    then
        echo "rollback start"
        if [ $count -eq 0 ];then
            #docker ps
            docker run -p 80:1337 -itd --restart=always --ip 172.20.0.21 -e NODE_ENV=$NODE_ENV  -e NODE_HOST=$NODE_HOST --name  strapi --net mynet123 -v  /app/jenkins_home/workspace/production/dist:/app/public -v /app/pcloud:/app/public/uploads 192.168.64.15:5000/qcloud_backend:$new_version    
        elif [ $count -eq 1 ];then
            #docker images
            docker stop strapi
            sleep 1
            docker rm strapi
            sleep 1
            docker run -p 80:1337 -itd --restart=always --ip 172.20.0.21 -e NODE_ENV=$NODE_ENV  -e NODE_HOST=$NODE_HOST --name  strapi --net mynet123 -v  /app/jenkins_home/workspace/production/dist:/app/public -v /app/pcloud:/app/public/uploads 192.168.64.15:5000/qcloud_backend:$new_version    
        else
            echo "Please check in manualy!"
        fi
    else
    	echo "Please check the image version manualy!"
    fi
    echo "Completing!"
    #cp -f *.war ${WORKSPACE}/target/       #将备份拷贝到程序打包目录中，并覆盖之前的war包
    ;;
  *)
  exit
    ;;
esac
