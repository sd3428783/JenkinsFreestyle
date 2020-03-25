#!/bin/sh -l
echo $WORKSPACE
cd $WORKSPACE
/usr/local/sonar-scanner/bin/sonar-scanner
