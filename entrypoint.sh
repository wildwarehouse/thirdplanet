#!/bin/sh

docker \
    run \
    --interactive \
    --rm \
    --env DISPLAY \
    --env HOST_UID=1000 \
    --env HOST_USER=aaja0ify \
    --env DOT_SSH=$(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.github.dot_ssh) \
    --env BIN=$(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.bin) \
    --env ENTRYPOINT=$(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.entrypoint) \
    --volume $(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.entrypoint):/opt/luckystar \
    --volume /var/run/docker.sock:/var/run/docker.sock:ro \
    --workdir /opt/luckystar \
    docker/compose:1.11.2 ${@}
