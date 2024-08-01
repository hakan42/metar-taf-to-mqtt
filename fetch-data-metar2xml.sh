#!/bin/sh -x

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

TARGET=${HERE}/target/metar2xml

rm -rf ${TARGET}
mkdir -p ${TARGET}

for s in ${STATIONS}
do
    curl \
        --silent \
        --output ${TARGET}/${s}-FULL.xml \
	"https://metaf2xml.sourceforge.io/cgi-bin/metaf.pl?lang=en&format=xml&mode=latest&hours=24&unit_temp=C&type_metaf=icao&msg_metaf="${s}"&type_synop=synop&msg_synop=&type_buoy=buoy&msg_buoy=&type_amdar=amdar&msg_amdar="

    xmllint \
	--xpath '(//info)[1]' ${TARGET}/${s}-FULL.xml \
	> ${TARGET}/${s}-info.xml

    xmllint --xpath '//info/text()' ${TARGET}/${s}-info.xml \
	> ${TARGET}/${s}-name.txt
    
    xmllint \
	--xpath '(//metar)[1]' ${TARGET}/${s}-FULL.xml \
	> ${TARGET}/${s}-metar.xml

    xmllint \
	--xpath '(//taf)[1]' ${TARGET}/${s}-FULL.xml \
	> ${TARGET}/${s}-taf.xml

    #
    # Now publish it via MQTT
    #
    # TODO would be nice to a check and publish-if-not-changed
    #

    mosquitto_pub \
     	--retain \
	--topic metarmap/${s}/name \
	--file ${TARGET}/${s}-name.txt

done

# ls -l ${TARGET}

ARCHIVE=${HERE}/archive/$(date -u +%Y%m%d-%H%M)

mkdir -p ${ARCHIVE}
rsync -avr ${TARGET}/ ${ARCHIVE}/

find ${ARCHIVE} -mtime +7 | xargs --no-run-if-empty rm
find ${ARCHIVE} -empty    | xargs --no-run-if-empty rmdir
