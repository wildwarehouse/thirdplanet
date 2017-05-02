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
    noblankout "$(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.home)" "There is already a home volume." 67 &&
    docker volume create --label com.emorymerryman.tstamp=$(date +%s) --label com.emorymerryman.thirdplanet.structure.home &&
    docker run --interactive --tty --rm --env NAME=home --volume $(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.home):/srv wildwarehouse/chown:2.0.2 