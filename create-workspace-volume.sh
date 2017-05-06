#!/bin/sh

blankout(){
    if [ -z "${1}" ]
    then
        echo ${2} &&
            exit ${3}
    fi
} &&
    noblankout(){
        if [ ! -z "${1}" ]
        then
            echo ${2} &&
                exit ${3}
        fi
    } &&
    while [ ${#} -gt 0 ]
    do
        case ${1} in
            *)
                echo Unknown Option: ${1} &&
                    exit 64
            ;;
        esac
    done &&
    noblankout "$(docker volume ls --quiet --filter label=com.emorymerryman.luckystar.structure.workspace)" "There is already a home volume." 67 &&
    docker volume create --label com.emorymerryman.tstamp=$(date +%s) --label com.emorymerryman.luckystar.structure.workspace &&
    docker \
        run \
        --interactive \
        --tty \
        --rm \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.luckystar.structure.workspace):/usr/local/src \
        --workdir /usr/local/src \
        --user root \
        bigsummer/mkdir:0.0.0 \
        workspace &&
    docker \
        run \
        --interactive \
        --tty \
        --rm \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.luckystar.structure.workspace):/usr/local/src \
        --workdir /usr/local/src \
        --user root \
        bigsummer/chown:0.0.0 \
        user:user workspace &&
    docker \
        run \
        --interactive \
        --tty \
        --rm \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.luckystar.structure.workspace):/usr/local/src \
        --workdir /usr/local/src/workspace \
        bigsummer/mkdir:0.0.0 \
        projects