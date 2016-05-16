#! /bin/bash
#####################################################################################
#                                                                                   #
#  Script to start the server                                                       #
#                                                                                   #
#  Usage : ihsstart.sh                                                              #
#                                                                                   #
#####################################################################################

startServer()
{
    echo "Starting IBM HTTP Server "
    # Starting IBM HTTPServer
    /opt/IBM/HTTPServer/bin/apachectl start

    if [ $? = 0 ]
    then
       echo "IBM HTTP Server started successfully"
    else
       echo "Failed to start IBM HTTP Server"
    fi
}

stopServer()
{
    echo "Stopping IBM HTTP Server "
    # Stopping IBM HTTPServer
    /opt/IBM/HTTPServer/bin/apachectl graceful-stop
    if [ $? = 0 ]
    then
       echo "IBM HTTP Server stopped successfully"
    fi
}

startServer

trap "stopServer" SIGTERM  

sleep 10

while [ -f "/opt/IBM/HTTPServer/logs/httpd.pid" ]
do
   sleep 5
done
