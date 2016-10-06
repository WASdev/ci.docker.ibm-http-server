# Building an IBM HTTP Server ILAN image from binaries

An IBM HTTP Server ILAN image can be built by running one script.

Versions available:
8.5.5.9
8.5.5.10
9.0.0.0

If you require all available versions of IHS then simply run the script buildAll with the arguments of a IBM ID and password.
These are required for downloading the binaries as part of the installation.

If you just want to build a specific version then you can run the build script with the version you require followed by an IBM ID and password.

You are required to download a version of IBM installation manager above version 8 and place it into the /ilan/im/ directory in this repository.

The build runs in two parts
The first part does the following:

1. Installs IBM Installation Manager
2. Installs IBM HTTP Server
3. Updates IBM HTTP Server with the Fixpack
4. Installs WebServer Plugins
5. Updates WebServer Plugins with the Fixpack
6. Installs WebSphere Customization Tools
7. Updates WebSphere Customization Tools with the Fixpack
8. When the container is started a tar file of the IBM HTTP Server, WebServer Plugins and WCT installation is created

The second part of the build does the following:   

1. Extracts the tar file created by the first part of the build
2. Copies the startup script to the image
3. When the container is started the IHS server is started

## Running the IBM HTTP Server ILAN image

Run the HTTP Server container using:

```bash
docker run --name <container-name> -h <container-name> -p 80:80 <install-image-name>
```
Example:

```bash
docker run --name ihs -h ihs -p 80:80 ihsimage
```
