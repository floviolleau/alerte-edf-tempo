#!/bin/bash

# prices at 2024-12-01
# you can combine it with https://github.com/RSS-Bridge/rss-bridge/blob/master/bridges/EdfPricesBridge.php
# or get it on https://particulier.edf.fr/fr/accueil/gestion-contrat/options/tempo/details.html
declare -A PRICES=( ["HPJB"]="0.1609" ["HCJB"]="0.1296" ["HPJW"]="0.1894" ["HCJW"]="0.1486" ["HPJR"]="0.7562" ["HCJR"]="0.1568" )

CURRENT_DATE=$(date +"%d/%m/%Y")
CURRENT_TIME=$(date +"%H:%I:%S")
CURRENT_YEAR=$(date +"%Y")

COLOR_GREY="\U0002B1B"
COLOR_RED="\U0001F7E5"
COLOR_WHITE="\U0002B1C"
COLOR_BLUE="\U0001F7E6"

LAST=$(cat /home/user/last_option_tarifaire.txt)
CALL=$(/usr/local/bin/teleinfo -m r -v 2>&1)
NEW=$(echo "$CALL" | grep ^PTEC | cut -d' ' -f 2)

LAST_INDEXES=$(cat /home/user/last_indexes_option_tarifaire.txt)
LAST_INDEXES_HPJB=$(expr $(echo "$LAST_INDEXES" | grep HPJB | cut -d' ' -f 2) + 0)
LAST_INDEXES_HCJB=$(expr $(echo "$LAST_INDEXES" | grep HCJB | cut -d' ' -f 2) + 0)
LAST_INDEXES_HPJW=$(expr $(echo "$LAST_INDEXES" | grep HPJW | cut -d' ' -f 2) + 0)
LAST_INDEXES_HCJW=$(expr $(echo "$LAST_INDEXES" | grep HCJW | cut -d' ' -f 2) + 0)
LAST_INDEXES_HPJR=$(expr $(echo "$LAST_INDEXES" | grep HPJR | cut -d' ' -f 2) + 0)
LAST_INDEXES_HCJR=$(expr $(echo "$LAST_INDEXES" | grep HCJR | cut -d' ' -f 2) + 0)

NEW_INDEXES_HPJB=$(expr $(echo "$CALL" | grep BBRHPJB | cut -d' ' -f 2) + 0)
NEW_INDEXES_HCJB=$(expr $(echo "$CALL" | grep BBRHCJB | cut -d' ' -f 2) + 0)
NEW_INDEXES_HPJW=$(expr $(echo "$CALL" | grep BBRHPJW | cut -d' ' -f 2) + 0)
NEW_INDEXES_HCJW=$(expr $(echo "$CALL" | grep BBRHCJW | cut -d' ' -f 2) + 0)
NEW_INDEXES_HPJR=$(expr $(echo "$CALL" | grep BBRHPJR | cut -d' ' -f 2) + 0)
NEW_INDEXES_HCJR=$(expr $(echo "$CALL" | grep BBRHCJR | cut -d' ' -f 2) + 0)

color () {
    if [[ "$1" == 'HPJB' || "$1" == 'HCJB' ]]; then
         echo $COLOR_BLUE
    elif [[ "$1" == 'HPJW' || "$1" == 'HCJW' ]]; then
        echo $COLOR_WHITE
    elif [[ "$1" == 'HPJR' || "$1" == 'HCJR' ]]; then
        echo $COLOR_RED
    else
	echo $COLOR_GREY
    fi
}

PICTO_COUL=$(color $LAST)
PICTO_COUL_NEW=$(color $NEW)

if [[ $NEW != '' ]]; then
  if [[ $LAST != $NEW ]]; then
    echo $NEW > /home/user/last_option_tarifaire.txt
    echo "HPJB: $NEW_INDEXES_HPJB" > /home/user/last_indexes_option_tarifaire.txt
    echo "HCJB: $NEW_INDEXES_HCJB" >> /home/user/last_indexes_option_tarifaire.txt
    echo "HPJW: $NEW_INDEXES_HPJW" >> /home/user/last_indexes_option_tarifaire.txt
    echo "HCJW: $NEW_INDEXES_HCJW" >> /home/user/last_indexes_option_tarifaire.txt
    echo "HPJR: $NEW_INDEXES_HPJR" >> /home/user/last_indexes_option_tarifaire.txt
    echo "HCJR: $NEW_INDEXES_HCJR" >> /home/user/last_indexes_option_tarifaire.txt
	
    declare -n LAST_INDEX="LAST_INDEXES_$LAST"
    declare -n NEW_INDEX="NEW_INDEXES_$LAST"
    DELTA=$(echo "scale=3; ($NEW_INDEX - $LAST_INDEX) / 1000" | bc)
    # add first 0
    [[ $DELTA =~ ^[1-9].*$ ]] || DELTA="0$DELTA"

    PRICE=$(echo "${PRICES[$LAST]}")
    PRICE_CALCULATED=$(echo "scale=3; ${PRICES[$LAST]}*$DELTA" | bc)
    [[ $PRICE_CALCULATED =~ ^[1-9].*$ ]] || PRICE_CALCULATED="0$PRICE_CALCULATED"    
    printf "%b" "$CURRENT_DATE;$CURRENT_TIME;$PICTO_COUL;$LAST;$PRICE;$DELTA;$PRICE_CALCULATED" >> "/home/user/data/teleinfo/$CURRENT_YEAR.csv"
    echo '' >> "/home/user/data/teleinfo/$CURRENT_YEAR.csv"
    printf "%b" "Changement option tarifaire : " "$PICTO_COUL_NEW" "$NEW, Consommation sur la période précédente : " "$PICTO_COUL" "$LAST: $DELTA kWh - " "$PRICE_CALCULATED €"
  fi
fi
