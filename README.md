# IBM HTTP Server and Docker

## Support Statement

This repository can still be used to build IBM HTTP Server images, but these images are no longer being published to the
[ibmcom](https://hub.docker.com/r/ibmcom/) Docker Hub registry. The `ibmcom/ibm-http-server` images are no longer
published and have been removed.

These images are also not supported when deployed using OpenShift or Kubernetes.

## Building the Images

### Archive Builds (IBM HTTP Server 9.0 and above only)

Building the IHS image using an IHS archive is the simplest method as it does not require IM to be installed. The IHS
archive also includes the WebSphere plugin files under the `plugin` directory. This is the recommended way to build the
IHS image. Note that IHS archive requires entitlement.

* [IBM HTTP Server Archive image](https://github.com/WASdev/ci.docker.ibm-http-server/tree/master/archive)

### Installation Manager Builds

The ILAN and production images have a dependency on IBM Installation Manager in order to be built. We recommend building
the IBM HTTP Server images from an archive instead since it requires you to collect zip file instead of several.

* [IBM HTTP Server ILAN image](https://github.com/WASdev/ci.docker.ibm-http-server/tree/master/ilan)
* [IBM HTTP Server Production image](https://github.com/WASdev/ci.docker.ibm-http-server/tree/master/production)
