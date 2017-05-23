###########################################################################
# (C) Copyright IBM Corporation 2015, 2016.                               #
#                                                                         #
# Licensed under the Apache License, Version 2.0 (the "License");         #
# you may not use this file except in compliance with the License.        #
# You may obtain a copy of the License at                                 #
#                                                                         #
#      http://www.apache.org/licenses/LICENSE-2.0                         #
#                                                                         #
# Unless required by applicable law or agreed to in writing, software     #
# distributed under the License is distributed on an "AS IS" BASIS,       #
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.#
# See the License for the specific language governing permissions and     #
# limitations under the License.                                          #
###########################################################################

# This Dockerfile is meant to download the requisite software and tar them
# up for the final DockerFile which will not have the IBM_ID and
# IBM_PASSWORD saved

FROM ubuntu:16.04

RUN apt-get update && apt-get install --no-install-recommends -y unzip bsdtar && rm -rf /var/lib/apt/lists/*
# BSD tar is need to prevent errors on Docker builds
# see https://github.com/docker/hub-feedback/issues/727
RUN export tar='bsdtar'

# Install IBM Installation Manager
COPY im/agent.installer.linux.gtk.x86_64_*.zip /tmp/
RUN unzip -qd /tmp/im /tmp/agent.installer.linux.gtk.x86_64_*.zip \
  && /tmp/im/installc -acceptLicense -accessRights nonAdmin \
    -installationDirectory "/opt/IBM/InstallationManager"  \
    -dataLocation "/var/ibm/InstallationManager" -showProgress \
  && rm -rf /tmp/agent.installer.linux.gtk.x86_65_*.zip /tmp/im

ENV PATH /opt/IBM/InstallationManager/eclipse/tools:$PATH
RUN mkdir /host
RUN mkdir /target
COPY install_ihs.sh /host
COPY versions.csv /host
COPY Dockerfile.template /host
RUN chmod 700 /host/install_ihs.sh

# requires envvars
ARG VERSION
ARG IBM_ID
ARG IBM_PASSWORD
RUN /host/install_ihs.sh
RUN tar zcf /target/ihs${VERSION}.tar.gz /opt/IBM/HTTPServer /opt/IBM/WebSphere/Plugins /opt/IBM/WebSphere/Toolbox
RUN sed s/@VERSION@/${VERSION}/ /host/Dockerfile.template > /target/Dockerfile.${VERSION}
