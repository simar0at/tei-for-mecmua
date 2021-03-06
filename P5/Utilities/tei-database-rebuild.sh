#!/bin/sh
# Rebuild TEI eXist database
# Sebastian Rahtz
# 2005-04-22
# License: GPL

X=/usr/share/xml/tei/xquery
S=/usr/share/xml/tei/odd

HOSTNAME=`hostname`
HOST=localhost
PORT=8080
WEBAPP=exist

case $HOSTNAME in
   teivm.village.Virginia.EDU) HOST=www.tei-c.org;PORT=8040;WEBAPP=exist;;
   tei.oucs.ox.ac.uk) HOST=localhost;PORT=8080;WEBAPP=exist;;
esac
OPTS="--webapp=$WEBAPP --port=$PORT --host=localhost "
echo Using $HOST:$PORT/$WEBAPP

cd /tmp
echo remove existing collection in eXist
perl $X/addtoexist.pl $OPTS --remove=/db/TEI
perl $X/addtoexist.pl $OPTS --remove=/db/system/config/db/TEI/index.xconf
echo add config,  $X/index.xconf
perl $X/addtoexist.pl $OPTS -c /db/system/config/db/TEI -s $X/index.xconf
echo add TEI P5, $S/p5subset.xml
perl $X/addtoexist.pl $OPTS -c /db/TEI -s $S/p5subset.xml
