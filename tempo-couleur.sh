#!/bin/bash
DATEJOUR=$(date +%Y-%m-%d)
DATEJOUR_FR=$(date '+%A %d-%m-%Y')
DATEDEMAIN_FR=$(date --date='next day' '+%A %d-%m-%Y')

adresse="particulier.edf.fr/services/rest/referentiel/searchTempoStore?dateRelevant="
adresseJoursRestants="particulier.edf.fr/services/rest/referentiel/getNbTempoDays?TypeAlerte=TEMPO"

adresse="https://${adresse}${DATEJOUR}"

RESULT="`wget -qO- $adresse`"
RESULT_JOURS_RESTANTS="`wget -qO- $adresseJoursRestants`"

coul_J=$(echo $RESULT | jq -r '.couleurJourJ')
coul_J1=$(echo $RESULT | jq -r '.couleurJourJ1')

if [[ "$coul_J" == 'TEMPO_BLEU' || "$coul_J1" == 'TEMPO_BLEU' ]]; then
    picto_coul_j="\U0001F7E6"
    picto_coul_j1="\U0001F7E6"
elif [[ "$coul_J" == 'TEMPO_BLANC' || "$coul_J1" == 'TEMPO_BLANC' ]]; then
    picto_coul_j="\U0002B1C"
    picto_coul_j1="\U0002B1C"
elif [[ "$coul_J" == 'TEMPO_ROUGE' || "$coul_J1" == 'TEMPO_ROUGE' ]]; then
    picto_coul_j="\U0001F7E5"
    picto_coul_j1="\U0001F7E5"
else
    picto_coul_j="\U0002B1B"
    picto_coul_j1="\U0002B1B"
fi

coul_ROUGE=$(echo $RESULT_JOURS_RESTANTS | jq -r '.PARAM_NB_J_ROUGE')
coul_BLANC=$(echo $RESULT_JOURS_RESTANTS | jq -r '.PARAM_NB_J_BLANC')
coul_BLEU=$(echo $RESULT_JOURS_RESTANTS | jq -r '.PARAM_NB_J_BLEU')

printf "%b" "$DATEJOUR_FR : " "$picto_coul_j" " $coul_J, Demain $DATEDEMAIN_FR : " "$picto_coul_j1" " $coul_J1"
printf "%b" "Jours restants : " "\U0001F7E5" " $coul_ROUGE jour(s) rouge(s), " "\U0002B1C" " $coul_BLANC jour(s) blanc(s) et " "\U0001F7E6" " $coul_BLEU jour(s) bleu(s)"
