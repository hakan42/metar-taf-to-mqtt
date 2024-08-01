#!/bin/sh

STATIONS=""

STATIONS="${STATIONS} EDDM" # Munich
STATIONS="${STATIONS} EDDN" # Nuremberg
STATIONS="${STATIONS} EDJA" # Memmingen
STATIONS="${STATIONS} EDMA" # Augsburg
STATIONS="${STATIONS} EDMO" # Oberpfaffenhofen

STATIONS="${STATIONS} ETEB" # Ansbach
STATIONS="${STATIONS} ETHA" # Altenstadt
STATIONS="${STATIONS} ETHL" # Laupheim
STATIONS="${STATIONS} ETIH" # Hohenfels
STATIONS="${STATIONS} ETSI" # Ingolstadt Manching
STATIONS="${STATIONS} ETSL" # Lechfeld
STATIONS="${STATIONS} ETSN" # Neuburg

STATIONS="${STATIONS} LOWI" # Insbruck

STATIONS="${STATIONS} "
STATIONS="${STATIONS} "
STATIONS="${STATIONS} "
STATIONS="${STATIONS} "
STATIONS="${STATIONS} "
STATIONS="${STATIONS} "
STATIONS="${STATIONS} "
STATIONS="${STATIONS} "
STATIONS="${STATIONS} "
STATIONS="${STATIONS} "
STATIONS="${STATIONS} "
STATIONS="${STATIONS} "
STATIONS="${STATIONS} "
STATIONS="${STATIONS} "
STATIONS="${STATIONS} "
STATIONS="${STATIONS} "
STATIONS="${STATIONS} "
STATIONS="${STATIONS} "
STATIONS="${STATIONS} "
STATIONS="${STATIONS} "
STATIONS="${STATIONS} "
STATIONS="${STATIONS} "
STATIONS="${STATIONS} "
STATIONS="${STATIONS} "
STATIONS="${STATIONS} "

HERE=$(dirname $(realpath $0))

TARGET=${HERE}/target/aviationweather

rm -rf ${TARGET}
mkdir -p ${TARGET}

for s in ${STATIONS}
do
    curl \
        --silent \
        --output ${TARGET}/${s}-FULL.xml \
        -H 'accept: */*' \
        "https://aviationweather.gov/api/data/dataserver?requestType=retrieve&dataSource=metars&hoursBeforeNow=1&format=xml&mostRecent=true&stationString="${s} \

    xmllint \
        --xpath '//flight_category/text()' ${TARGET}/${s}-FULL.xml \
        > ${TARGET}/${s}-category

    echo ${s}
    cat ${TARGET}/${s}-category

    #
    # Now publish it via MQTT
    #

    mosquitto_pub \
        --retain \
        --topic metarmap/${s}/flight_category \
        --file ${TARGET}/${s}-category

done

ls -l ${TARGET}
