#!/usr/bin/env sh

LOG=/tmp/ls_proxy.log
echo $0 >> $LOG
echo $@ >> $LOG
echo "pwd" >> $LOG
pwd >> $LOG

DIR=`dirname "$(readlink -f "$0")"`
# TODO: Don't hard-code path
# $DIR/ls_proxy | /home/jason/config/repos/elixir-ls/release/real_language_server.sh
~/dev/ls_proxy/ls_proxy
