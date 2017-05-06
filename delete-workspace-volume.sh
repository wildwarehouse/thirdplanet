#!/bin/sh

docker volume ls --quiet --filter label=com.emorymerryman.luckystar.structure.workspace | while read VOLUME
do
    docker volume rm ${VOLUME}
done
