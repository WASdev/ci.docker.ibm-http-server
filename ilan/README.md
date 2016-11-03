# Building an IBM HTTP Server ILAN image from binaries

An IBM HTTP Server ILAN image can be built by running one script.

This repository contains build scripts that can be used for building an IHS Docker image. The output of the build will give you IHS, the IHS plugins and the IBM customisation tools.

Versions available:
8.5.5.9
8.5.5.10
9.0.0.0

Pre-req
You are required to download a version of IBM Installation Manager above version 8 and place it into the /ilan/im directory.
Download Location: [IBM Support] (http://www-01.ibm.com/support/docview.wss?uid=swg27025142)

If you require all available versions of IHS then simply run the script buildAll with the arguments of a IBM ID and password. These are required for downloading the binaries as part of the installation. If you just want to build a specific version then you can run the build script with the version you require followed by an IBM ID and password.

## Running the IBM HTTP Server ILAN image

Run the HTTP Server container using:

```bash
docker run --name <container-name> -h <container-name> -p 80:80 <install-image-name>
```
Example:

```bash
docker run --name ihs -h ihs -p 80:80 ihsimage
```
