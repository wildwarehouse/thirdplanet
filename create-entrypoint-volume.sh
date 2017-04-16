#!/bin/sh

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
    ( [ ! -z "${BRANCH}" ] || (echo There is no BRANCH defined && exit 65)) &&
    ([ ! -z "$(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.github.dot-ssh)" ] || (echo "There is no dot-ssh volume." && exit 66)) &&
    ([ -z "$(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.entrypoint)" ] || (echo "There is already a entrypoint volume." && exit 67)) &&
    docker volume create --label com.emorymerryman.tstamp=$(date +%s) --label com.emorymerryman.thirdplanet.structure.entrypoint &&
    docker \
        run \
        --interactive \
        --rm \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.entrypoint):/usr/local/src \
        --workdir /usr/local/src \
        tidyrailroad/git:0.0.0 \
        init &&
    docker \
        run \
        --interactive \
        --rm \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.entrypoint):/usr/local/src \
        --workdir /usr/local/src \
        tidyrailroad/git:0.0.0 \
        remote add upstream upstream/wildwarehouse/thirdplanet.git &&
    docker \
        run \
        --interactive \
        --rm \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.github.dot-ssh):/root/.ssh:ro \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.entrypoint):/usr/local/src \
        --workdir /usr/local/src \
        tidyrailroad/git:0.0.0 \
        fetch upstream ${BRANCH} &&
    docker \
        run \
        --interactive \
        --rm \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.entrypoint):/usr/local/src \
        --workdir /usr/local/src \
        tidyrailroad/git:0.0.0 \
        checkout upstream/${BRANCH} &&
        

        
        

    docker \
        run \
        --interactive \
        --rm \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.github.dot-ssh):/root/.ssh \
        --workdir /root/.ssh \
        --entrypoint chmod \
        alpine:3.4 \
        0700 . &&
    docker \
        run \
        --interactive \
        --rm \
        --entrypoint ssh-keygen \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.github.dot-ssh):/root/.ssh \
        --workdir /root/.ssh \
        tidyrailroad/openssh-client:0.0.0 \
        -f /root/.ssh/upstream_id_rsa -P "" -C "upstream" &&
    (cat <<EOF
{
    "title": "upstream",
    "key": "$(docker \
        run \
        --interactive \
        --rm \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.github.dot-ssh):/root/.ssh:ro \
        --workdir /root/.ssh \
        alpine:3.4 \
        cat upstream_id_rsa.pub)"
}
EOF
    ) | docker \
        run \
        --interactive \
        --rm \
        tidyrailroad/curl:0.0.0 \
        --header "Content-Type: application/x-www-form-urlencoded" --user "${GITHUB_USER_ID}:${GITHUB_ACCESS_TOKEN}" --data @- "https://api.github.com/user/keys" &&
    docker \
        run \
        --interactive \
        --rm \
        --entrypoint ssh-keygen \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.github.dot-ssh):/root/.ssh \
        --workdir /root/.ssh \
        tidyrailroad/openssh-client:0.0.0 \
        -f /root/.ssh/origin_id_rsa -P "" -C "origin" &&
    (cat <<EOF
{
    "title": "origin",
    "key": "$(docker \
        run \
        --interactive \
        --rm \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.github.dot-ssh):/root/.ssh:ro \
        --workdir /root/.ssh \
        alpine:3.4 \
        cat origin_id_rsa.pub)"
}
EOF
    ) | docker \
        run \
        --interactive \
        --rm \
        tidyrailroad/curl:0.0.0 \
        --header "Content-Type: application/x-www-form-urlencoded" --user "${GITHUB_USER_ID}:${GITHUB_ACCESS_TOKEN}" --data @- "https://api.github.com/user/keys" &&
    docker \
        run \
        --interactive \
        --rm \
        --entrypoint ssh-keygen \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.github.dot-ssh):/root/.ssh \
        --workdir /root/.ssh \
        tidyrailroad/openssh-client:0.0.0 \
        -f /root/.ssh/report_id_rsa -P "${REPORT_PASSPHRASE}" -C "report" &&
    (cat <<EOF
{
    "title": "report",
    "key": "$(docker \
        run \
        --interactive \
        --rm \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.github.dot-ssh):/root/.ssh:ro \
        --workdir /root/.ssh \
        alpine:3.4 \
        cat report_id_rsa.pub)"
}
EOF
    ) | docker \
        run \
        --interactive \
        --rm \
        tidyrailroad/curl:0.0.0 \
        --header "Content-Type: application/x-www-form-urlencoded" --user "${GITHUB_USER_ID}:${GITHUB_ACCESS_TOKEN}" --data @- "https://api.github.com/user/keys" &&
    (cat <<EOF
Host upstream
User git
HostName github.com
IdentityFile ~/.ssh/upstream_id_rsa

Host origin
User git
HostName github.com
IdentityFile ~/.ssh/origin_id_rsa

Host report
User git
HostName github.com
IdentityFile ~/.ssh/report_id_rsa

EOF
    ) | docker \
        run \
        --interactive \
        --rm \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.github.dot-ssh):/root/.ssh \
        --workdir /root/.ssh \
        --entrypoint tee \
        alpine:3.4 \
        config &&
    docker \
        run \
        --interactive \
        --rm \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.github.dot-ssh):/root/.ssh \
        --workdir /root/.ssh \
        --entrypoint chmod \
        alpine:3.4 \
        0600 config
        