#!/bin/bash -ilex

echo ${BUILD_TIMESTAMP}
nginx_dir="/var/jenkins_home/workspace/nginx"
frontend_workspace="/var/jenkins_home/workspace/pcl-qcloud-frontend"
backend_workspace="/var/jenkins_home/workspace/pcl-qcloud-backend"
#alias cnpm="npm --registry=https://registry.npm.taobao.org \
#--cache=$HOME/.npm/.cache/cnpm \
#--disturl=https://npm.taobao.org/mirrors/node \
#--userconfig=$HOME/.cnpmrc"
#export NODE_HOME=/usr/local/node-v10.16.3-linux-x64
#export PATH=$PATH:$NODE_HOME/bin
if [ $GIT_PREVIOUS_SUCCESSFUL_COMMIT == $GIT_COMMIT ];then
        echo "no change,skip build";
        exit 0
else
		echo "git pull commit id not equals to current commit id trigger build"
		/usr/local/node/bin/cnpm install
		#npm install
		echo $NODE_ENV
		/usr/local/node/bin/npm run build
		#npm run test:unit-coverage
        cp -r -f ./dist/* $backend_workspace/public/
        if [ -d "$nginx_dir/dist" ];then
			echo "文件夹存在,将执行删除操作"
			rm -rf $nginx_dir/dist
        	cp -r -f $frontend_workspace/dist $nginx_dir
			echo "删除完成,并拷贝新文件夹，将重启后端"
            docker restart strapi
		else
			echo "文件夹不存在,将执行文件夹拷贝"
        	cp -r -f $frontend_workspace/dist $nginx_dir
            echo "拷贝完成,将重启后端"
            docker restart strapi
		fi
		
fi
