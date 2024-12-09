#!/bin/bash
set -e

COLOR_CODE_GREY="\U0002B1B"
COLOR_CODE_RED="\U0001F7E5"
COLOR_CODE_WHITE="\U0002B1C"
COLOR_CODE_BLUE="\U0001F7E6"

CURRENT_DAY=$(date +%Y-%m-%d)
CURRENT_DAY_FR=$(LC_TIME='fr_FR.UTF-8' date '+%A %-d %B %Y')
TOMORROW_FR=$(LC_TIME='fr_FR.UTF-8' date --date='next day' '+%A %-d %B %Y')
TOMORROW_NO_ZEROS=$(date --date='next day' '+%Y-%-m-%-d')
DATE_YEAR_AGO_NEXT_DAY_NO_ZERO=$(date --date='year ago next day' '+%Y-%-m-%-d')

USER_AGENT='Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:129.0) Gecko/20100101 Firefox/129.0'

COOKIE_PATH='/tmp/edf-cookies.txt'
COOKIE_PATH_2='/tmp/edf-cookies-2.txt'
COOKIE_PATH_3='/tmp/edf-cookies-3.txt'

CURL_OPTIONS="-b $COOKIE_PATH -b $COOKIE_PATH_2 -b $COOKIE_PATH_3"
CURL_OPTIONS=$CURL_OPTIONS" --compressed -H \"Accept: application/json\" -H \"Accept-Language: fr,fr-FR;q=0.8,en-US;q=0.5,en;q=0.3\" -H \"Accept-Encoding: gzip, deflate, br, zstd\""
CURL_OPTIONS=$CURL_OPTIONS" -H \"content-type: application/json\" -H \"User-Agent: ${USER_AGENT}\" -H \"Referer: https://particulier.edf.fr/\""
CURL_OPTIONS=$CURL_OPTIONS" -H \"Origin: https://particulier.edf.fr\" -H \"Application-Origine-Controlee: site_RC\""

URL="https://api-commerce.edf.fr/commerce/activet/v1/calendrier-jours-effacement?option=TEMPO&dateApplicationBorneInf=${DATE_YEAR_AGO_NEXT_DAY_NO_ZERO}&dateApplicationBorneSup=${TOMORROW_NO_ZEROS}"
URL_REMAING_DAYS="https://api-commerce.edf.fr/commerce/activet/v1/saisons/search?option=TEMPO&dateReference=${CURRENT_DAY}"

lynx -dump $URL > /dev/null
sleep $(($RANDOM % 2))

GetColor () {
    if [[ "$1" == 'TEMPO_BLEU' ]]; then
        echo $COLOR_CODE_BLUE
    elif [[ "$1" == 'TEMPO_BLANC' ]]; then
        echo $COLOR_CODE_WHITE
    elif [[ "$1" == 'TEMPO_ROUGE' ]]; then
        echo $COLOR_CODE_RED
    else
        echo $COLOR_CODE_GREY
    fi
}

GetCountersDayColor() {
    echo '>>> GetCountersDayColor'
    
    sleep $(($RANDOM % 2))
    
    local cmd_counter="curl -s ${URL_REMAING_DAYS} ${CURL_OPTIONS}"
    echo ">>> $cmd_counter"
    RESULT_COUNTER=$($cmd_counter | head -1 | sed 's|\(.*\)<!DOCTYPE HTML>|\1|gm')

    echo ">>>$RESULT_COUNTER"
    ERRORS_COUNTER=$(echo "$RESULT_COUNTER" | jq -r '.errors[0].code')
    # eg of random error
    #{"errors":[{"code":"ATM_HTTP_400","description":"La syntaxe de la requête est erronée.","severity":"ERROR","type":"TECHNICAL"}],"content":null}
    echo ">>>$ERRORS_COUNTER"
}

GetCurrentAndNextDayColor() {
    echo '>>> GetCurrentAndNextDayColor'
    rm -fr $COOKIE_PATH $COOKIE_PATH_2 $COOKIE_PATH_3

    curl -s -c $COOKIE_PATH "https://particulier.edf.fr/fr/accueil/gestion-contrat/options/tempo.html" > /dev/null
    
    sleep $(($RANDOM % 2))
    curl -s -b $COOKIE_PATH -c $COOKIE_PATH_2 "https://particulier.edf.fr/libs/granite/csrf/token.json" > /dev/null
    
    local rand=$(($RANDOM % 2))
    local epoch=$(date +%s%3N)
    sleep $rand
    curl -s -b $COOKIE_PATH -b $COOKIE_PATH_2  -c $COOKIE_PATH_3 "https://particulier.edf.fr/services/rest/checkuserstatus/getUserStatus?_=${epoch}" > /dev/null
    
    local cmd="curl -s ${URL} ${CURL_OPTIONS}"
    echo ">>> $cmd"
    RESULT=$($cmd | head -1 | sed 's|\(.*\)<!DOCTYPE HTML>|\1|gm')

    echo ">>>$RESULT"
    ERRORS=$(echo "$RESULT" | jq -r '.errors[0].code')
    # eg of random error
    # {"errors":[{"code":"ATM_HTTP_400","description":"La syntaxe de la requête est erronée.","severity":"ERROR","type":"TECHNICAL"}],"content":null}
    echo ">>>$ERRORS"
}

# Retrieve calendar with all colors in order to get today and tomorrow colors
GetCurrentAndNextDayColor
count=1
while [[ $ERRORS == 'ATM_HTTP_400' && $count -lt 100 ]]
do 
    echo 'Do it again'
    GetCurrentAndNextDayColor
    count=$((COUNT+1))
    sleep $(($RANDOM % 4))
done

if [[ $ERRORS != 'null' ]]; then
    echo 'Échec récupération couleur du jour et lendemain'
    exit 1
fi

color_J=$(echo $RESULT | jq -r '.content.options[0].calendrier | .[-2:][0].statut')
color_J1=$(echo $RESULT | jq -r '.content.options[0].calendrier | [last][0].statut')

picto_color_j=$(GetColor $color_J)
picto_color_j1=$(GetColor $color_J1)
#echo "$color_J"
#echo $picto_color_j
#echo "$color_J1"
#echo $picto_color_j1

# Get counters of all colors
GetCountersDayColor
count=1
while [[ $ERRORS_COUNTER == 'ATM_HTTP_400' && $count -lt 100 ]]
do 
    echo 'Do it again'
    GetCountersDayColor
    count=$((count+1))
    sleep $(($RANDOM % 4))
done

if [[ $ERRORS_COUNTER != 'null' ]]; then
    echo 'Échec récupération compteurs couleur jours restants'
    exit 1
fi

getRemainingDays() {
    # $1 must be TEMPO_BLEU, TEMPO_BLANC or TEMPO_ROUGE
    local color=$1
    local totalDays=$(echo $RESULT_COUNTER | jq -r ".content[] | select(.typeJourEff | contains(\"$color\")).nombreJours | tonumber")
    local days=$(echo $RESULT_COUNTER | jq -r ".content[] | select(.typeJourEff | contains(\"$color\")).nombreJoursTires | tonumber")
    remainingDays=$(expr $totalDays - $days)
    echo $remainingDays
}

color_red=$(getRemainingDays 'TEMPO_ROUGE')
color_white=$(getRemainingDays 'TEMPO_BLANC')
color_blue=$(getRemainingDays 'TEMPO_BLEU')

if [[ $color_J1 == 'NON_DEFINI' ]];then
    touch /tmp/no-color-next-day
else
    rm -f /tmp/no-color-next-day
fi

# final print
printf "%b" "Jours restants : " "$COLOR_CODE_RED" " $color_red jour(s) rouge(s), " "$COLOR_CODE_WHITE" " $color_white jour(s) blanc(s) et " "$COLOR_CODE_BLUE" " $color_blue jour(s) bleu(s)"
printf "%b" "$CURRENT_DAY_FR : " "$picto_color_j" " $color_J, Demain $TOMORROW_FR : " "$picto_color_j1" " $color_J1"
