# Building an IBM HTTP Server Image from an IHS Archive

The Dockerfile in the `archive` directory can be used to build an IBM HTTP Server (including the WebSphere plugin) image from
a single zip. This method does not require IM to be installed.

## Getting the Archive

Archive installs from IBM HTTP Server can be found on Fix Central. Links to the archives are also provided in each fix
pack document. Downloading the IBM HTTP Server archive file requires entitlement.

1. Visit [Fix list for IBM HTTP Server Version 9.0](https://www.ibm.com/support/pages/node/617655)
2. Select the desired fix pack
3. Click the link for `Download Fix Pack <fixpack>`
4. Go to the section `IBM HTTP Server and Web server Plug-ins archive packages`
5. Download the archive that matches the base image operating system and architecture
6. Place the image of your Docker context root.

## Building the Archive Image

Run this command to build the archive image:

```command
docker build -t name:tag --build-arg IHS_ARCHIVE_FILE=<ihs-archive-file> .
```

The Dockerfile will install IHS at `/opt/IHS`.

## Using the Archive Image

You can either add your IHS configuration and keystores directly to the Dockerfile, or you can use a another Dockerfile
and use the archive image as the base and then copy in your IHS files.

### Example IHS Dockerfile using Archive as the base image

```Dockerfile
# Specify the image you built before using the archive
FROM hwibell/ibm-http-server:9.0.5.7

# Copy in your IHS keystore file
COPY ihsserverkey.kdb /conf/
COPY ihsserverkey.sth /conf/

# Copy IHS config
COPY httpd.conf /conf/

# Copy plugin config
COPY plugin-cfg.xml /plugin/config/webserver1/
COPY key.p12 /tmp/

# Create plugin keystore and trust the Liberty certificate
RUN openssl pkcs1I2 -in /tmp/key.p12 -out /tmp/ihs.crt -nokeys -password pass:<liberty-keystore-password>
RUN /opt/IHS/bin/gskcapicmd -keydb -create -db /plugin/config/webserver1/plugin-key.kdb -pw <new-plugin-password> -stash
RUN /opt/IHS/bin/gskcapicmd -cert -add -db /plugin/config/webserver1/plugin-key.kdb -stashed -file /tmp/ihs.crt
```

## Getting the plugin from a local Liberty Container

If you are running Liberty locally in Docker, the script `archive/get-liberty-plugin-config.sh` can be used to get the
generated `plugin-cfg.xml` and keystore for Liberty. The above Dockerfile example includes commands to extract the
Liberty certificate and add it to the plugin keystore.
