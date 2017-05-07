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
    blankout "$(docker volume ls --quiet --filter label=com.emorymerryman.luckystar.structure.sudo)" "There is no sudo volume." 67 &&
    TEMP=$(docker volume create --label com.emorymerryman.tstamp=$(date +%s) --label com.emorymerryman.temporary) &&
    (cat <<EOF
#!/bin/sh

ls -1 /input | while read SCRIPT
do
    echo '#!/bin' > /output/\${SCRIPT%.*} &&
        echo >> /output/\${SCRIPT%.*} &&
        echo "sudo /usr/local/sbin/\${SCRIPT} \"\${@}\"" >> /output/\${SCRIPT%.*} &&
        chmod 0555 /output/${SCRIPT%.*}
done
EOF
    ) | docker \
        run \
        --interactive \
        --rm \
        --volume ${TEMP}:/usr/local/src \
        --workdir /usr/local/src \
        --user root \
        bigsummer/tee:0.0.0 \
        generate.sh &&
    docker \
        run \
        --interactive \
        --tty \
        --rm \
        --volume ${TEMP}:/usr/local/src \
        --workdir /usr/local/src \
        --user root \
        bigsummer/chmod:0.0.0 \
        0555 generate.sh &&
    docker \
        run \
        --interactive \
        --tty \
        --rm \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.luckystar.structure.sbin):/input:ro \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.luckystar.structure.bin):/output \
        --volume ${TEMP}:/script \
        --workdir /script \
        --user root \
        wildwarehouse/fedora:0.0.0 \
        /script/generate.sh &&
    docker volume rm ${TEMP}