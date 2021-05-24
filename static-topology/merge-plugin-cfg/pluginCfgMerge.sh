#!/bin/bash

# (C) Copyright IBM Corporation 2015.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

if [[ -z "${JAVA_HOME}" ]]; then
    echo "Please set the environment variable JAVA_HOME"
    exit 1
fi

if [[ -z "${WLP_HOME}" ]]; then
    echo "Please set the environment variable WLP_HOME to your WLP root path"
    exit 1
fi

JAVA_CMD=${JAVA_HOME}/jre/bin/java
if [[ ! -d "${JAVA_HOME}/jre" ]]; then
    JAVA_CMD=${JAVA_HOME}/bin/java
fi

PLUGIN_MERGE_JAR=$(find "${WLP_HOME}/lib" -name com.ibm.ws.http.plugin.merge_*.jar)
if [[ -z "${PLUGIN_MERGE_JAR}" ]]; then
    echo "Unable to find com.ibm.ws.http.plugin.merge jar in '${WLP_HOME}/lib'"
    exit 1
fi

LOGGING_JAR=$(find "${WLP_HOME}/lib" -name com.ibm.ws.logging_*.jar)
if [[ -z "${LOGGING_JAR}" ]]; then
    echo "Unable to find com.ibm.ws.logging jar in '${WLP_HOME}/lib'"
    exit 1
fi

MAINCLASS=com.ibm.ws.http.plugin.merge.internal.PluginMergeToolImpl
$JAVA_CMD -cp "${PLUGIN_MERGE_JAR}:${LOGGING_JAR}" $MAINCLASS $@