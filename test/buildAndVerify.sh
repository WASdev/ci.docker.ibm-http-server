#! /bin/bash                                                                         
#####################################################################################
#                                                                                   #
#  Script to build docker image and verify the image                                #
#                                                                                   #
#  Usage : buildAndVerify.sh <Image name> <Dockerfile location> <URL>               #
#                                                                                   #
#####################################################################################

image=$1                                                                  

tag=`echo $image | cut -d ":" -f2`

dloc=$2                                                                   
url=$3
                                                                          
cname=$image'test'                                                                                     

if [ $# != 3 ]                                                                       
then                                                                                 
    echo "Usage : buildAndVerify.sh <Image name> <Dockerfile location> <URL> "           
    exit 1                                                                         
fi                                                                                      
                                                                                        
echo "******************************************************************************"   
echo "           Starting docker prereq build for $image                            "   
echo "******************************************************************************"   

imagename=$image'tar'
docker build --build-arg URL=$url -t $imagename -f $dloc/Dockerfile.prereq $dloc

if [ $? = 0 ]
then
   docker run --rm -v $(pwd):/tmp $imagename
   mv ihs_plg_wct.tar $dloc
else
   echo "Build failed , exiting......."
fi

if [ $? = 0 ]
then
   echo "******************************************************************************"                                                           
   echo "           Prereq build completed successfully                                "
   echo "           Starting docker install build for $image                           "                                                           
   echo "******************************************************************************"    
   docker build  -t $image -f $dloc/Dockerfile.install $dloc
fi

cleanup()                                                                                                          
{                                                                                                                  
                                                                                                                   
   echo "------------------------------------------------------------------------------"                           
   echo "Starting Cleanup  "                                                                                       
   echo "Stopping Container $cname"                                                                                
   docker kill $cname                                                                                              
   echo "Removing Container $cname"                                                                                
   docker rm $cname                                                                                                
   echo "Cleanup Completed "                                                                                       
   echo "------------------------------------------------------------------------------"                           
}  

test1()                                                                                                            
{                                                                                                                  
   echo "******************************************************************************"                           
   echo "                       Executing  test1  - Container Runs                     "                                    
   echo "******************************************************************************"                           
                                                                                                                   
   docker ps -a | grep -i $cname                                                                                   
   if [ $? = 0 ]                                                                                                   
   then                                                                                                            
        cleanup                                                                                                    
   fi                                                                                                              
                                                                                                                   
   cid=`docker run --name $cname -h $cname -p 80:80 -d $image`                                                                    
   scid=${cid:0:12}                                                                                                
   sleep 10                                                                                                        
   if [ $scid != "" ]                                                                                              
   then                                                                                                            
       echo "Container running successfully"     
       cleanup
   else                                                                                                            
       echo "Container not started successfully, exiting"                                                        
       cleanup                                                                                                   
       exit 1                                                                                                    
   fi        
}

if [ $? = 0 ]                                                                                                      
then                                                                                                               
   echo "******************************************************************************"                          
   echo "                     $image image built successfully                                "                          
   rm -f $dloc/ihs_plg_wct.tar
   echo "******************************************************************************"                          
   test1                                                                                                          
   if [ $? = 0 ]                                                                                                  
   then                                                                                                           
       echo "******************************************************************************"                      
       echo "                       Test1 Completed Successfully                           "                      
       echo "******************************************************************************"                      
   fi                                                                                                             
else                                                                                                               
   echo " Build failed , exiting.........."                                                                       
   exit 1                                                                                                         
fi               
