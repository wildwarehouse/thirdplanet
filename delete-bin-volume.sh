#!/bin/sh

docker volume rm $(docker volume ls --quiet --filter label=com.emorymerryman.luckystar.structure.bin)