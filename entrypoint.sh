#!/bin/sh

docker \
    run \
    --interactive \
    --tty \
    --rm \
    --volume $(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.entrypoint):/usr/local/src \
    --workdir /usr/local/src \
    tidyrailroad/docker-compose:0.0.0 \
    up -d