#!/bin/bash
# https://stackoverflow.com/questions/2746553/read-values-into-a-shell-variable-from-a-pipe

cat | while read x ; do echo "got $x" ; done
