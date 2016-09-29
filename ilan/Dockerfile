############################################################################
# (C) Copyright IBM Corporation 2015.                                      #
#                                                                          #
# Licensed under the Apache License, Version 2.0 (the "License");          #
# you may not use this file except in compliance with the License.         #
# You may obtain a copy of the License at                                  #
#                                                                          #
#      http://www.apache.org/licenses/LICENSE-2.0                          #
#                                                                          #
# Unless required by applicable law or agreed to in writing, software      #
# distributed under the License is distributed on an "AS IS" BASIS,        #
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. #
# See the License for the specific language governing permissions and      #
# limitations under the License.                                           #
#                                                                          #
############################################################################

FROM ubuntu:16.04

MAINTAINER Kavitha Suresh Kumar <kavisuresh@in.ibm.com>

RUN apt-get update && apt-get install -y openssl wget

ARG USER=was
ARG GROUP=was
ARG TAR_URL

COPY ihsstart.sh /work/  

RUN groupadd $GROUP \
    && useradd $USER -g $GROUP -m \
    && chown -R $USER:$GROUP /work /opt

USER $USER

RUN echo $TAR_URL

RUN wget -q -O - $TAR_URL | tar xz

RUN ln -s /opt/IBM/HTTPServer/java /opt/IBM/WebSphere/Plugins/java \
    && ln -s /opt/IBM/HTTPServer/java /opt/IBM/WebSphere/Toolbox/java \
    && chmod +x /work/ihsstart.sh

CMD ["/work/ihsstart.sh"]
