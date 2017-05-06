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
    blankout "$(docker volume ls --quiet --filter label=com.emorymerryman.luckystar.structure.github.dot_ssh)" "There is no dot_ssh volume." 66 &&
    noblankout "$(docker volume ls --quiet --filter label=com.emorymerryman.luckystar.structure.bin)" "There is already a bin volume." 67 &&
    docker volume create --label com.emorymerryman.tstamp=$(date +%s) --label com.emorymerryman.luckystar.structure.bin &&
    docker \
        run \
        --interactive \
        --tty \
        --rm \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.luckystar.structure.bin):/usr/local/src \
        --workdir /usr/local/src \
        --user root \
        bigsummer/mkdir:0.0.0 \
        bin &&
     docker \
        run \
        --interactive \
        --tty \
        --rm \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.luckystar.structure.bin):/usr/local/src \
        --workdir /usr/local/src \
        --user root \
        bigsummer/chown:0.0.0 \
        user:user bin &&
    docker \
        run \
        --interactive \
        --rm \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.luckystar.structure.bin):/usr/local/src \
        --workdir /usr/local/src/bin \
        wildwarehouse/git:0.0.0 \
        init &&
     docker \
        run \
        --interactive \
        --rm \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.luckystar.structure.bin):/usr/local/src \
        --workdir /usr/local/src/bin \
        wildwarehouse/git:0.0.0 \
        remote add upstream ssh://upstream/wildwarehouse/thirdplanet.git