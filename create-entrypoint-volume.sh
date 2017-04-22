#!/bin/sh

errorout(){
    if [ ${1} ]
    then
        echo ${2} &&
            exit ${3}
    fi
} &&
    while [ ${#} -gt 0 ]
    do
        case ${1} in
            --branch)
                BRANCH=${2} &&
                    shift &&
                    shift
            ;;
            *)
                echo Unknown Option: ${1} &&
                    exit 64
            ;;
        esac
    done &&
    errorout [ -z "${BRANCH}" ] "There is no BRANCH defined" 65 &&
    errorout [ -z "$(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.github.dot-ssh)" ] "There is no dot-ssh volume." 66 &&
    errorout [ ! -z "$(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.entrypoint)" ] "There is already a entrypoint volume." 67 &&
    docker volume create --label com.emorymerryman.tstamp=$(date +%s) --label com.emorymerryman.thirdplanet.structure.entrypoint &&
    docker \
        run \
        --interactive \
        --rm \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.entrypoint):/usr/local/src \
        --workdir /usr/local/src \
        tidyrailroad/git:0.2.0 \
        init &&
    docker \
        run \
        --interactive \
        --rm \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.entrypoint):/usr/local/src \
        --workdir /usr/local/src \
        tidyrailroad/git:0.2.0 \
        remote add upstream ssh://upstream/wildwarehouse/thirdplanet.git &&
    BIN=$(docker volume create --label com.emorymerryman.tstamp=$(date +%s) --label com.emorymerryman.temporary) &&
    (cat <<EOF
#!/bin/sh

docker \
    run \
    --interactive \
    --rm \
    --volume $(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.github.dot-ssh):/root/.ssh:ro \
    --volume $(docker volume ls --quiet --filter  label=com.emorymerryman.thirdplanet.structure.entrypoint):/usr/local/src \
    --workdir /usr/local/src \
    tidyrailroad/openssh-client:0.0.0 \
    \${@}
EOF
) | docker \
    run \
    --interactive \
    --rm \
    --volume ${BIN}:/usr/local/src \
    --workdir /usr/local/src \
    alpine:3.4 \
    tee ssh &&
    docker \
        run \
        --interactive \
        --rm \
        --volume ${BIN}:/usr/local/src \
        --workdir /usr/local/src \
        --entrypoint chmod \
        alpine:3.4 \
        0500 ssh &&
    docker \
        run \
        --interactive \
        --rm \
        --volume /var/run/docker.sock:/var/run/docker.sock:ro \
        --volume ${BIN}:/usr/local/bin:ro \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.entrypoint):/usr/local/src \
        --workdir /usr/local/src \
        tidyrailroad/git:0.2.0 \
        fetch upstream ${BRANCH} &&
    docker volume rm ${BIN} &&
    docker \
        run \
        --interactive \
        --rm \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.entrypoint):/usr/local/src \
        --workdir /usr/local/src \
        tidyrailroad/git:0.2.0 \
        checkout upstream/${BRANCH}
