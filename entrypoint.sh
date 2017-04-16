#!/bin/sh


docker \
    run \
    --interactive \
    --rm \
    --env ENTRYPOINT=$(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.entrypoint) \
    --volume $(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.entrypoint):/usr/local/src \
    --workdir /usr/local/src \
    docker/compose:1.11.2 up -d
