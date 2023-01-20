#!/bin/bash
DATEJOUR=$(date +%Y-%m-%d)
DATEJOUR_FR=$(date '+%A %d-%m-%Y')
DATEDEMAIN_FR=$(date --date='next day' '+%A %d-%m-%Y')

adresse="particulier.edf.fr/services/rest/referentiel/searchTempoStore?dateRelevant="
adresseJoursRestants="particulier.edf.fr/services/rest/referentiel/getNbTempoDays?TypeAlerte=TEMPO"

adresse="https://${adresse}${DATEJOUR}"

RESULT="`wget -qO- $adresse`"
RESULT_JOURS_RESTANTS="`wget -qO- $adresseJoursRestants`"

COLOR_GREY="\U0002B1B"
COLOR_RED="\U0001F7E5"
COLOR_WHITE="\U0002B1C"
COLOR_BLUE="\U0001F7E6"

coul_J=$(echo $RESULT | jq -r '.couleurJourJ')
coul_J1=$(echo $RESULT | jq -r '.couleurJourJ1')

color () {
    if [[ "$1" == 'TEMPO_BLEU' ]]; then
        echo $COLOR_BLUE
    elif [[ "$1" == 'TEMPO_BLANC' ]]; then
        echo $COLOR_WHITE
    elif [[ "$1" == 'TEMPO_ROUGE' ]]; then
        echo $COLOR_RED
    else
        echo $COLOR_GREY
    fi
}

picto_coul_j=$(color $coul_J)
picto_coul_j1=$(color $coul_J1)

coul_ROUGE=$(echo $RESULT_JOURS_RESTANTS | jq -r '.PARAM_NB_J_ROUGE')
coul_BLANC=$(echo $RESULT_JOURS_RESTANTS | jq -r '.PARAM_NB_J_BLANC')
coul_BLEU=$(echo $RESULT_JOURS_RESTANTS | jq -r '.PARAM_NB_J_BLEU')
printf "%b" "Jours restants : " "$COLOR_RED" " $coul_ROUGE jour(s) rouge(s), " "$COLOR_WHITE" " $coul_BLANC jour(s) blanc(s) et " "$COLOR_BLUE" " $coul_BLEU jour(s) bleu(s)"
printf "%b" "$DATEJOUR_FR : " "$picto_coul_j" " $coul_J, Demain $DATEDEMAIN_FR : " "$picto_coul_j1" " $coul_J1"
