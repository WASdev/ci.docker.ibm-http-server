# Building an IBM HTTP Server v8.5.5 production image from binaries

An IBM HTTP Server production image can be built by obtaining the following binaries:
* IBM Installation Manager binaries from [Passport Advantage](http://www-01.ibm.com/software/passportadvantage/pao_customer.html)

  IBM Installation Manager binaries:
  * Install_Mgr_v1.6.2_Lnx_WASv8.5.5.zip(CIK2GML) 

* IBM HTTP Server,IBM WebServer Plugins and IBM WebSphere Customization Tools binaries from [Passport Advantage](http://www-01.ibm.com/software/passportadvantage/pao_customer.html) / [Fix Central](http://www-933.ibm.com/support/fixcentral/)

  IBM HTTP Server,IBM WebServer Plugins and IBM WebSphere Customization Tools 8.5.5 binaries:
  * WAS_V8.5.5_SUPPL_1_OF_3.zip(CIK1VML)
  * WAS_V8.5.5_SUPPL_1_OF_3.zip(CIK1WML)
  * WAS_V8.5.5_SUPPL_1_OF_3.zip(CIK1XML)

  Fixpack 8.5.5.8 binaries:
  * 8.5.5-WS-WASSupplements-FP0000008-part1.zip
  * 8.5.5-WS-WASSupplements-FP0000008-part2.zip
  * 8.5.5-WS-WCT-FP0000008-part1.zip
  * 8.5.5-WS-WCT-FP0000008-part2.zip

IBM HTTP Server production install image is created in two steps using the following two Dockerfiles to reduce the final image size:

1. Dockerfile.prereq
2. Dockerfile.install

Dockerfile.prereq does the following:
 
1. Installs IBM Installation Manager
2. Installs IBM HTTP Server 
3. Updates IBM HTTP Server with the Fixpack
4. Installs WebServer Plugins
5. Updates WebServer Plugins with the Fixpack
6. Installs WebSphere Customization Tools
7. Updates WebSphere Customization Tools with the Fixpack
8. When the container is started a tar file of the IBM HTTP Server, WebServer Plugins and WCT installation is created

The Dockerfile.prereq take the value for the following variable during build time: 
* URL(required) - URL from where the binaries are downloaded

Dockerfile.install does the following:                                                                                                           

1. Extracts the tar file created by Dockerfile.prereq
2. Copies the startup script to the image
3. When the container is started the IHS server is started

## Building the IBM HTTP Server production image

1. Place the downloaded IBM Installation Manager and IBM HTTP Server binaries on the FTP or HTTP server.
2. Clone this repository.
3. Move to the directory `production`.
4. Build the prereq image using:

    ```bash
    docker build --build-arg URL=<URL> -t <prereq-image-name> -f Dockerfile.prereq .
    ```

5. Run a container using the prereq image to create the tar file in the current folder using:

    ```bash
    docker run --rm -v $(pwd):/tmp <prereq-image-name>
    ```

6. Build the install image using:       

    ```bash
    docker build -t <install-image-name> -f Dockerfile.install .
    ```

## Running the IBM HTTP Server Production image                                                               
                                                                                                        
Run the HTTP Server container using:

```bash                                                                                             
docker run --name <container-name> -h <container-name> -p 80:80 <install-image-name>                        
```                                                                                                 

Example:                                                                                   
                                                                                          
```bash                                                                               
docker run --name ihs -h ihs -p 80:80 ihsimage                                             
```         
