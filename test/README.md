# Building and Testing images 

IBM HTTP Server images can be built and verified using the test scripts provided.

## Build and Test image

1. Clone this repository.
2. Move to the directory `test`.
3. Build and Test image using:

    ```bash
    sh buildAndverify.sh <image-name> <dockerfile-location> <URL>`
    ```

Parameter values for building IHS ILAN images:

* image-name - ilan
* dockerfile-location - ../ilan
* URL - URL where the binaries are placed

Parameter values for building IHS production  images:
                                                  
* image-name - production
* dockerfile-location - ../production                   
* URL - URL where the binaries are placed

