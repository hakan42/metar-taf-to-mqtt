#!/bin/sh

STATIONS=""

HERE=$(dirname $(realpath $0))

. ${HERE}/stations.sh

TARGET=${HERE}/target/aviationweather

rm -rf ${TARGET}
mkdir -p ${TARGET}

for s in ${STATIONS}
do
    mkdir -p ${TARGET}/${s}
    RAW=${TARGET}/${s}/${s}-aw-FULL-metar.xml

    curl \
        --silent \
        --output ${RAW} \
        -H 'accept: */*' \
        "https://aviationweather.gov/api/data/dataserver?requestType=retrieve&dataSource=metars&hoursBeforeNow=1&format=xml&mostRecent=true&stationString="${s}

    xmllint \
        --xpath '//flight_category/text()' ${RAW} \
        > ${TARGET}/${s}/${s}-category

    RAW=${TARGET}/${s}/${s}-aw-FULL-taf.xml

    curl \
        --silent \
        --output ${RAW} \
        -H 'accept: */*' \
        "https://aviationweather.gov/api/data/dataserver?requestType=retrieve&dataSource=tafs&hoursBeforeNow=1&format=xml&mostRecent=true&stationString="${s}

    #
    # Now publish it via MQTT
    #
    mosquitto_pub \
        --retain \
        --topic metarmap/${s}/flight_category \
        --file ${TARGET}/${s}/${s}-category

done
