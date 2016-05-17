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
				docker network create net1
				docker build -t liberty .
				docker run -d -P --net=net1 -h liberty1 --name=liberty1 liberty
				docker run -d -P --net=net1 -h liberty2 --name=liberty2 liberty
				docker run -d -P --net=net1 -h liberty3 --name=liberty3 liberty


				#This is the command for copying the generated xml FIXXXXX!""
				#docker cp $1:/opt/ibm/wlp/output/defaultServer/plugin-cfg.xml .


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
				./GetPluginCfg.sh liberty1 net1
				#docker cp liberty1:/opt/ibm/wlp/output/defaultServer/plugin-cfg.xml .
				mv plugin-cfg.xml plugin-cfg1.xml

				./GetPluginCfg.sh liberty2 net1
				#docker cp liberty2:/opt/ibm/wlp/output/defaultServer/plugin-cfg.xml .
				mv plugin-cfg.xml plugin-cfg2.xml

				./GetPluginCfg.sh liberty3 net1
				#docker cp liberty3:/opt/ibm/wlp/output/defaultServer/plugin-cfg.xml .
				mv plugin-cfg.xml plugin-cfg3.xml

				cd ..
				mv get-plugin-cfg/plugin-cfg1.xml merge-plugin-cfg/plugin-cfg1.xml
				mv get-plugin-cfg/plugin-cfg2.xml merge-plugin-cfg/plugin-cfg2.xml
				mv get-plugin-cfg/plugin-cfg3.xml merge-plugin-cfg/plugin-cfg3.xml
				cd merge-plugin-cfg

				echo "   "
				echo "Geting the port numbers of the running WebSphere-Liberty containers."
				port1=$(docker port liberty1| cut -c 21-26)
				lib1finalport1=$(echo $port1| cut -c 1-6)
				lib1finalport2=$(echo $port1| cut -c 7-13)
				port2=$(docker port liberty2| cut -c 21-26)
				lib2finalport1=$(echo $port2| cut -c 1-6)
				lib2finalport2=$(echo $port2| cut -c 7-13)
				port3=$(docker port liberty3| cut -c 21-26)
				lib3finalport1=$(echo $port3| cut -c 1-6)
				lib3finalport2=$(echo $port3| cut -c 7-13)

				echo "Printing ports for Liberty 1"
				echo $lib1finalport1
				echo $lib1finalport2

				echo "Printing ports for Liberty 2"
				echo $lib2finalport1
				echo $lib2finalport2

				echo "Printing ports fpr Liberty 3"
				echo $lib3finalport1
				echo $lib3finalport2

				echo "   "
				echo "Killing and removing each Liberty container"
				#docker stop liberty1
				#docker stop liberty2
				#docker stop liberty3
				#docker rm liberty1
				#docker rm liberty2
				#docker rm liberty3

				echo "   "
				echo "Creating new liberty container with the required .jar file"
				docker build -t libertytwo .
				docker run -d --name=liberty4 libertytwo
				echo "Copying xml to the container"
				docker cp plugin-cfg1.xml liberty4:/tmp
				docker cp plugin-cfg2.xml liberty4:/tmp
				docker cp plugin-cfg3.xml liberty4:/tmp
				docker cp pluginCfgMerge.sh liberty4:/tmp
				#Not using as it is not yet working...
				#echo "Downloading xml merge tool"
				#wget https://github.com/WASdev/sample.pluginmergetool/releases/download/1.0/PluginMergeTool-1.0.jar
				echo "Copying to the container"
				#docker cp PluginMergeTool-1.0.jar liberty4:/opt/ibm/wlp/lib/com.ibm.ws.http.plugin.merge_1.0.9.jar
				#work around for broken release of the merge tool on github
				docker cp com.ibm.ws.http.plugin.merge_1.0.131.jar liberty4:/opt/ibm/wlp/lib/com.ibm.ws.http.plugin.merge_1.0.9.jar
				echo "Tool Coppied"
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


				# echo "Testing to see if the final xml contains the required port numbers"
				# if grep -q $lib1finalport1 merge-cfg.xml && grep -q $lib1finalport2 merge-cfg.xml; then
				# 	echo "The ports for Liberty1 have been written to the merged xml file"
				# else
				# 	echo "Merge has not compleated successfully for Liberty1"
				# fi
				#
				# if grep -q $lib2finalport1 merge-cfg.xml && grep -q $lib2finalport2 merge-cfg.xml; then
				# 	echo "The ports for Liberty2 have been written to the merged xml file"
				# else
				# 	echo "Merge has not compleated successfully for Liberty2"
				# fi
				#
				# if grep -q $lib3finalport1 merge-cfg.xml && grep -q $lib3finalport2 merge-cfg.xml; then
				# 	echo "The ports for Liberty3 have been written to the merged xml file"
				# 	echo "    "
				# 	echo "Test Passed!!!"
				# else
				# 	echo "Merge has not compleated successfully for Liberty3"
				# 	echo "   "
				# 	echo "Test Failed!!!"
				# fi

				#Killing the final container!
				echo "   "
				echo "Killing the last Docker container"
				docker stop liberty4
				docker rm liberty4


				#This is the new section to support IHS
				echo "Pulling down and deploying the IHS image"
				docker run -d -p 80:80 --net=net1 -h test --name=ihs jamielcoleman/ihs:v1
				sleep 5s
				echo "Send the merged xml to the IHS Instance"
				docker cp merge-cfg.xml ihs:/opt/IBM/WebSphere/Plugins/config/webserver1/plugin-cfg.xml
				echo "Stopping and starting the ihs server"
		    docker exec ihs bash -c "/opt/IBM/HTTPServer/bin/apachectl stop"
				echo "ihs has stopped"
				#docker exec ihs rm /opt/IBM/WebSphere/Plugins/logs/webserver1/.......
				sleep 5s
		    docker exec ihs bash -c "/opt/IBM/HTTPServer/bin/apachectl start"
				echo "ihs has started"
				echo "Killing the IHS container"
				#docker stop ihs
				#docker rm ihs
				echo "Killing and removing each Liberty container"
				#docker stop liberty1
				#docker stop liberty2
				#docker stop liberty3
				#docker rm liberty1
				#docker rm liberty2
				#docker rm liberty3

fi