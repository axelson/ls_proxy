#!/bin/bash
# https://stackoverflow.com/questions/2746553/read-values-into-a-shell-variable-from-a-pipe

FILE=/tmp/echo.log
echo "starting" >> $FILE
cat | while read x ; do echo "got $x" ; echo "got input $x" >> $FILE; done
echo "DONE" >> $FILE
