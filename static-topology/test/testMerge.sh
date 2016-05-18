#!/bin/bash
#
# (C) Copyright IBM Corporation 2015.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
HELP="--help"
	if [[ $1 -eq $HELP ]]
			then
				echo "USAGE"
				echo "            No args are required! "
				echo "DESCRIPTION"
				echo "                       "
				echo "            This test has been created to help test the Static-Topology scripts"
				echo "            This test runs in a docker enviroment so Docker must be installed on the"
				echo "            the host machine that this script is running on."
				echo "            This script will build and run two containers of WebSphere-Liberty coppying in the required files"
				echo "            It will then check to see when WebSphere-Liberty has started and run the GenPluginCfg.sh script to "
				echo "            generate the xml for each liberty instance. Another Liberty container is then spun up and the xml"
				echo "            is coppied into the new container and the merge script is then run to produce the final merged.xml"
			else
				cd ..
				cd gen-plugin-cfg
				docker build -t baseliberty .
				cd ..
				cd test

				#Create docker bridge network
				docker network create net1
				docker build -t liberty .
				docker run -d --name liberty1 -h liberty1 --net=net1 liberty
				docker run -d --name liberty2 -h liberty2 --net=net1 liberty
				docker run -d --name liberty3 -h liberty3 --net=net1 liberty

				#This section waits for Liberty to start otherwise the GenPluginCfg.sh script fails
				echo "  "
				echo "The test is waiting for all Liberty containers to start"
				found=1
				while [ $found != 0 ];
				do
				sleep 3s
				docker logs liberty1 | grep "ready to run a smarter planet"
				found=$?
				done
				docker exec liberty1 /opt/ibm/wlp/bin/GenPluginCfg.sh --installDir=/opt/ibm/wlp --userDir=/opt/ibm/wlp/usr --serverName=defaultServer

				found2=1
				while [ $found2 != 0 ];
				do
				sleep 3s
				docker logs liberty2 | grep "ready to run a smarter planet"
				found2=$?
				done
				docker exec liberty2 /opt/ibm/wlp/bin/GenPluginCfg.sh --installDir=/opt/ibm/wlp --userDir=/opt/ibm/wlp/usr --serverName=defaultServer

				found3=1
				while [ $found3 != 0 ];
				do
				sleep 3s
				docker logs liberty3 | grep "ready to run a smarter planet"
				found3=$?
				done
				docker exec liberty3 /opt/ibm/wlp/bin/GenPluginCfg.sh --installDir=/opt/ibm/wlp --userDir=/opt/ibm/wlp/usr --serverName=defaultServer

				cd ..
				cd get-plugin-cfg
				./GetPluginCfg.sh liberty1 liberty1
				mv plugin-cfg.xml plugin-cfg1.xml
				./GetPluginCfg.sh liberty2 liberty2
				mv plugin-cfg.xml plugin-cfg2.xml
				./GetPluginCfg.sh liberty3 liberty3
				mv plugin-cfg.xml plugin-cfg3.xml

				cd ..
				mv get-plugin-cfg/plugin-cfg1.xml merge-plugin-cfg/plugin-cfg1.xml
				mv get-plugin-cfg/plugin-cfg2.xml merge-plugin-cfg/plugin-cfg2.xml
				mv get-plugin-cfg/plugin-cfg3.xml merge-plugin-cfg/plugin-cfg3.xml
				cd merge-plugin-cfg

				echo "   "
				echo "Creating new liberty container with the required .jar file"
				docker build -t libertytwo .
				docker run -d --name=liberty4 libertytwo
				echo "Copying xml to the container"
				docker cp plugin-cfg1.xml liberty4:/tmp
				docker cp plugin-cfg2.xml liberty4:/tmp
				docker cp plugin-cfg3.xml liberty4:/tmp
				docker cp pluginCfgMerge.sh liberty4:/tmp

				found4=1
				while [ $found4 != 0 ];
				do
				sleep 3s
				docker logs liberty4 | grep "ready to run a smarter planet"
				found4=$?
				done
				echo "   "
				echo "Executing merge script"
				docker exec liberty4 /tmp/pluginCfgMerge.sh /tmp/plugin-cfg1.xml /tmp/plugin-cfg2.xml /tmp/plugin-cfg3.xml /tmp/merge-cfg.xml
				cd ..
				docker cp liberty4:/tmp/merge-cfg.xml merge-plugin-cfg/merge-cfg.xml
				cd merge-plugin-cfg

				#This is the new section to support IHS
				echo "Pulling down and deploying the IHS image"
				docker run -d -p 80:80 -h ihs --net=net1  --name=ihs jamielcoleman/ihs:v1
				sleep 5s
				echo "Send the merged xml to the IHS Instance"
				docker cp merge-cfg.xml ihs:/opt/IBM/WebSphere/Plugins/config/webserver1/plugin-cfg.xml
				echo "Stopping and starting the ihs server"
		    docker exec ihs bash -c "/opt/IBM/HTTPServer/bin/apachectl stop"
				echo "ihs has stopped"
				sleep 3s
		    docker exec ihs bash -c "/opt/IBM/HTTPServer/bin/apachectl start"
				echo "ihs has started"
				sleep 3s

				#Getting the port numbers of the liberty instances that have been routed too
				echo "Starting comparisons"
				wget http://0.0.0.0:80/ferret -q -O ferret1.txt
				port1=$(head -75 ferret1.txt | tail -1 | cut -c 7-11) >> test.txt
				wget http://0.0.0.0:80/ferret -q -O ferret2.txt
				port2=$(head -75 ferret2.txt | tail -1 | cut -c 7-11) >> test.txt
				wget http://0.0.0.0:80/ferret -q -O ferret3.txt
				port3=$(head -75 ferret3.txt | tail -1 | cut -c 7-11) >> test.txt
				echo $port1
				echo $port2
				echo $port3

				wget http://0.0.0.0:80/ferret -q -O ferret11.txt
				port11=$(head -75 ferret1.txt | tail -1 | cut -c 7-11) >> test.txt
				wget http://0.0.0.0:80/ferret -q -O ferret22.txt
				port22=$(head -75 ferret2.txt | tail -1 | cut -c 7-11) >> test.txt
				wget http://0.0.0.0:80/ferret -q -O ferret33.txt
				port33=$(head -75 ferret3.txt | tail -1 | cut -c 7-11) >> test.txt
				echo $port11
				echo $port22
				echo $port33

				#Comparing ports
				echo "Comparing Ports"
				if [[ $port1 == $port11 ]]
				then
					result="PASS"
				else
					result="FAIL"
				fi
				if [[ $port2 == $port22 ]]
				then
					result="PASS"
				else
					result="FAIL"
				fi
				if [[ $port3 == $port33 ]]
				then
					result="PASS"
				else
					result="FAIL"
				fi
				echo "Test Result: $result"

				#Cleanup
				rm test.txt
				rm ferret1.txt
				rm ferret11.txt
				rm ferret2.txt
				rm ferret22.txt
				rm ferret3.txt
				rm ferret33.txt
				rm plugin-cfg1.xml
				rm plugin-cfg2.xml
				rm plugin-cfg3.xml
				rm merge-cfg.xml
				echo "Killing and removing the IHS container"
				docker stop ihs
				docker rm ihs
				echo "Killing and removing each Liberty container"
				docker stop liberty1
				docker stop liberty2
				docker stop liberty3
				docker stop liberty4
				docker rm liberty1
				docker rm liberty2
				docker rm liberty3
				docker rm liberty4

fi
