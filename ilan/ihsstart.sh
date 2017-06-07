#! /bin/bash
#####################################################################################
#                                                                                   #
#  Script to start the server                                                       #
#                                                                                   #
#  Usage : ihsstart.sh                                                              #
#                                                                                   #
#####################################################################################

. /opt/IBM/HTTPServer/bin/envvars
exec /opt/IBM/HTTPServer/bin/httpd -d /opt/IBM/HTTPServer -DFOREGROUND
