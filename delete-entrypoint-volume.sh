#!/bin/sh

docker volume ls --quiet --filter label=com.emorymerryman.luckystar.structure.entrypoint | while read VOLUME
do
    docker volume rm ${VOLUME}
done
