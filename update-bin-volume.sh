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
    blankout "$(docker volume ls --quiet --filter label=com.emorymerryman.luckystar.structure.sbin)" "There is no sbin volume." 66 &&
    blankout "$(docker volume ls --quiet --filter label=com.emorymerryman.luckystar.structure.bin)" "There is no bin volume." 67 &&
    docker \
        run \
        --interactive \
        --tty \
        --rm \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.luckystar.structure.sbin):/usr/local/src:ro \
        --workdir /usr/local/src \
        bigsummer/ls:0.0.0 \
        -1 | while read SCRIPT
        do
            echo ${SCRIPT} &&
            echo -en "#!/bin/sh\n\n/usr/local/sbin/${SCRIPT} \"\${@}\"" | docker \
                run \
                --interactive \
                --rm \
                --volume $(docker volume ls --quiet --filter label=com.emorymerryman.luckystar.structure.bin):/usr/local/src \
                --workdir /usr/local/src \
                --user root \
                bigsummer/tee:0.0.0 \
                ${SCRIPT%.*} &&
                docker \
                    run \
                    --interactive \
                    --rm \
                    --volume $(docker volume ls --quiet --filter label=com.emorymerryman.luckystar.structure.bin):/usr/local/src \
                    --workdir /usr/local/src \
                    --user root \
                    bigsummer/chmod:0.0.0 \
                    0555 ${SCRIPT%.*}
        done