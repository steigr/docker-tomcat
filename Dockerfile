FROM steigr/java:8_server-jre_unlimited

RUN  export pkgname=tomcat-native pkgver=1.2.12 \
 &&  apk add --no-cache --virtual .runtime-deps apr \
 &&  apk add --no-cache --virtual .build-deps apr-dev chrpath openjdk8 curl tar openssl-dev gcc make libc-dev \
 &&  mkdir /usr/src \
 &&  cd /usr/src \
 &&  curl -sL http://www-eu.apache.org/dist/tomcat/tomcat-connectors/native/$pkgver/source/$pkgname-$pkgver-src.tar.gz \
     | tar -xvz \
 &&  cd tomcat-native-$pkgver-src/native \
 &&  ./configure --prefix=/usr --with-java-home=$(find /usr -name jni_md.h | grep x86_64-alpine-linux-musl | head -1 | xargs dirname | xargs dirname) --with-ssl=yes \
 &&  DESTDIR=/usr/src/tomcat-native-${pkgver}-dist make install \
 &&  ( cd /usr/src/tomcat-native-${pkgver}-dist; find * -name '*.so*' -type f | xargs -t -r -n1 strip -s) \
 &&  ( cd /usr/src/tomcat-native-${pkgver}-dist; tar -c $(find * -name '*.so*')) | tar -x -C / \
 &&  cd / \
 &&  rm -rf /usr/src \
 &&  apk del .build-deps

RUN  export TOMCAT_VERSION=8.5.11 \
 &&  apk add --no-cache --virtual .build-deps tar curl \
 &&  mkdir /tomcat \
 &&  curl -sL http://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_VERSION:0:1}/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz \
     | tar -x -z -v -C /tomcat --strip-components=1 --wildcards "apache-tomcat-$TOMCAT_VERSION/bin/*" "apache-tomcat-$TOMCAT_VERSION/lib/*" \
 &&  ( cd /tomcat && tar c bin lib ) > /tomcat-$TOMCAT_VERSION.tar \
 &&  apk del .build-deps \
 &&  rm -rf /var/cache/apk/* /tomcat

ADD scripts/tomcat-configurator  /tomcat-configurator
ADD scripts/log4j-configurator   /log4j-configurator
ADD scripts/tomcat-install       /bin/tomcat-install
ADD scripts/idenity-configurator /idenity-configurator
CMD ["/tomcat/bin/catalina.sh","run"]