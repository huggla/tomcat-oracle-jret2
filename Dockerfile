ARG TAG="20190115"
ARG CONTENTIMAGE1="tomcat:9-jre8-alpine"
ARG CONTENTSOURCE1="/usr/local/tomcat"
ARG CONTENTDESTINATION1="/buildfs$CONTENTSOURCE1"
ARG CONTENTIMAGE2="anapsix/alpine-java:9"
ARG CONTENTSOURCE2="/opt/jdk"
ARG CONTENTDESTINATION2="/buildfs$CONTENTSOURCE2"
ARG MAKEDIRS="/usr/lib/"
ARG RUNDEPS="libssl1.1 apr"
ARG BUILDDEPS="rsync"
ARG BUILDCMDS=\
"   rsync -r --ignore-existing /imagefs$CONTENTSOURCE1/native-jni-lib/* /imagefs/usr/lib/ "\
"&& rm -rf /imagefs$CONTENTSOURCE1/native-jni-lib "\
"&& chmod -R o= /imagefs$CONTENTSOURCE1 /imagefs$CONTENTSOURCE2 "\
"&& find /imagefs$CONTENTSOURCE1/bin/ -name '*.sh' -exec sed -ri 's|^#!/bin/bash$|#!/usr/local/bin/dash|' '{}' + "\
"&& find /imagefs$CONTENTSOURCE1/bin/ -name '*.sh' -exec sed -ri 's|^#!/usr/bin/env bash$|#!/usr/bin/env /usr/local/bin/dash|' '{}' +"
ARG REMOVEFILES="/usr/local/tomcat/webapps/examples"

#---------------Don't edit----------------
FROM ${CONTENTIMAGE1:-scratch} as content1
FROM ${CONTENTIMAGE2:-scratch} as content2
FROM ${INITIMAGE:-${BASEIMAGE:-huggla/base:$TAG}} as init
FROM ${BUILDIMAGE:-huggla/build} as build
FROM ${BASEIMAGE:-huggla/base:$TAG} as image
ARG CONTENTSOURCE1
ARG CONTENTDESTINATION1
ARG CONTENTSOURCE2
ARG CONTENTDESTINATION2
ARG DOWNLOADSDIR
ARG MAKEDIRS
ARG MAKEFILES
ARG EXECUTABLES
ARG EXPOSEFUNCTIONS
COPY --from=build /imagefs /
#-----------------------------------------

ENV VAR_LINUX_USER="tomcat" \
    VAR_FINAL_COMMAND="JAVA_HOME=\"$CONTENTSOURCE2\" CATALINA_HOME=\"$CONTENTSOURCE1\" CATALINA_OPTS=\"\$VAR_CATALINA_OPTS\" JAVA_MAJOR=9 TOMCAT_MAJOR=9 CATALINA_OUT=\"\$VAR_CATALINA_OUT\" PATH=\"\$PATH:/usr/local/bin:$CONTENTSOURCE2/bin:$CONTENTSOURCE1/bin\" catalina.sh run" \
    VAR_CATALINA_OPTS="-Xms128m -Xmx756M -XX:SoftRefLRUPolicyMSPerMB=36000" \
    VAR_CATALINA_OUT="/dev/null"

#---------------Don't edit----------------
USER starter
ONBUILD USER root
#-----------------------------------------
