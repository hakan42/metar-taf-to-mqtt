#!/bin/sh -x

STATIONS=""

HERE=$(dirname $(realpath $0))

. ${HERE}/stations.sh

TARGET=${HERE}/target

ARCHIVE=${HERE}/archive/$(date -u +%Y%m%d)/$(date -u +%Y%m%d-%H%M)

mkdir -p ${ARCHIVE}

rsync -avr ${TARGET}/aviationweather/ ${ARCHIVE}/
rsync -avr ${TARGET}/metar2xml/       ${ARCHIVE}/

find ${ARCHIVE} -type f -a -mtime +7  | xargs --no-run-if-empty rm
find ${ARCHIVE} -type d -a -empty     | xargs --no-run-if-empty rmdir
