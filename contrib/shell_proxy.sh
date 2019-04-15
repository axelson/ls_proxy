#!/usr/bin/env sh
echo $0 >> /tmp/mylog.txt
echo $@ >> /tmp/mylog.txt
echo "env:" >> /tmp/mylog.txt
env >> /tmp/mylog.txt
echo "pwd" >> /tmp/mylog.txt
pwd >> /tmp/mylog.txt
DIR=`dirname "$(readlink -f "$0")"`
echo "DIR: $DIR" >> /tmp/mylog.txt
tee -a /tmp/tee_log.txt | $DIR/real_language_server.sh
