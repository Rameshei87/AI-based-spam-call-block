#!/bin/sh

#   Copyright (c) 2006, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
# -----------------------------------------------------------------------------

# Environment Variable Prequisites#
#   ESB_HOME   Home of WSO2 ESB installation. Detected if not available.#
#   JAVA_HOME  Must point at your Java Development Kit installation.
#
# NOTE: Borrowed generously from Apache Tomcat startup scripts.
#JAVA_HOME=/jdk1.5.0_15
# if JAVA_HOME is not set we're not happy
if [ -z "$JAVA_HOME" ]; then
  echo "You must set the JAVA_HOME variable"
  exit 1
fi

# OS specific support.  $var _must_ be set to either true or false.
cygwin=false
os400=false
case "`uname`" in
CYGWIN*) cygwin=true;;
OS400*) os400=true;;
esac

# resolve links - $0 may be a softlink
PRG="$0"

while [ -h "$PRG" ]; do
  ls=`ls -ld "$PRG"`
  link=`expr "$ls" : '.*-> \(.*\)$'`
  if expr "$link" : '.*/.*' > /dev/null; then
    PRG="$link"
  else
    PRG=`dirname "$PRG"`/"$link"
  fi
done

# Get standard environment variables
PRGDIR=`dirname "$PRG"`

# Only set ESB_HOME if not already set
[ -z "$ESB_HOME" ] && ESB_HOME=`cd "$PRGDIR/.." ; pwd`

# For Cygwin, ensure paths are in UNIX format before anything is touched
if $cygwin; then
  [ -n "$JAVA_HOME" ] && JAVA_HOME=`cygpath --unix "$JAVA_HOME"`
  [ -n "$ESB_HOME" ] && ESB_HOME=`cygpath --unix "$ESB_HOME"`
  [ -n "$AXIS2_HOME" ] && TUNGSTEN_HOME=`cygpath --unix "$ESB_HOME"`
  [ -n "$CLASSPATH" ] && CLASSPATH=`cygpath --path --unix "$CLASSPATH"`
fi

# For OS400
if $os400; then
  # Set job priority to standard for interactive (interactive - 6) by using
  # the interactive priority - 6, the helper threads that respond to requests
  # will be running at the same priority as interactive jobs.
  COMMAND='chgjob job('$JOBNAME') runpty(6)'
  system $COMMAND

  # Enable multi threading
  export QIBM_MULTI_THREADED=Y
fi

# update classpath with Tomcat JARs
ESB_CLASSPATH="$ESB_HOME/tomcat/conf":"$ESB_HOME/tomcat/lib"
for f in $ESB_HOME/tomcat/lib/*.jar
do
  ESB_CLASSPATH=$ESB_CLASSPATH:$f
done

# update classpath with Patches
ESB_CLASSPATH=$ESB_CLASSPATH:"$ESB_HOME/webapp/WEB-INF/lib/patches"
for f in $ESB_HOME/webapp/WEB-INF/lib/patches/*.jar
do
  ESB_CLASSPATH=$ESB_CLASSPATH:$f
done

# update classpath with libs
ESB_CLASSPATH=$ESB_CLASSPATH:"$ESB_HOME/webapp/WEB-INF/classes/conf":"$ESB_HOME/webapp/WEB-INF/lib"
for f in $ESB_HOME/webapp/WEB-INF/lib/*.jar
do
  ESB_CLASSPATH=$ESB_CLASSPATH:$f
done

# update classpath with custom extensions
for f in $ESB_HOME/webapp/WEB-INF/lib/extensions/*.jar
do
  ESB_CLASSPATH=$ESB_CLASSPATH:$f
done

# update classpath with tools.jar
ESB_CLASSPATH=$ESB_CLASSPATH:$JAVA_HOME/lib/tools.jar

# For Cygwin, switch paths to Windows format before running java
if $cygwin; then
  JAVA_HOME=`cygpath --absolute --windows "$JAVA_HOME"`
  ESB_HOME=`cygpath --absolute --windows "$ESB_HOME"`
  AXIS2_HOME=`cygpath --absolute --windows "$ESB_HOME"`
  CLASSPATH=`cygpath --path --windows "$CLASSPATH"`
  JAVA_ENDORSED_DIRS=`cygpath --path --windows "$JAVA_ENDORSED_DIRS"`
fi

# endorsed dir
ESB_ENDORSED=$ESB_HOME/webapp/WEB-INF/lib/endorsed:$JAVA_HOME/jre/lib/endorsed

# synapse.xml
SYNAPSE_XML=
# serverName
SERVER_NAME=

if [ "$1" = "-xdebug" ]; then
  XDEBUG="-Xdebug -Xnoagent -Xrunjdwp:transport=dt_socket,server=y,address=8000"
fi

if [ "$1" = "-sample" ]; then
  SYNAPSE_XML=-Dsynapse.xml=$ESB_HOME/repository/conf/sample/synapse_sample_$2.xml
fi

if [ "$1" = "-serverName" ]; then
  SERVER_NAME="-DserverName=$2"
fi

if [ "$3" = "-xdebug" ]; then
  XDEBUG="-Xdebug -Xnoagent -Xrunjdwp:transport=dt_socket,server=y,address=8000"
fi

if [ "$3" = "-sample" ]; then
  SYNAPSE_XML=-Dsynapse.xml=$ESB_HOME/repository/conf/sample/synapse_sample_$4.xml
fi

if [ "$3" = "-serverName" ]; then
  SERVER_NAME="-DserverName=$4"
fi

if [ "$5" = "-xdebug" ]; then
  XDEBUG="-Xdebug -Xnoagent -Xrunjdwp:transport=dt_socket,server=y,address=8000"
fi

if [ "$5" = "-sample" ]; then
  SYNAPSE_XML=-Dsynapse.xml=$ESB_HOME/repository/conf/sample/synapse_sample_$6.xml
fi

if [ "$5" = "-serverName" ]; then
  SERVER_NAME="-DserverName=$6"
fi

# ----- Uncomment the following line to enalbe the SSL debug options ----------
# TEMP_PROPS="-Djavax.net.debug=all"

# ----- Execute The Requested Command -----------------------------------------

cd $ESB_HOME
echo "Starting WSO2 Enterprise Service Bus ..."
echo "Using ESB_HOME:        $ESB_HOME"
echo "Using JAVA_HOME:       $JAVA_HOME"
if [ -z "SYNAPSE_XML" ]; then
  echo "Using SYNAPSE_XML:     $SYNAPSE_XML"
fi

$JAVA_HOME/bin/java -server -Xms128M -Xmx128M -XX:+UseParallelGC \
    $XDEBUG \
    $TEMP_PROPS \
    $SYNAPSE_XML \
    $SERVER_NAME \
    -Djava.io.tmpdir=$ESB_HOME/work/temp/esb \
    -Dorg.apache.xerces.xni.parser.XMLParserConfiguration=org.apache.xerces.parsers.XMLGrammarCachingConfiguration \
    -Dcom.sun.management.jmxremote \
    -Djava.endorsed.dirs=$ESB_ENDORSED \
    -classpath $ESB_CLASSPATH \
    org.wso2.esb.ServiceBus
