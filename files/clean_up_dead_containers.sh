#!/bin/bash

LOGGER_TAG=$(basename -- "$0")
DEAD_CONTAINERS=$(docker ps -a -q -f status=dead)

if [ -n "$DEAD_CONTAINERS" ]; then
    docker rm $DEAD_CONTAINERS 2>&1 >/dev/null | awk '{print "umount " $19}' | bash  | logger -t ${LOGGER_TAG%.*}
    docker ps -a -q -f status=dead | xargs docker rm | logger -t ${LOGGER_TAG%.*}
else
    echo "No dead containers."
fi
