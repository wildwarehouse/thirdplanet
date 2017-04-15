#!/bin/sh

while [ ${#} -gt 0 ]
do
    case ${1} in
        --github-access-token)
            GITHUB_ACCESS_TOKEN=${2} &&
                shift &&
                shift
        ;;
        --github-user-id)
            GITHUB_USER_ID=${2} &&
            shift &&
            shift
        ;;
        *)
            echo Unknown Option: ${1} &&
                exit 64
        ;;
    esac
done &&
    ([ ! -z "${GITHUB_ACCESS_TOKEN}" ] || (echo GITHUB_ACCESS_TOKEN is not defined. && exit 65)) &&
    ([ ! -z "${GITHUB_USER_ID}" ] || (echo GITHUB_USER_ID is not defined. && exit 66)) &&
    ([ -z "$(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.dot-ssh)" ] || (echo "There is already a dot-ssh volume." && exit 67)) &&
    docker volume create --label com.emorymerryman.tstamp=$(date +%s) --label com.emorymerryman.thirdplanet.structure.dot-ssh &&
    docker \
        run \
        --interactive \
        --rm \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.dot-ssh):/root/.ssh \
        --workdir /root/.ssh \
        --entrypoint chmod \
        alpine:3.4 \
        0700 . &&
    docker \
        run \
        --interactive \
        --rm \
        --entrypoint ssh-keygen \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.dot-ssh):/root/.ssh \
        --workdir /root/.ssh \
        tidyrailroad/openssh-client:0.0.0 \
        -f /root/.ssh/upstream_id_rsa -P "" -C "upstream" &&
    KEY=$(docker \
        run \
        --interactive \
        --rm \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.dot-ssh):/root/.ssh:ro \
        --workdir /root/.ssh \
        alpine:3.4 \
        cat upstream_id_rsa.pub) &&
    (cat <<EOF
{
    "title": "upstream",
    "key": "${KEY}"
}
EOF
    ) | docker \
        run \
        --interactive \
        --rm \
        --volume $(docker volume ls --quiet --filter label=com.emorymerryman.thirdplanet.structure.dot-ssh):/root/.ssh \
        tidyrailroad/curl:0.0.0 \
        --header "Content-Type: application/x-www-form-urlencoded" --user "${GITHUB_USER_ID}:${GITHUB_ACCESS_TOKEN}" --data @- "https://api.github.com/user/keys"
        
        