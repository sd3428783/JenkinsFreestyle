#!/bin/bash -ilex
echo ${BUILD_TIMESTAMP}
if [ $GIT_PREVIOUS_SUCCESSFUL_COMMIT == $GIT_COMMIT ];then
        echo "no change,skip build";
        exit 0
else
		echo "git pull commit id not equals to current commit id trigger build"
		/usr/local/node/bin/cnpm install
		echo $NODE_ENV
		/usr/local/node/bin/npm run buildPreProduction
fi
