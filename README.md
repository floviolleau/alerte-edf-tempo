# Alerte EDF tempo

Ensemble de scripts permettant de connaître très simplement la couleur du jour et du lendemain, le nombre restant de jours des différents couleurs et le coût et la consommation par tranche de tarif.

J'ai personnellement branché avec mes salons de discussion (basé sur Matrix / [Element.io](https://element.io) ce qui est très pratique pour être informé des jours blancs et rouges (les plus chers) ainsi que voir sa consommation.

Vous pouvez utiliser ce projet pour l'envoi de notification sur Matrix / [Element.io](https://element.io) : https://github.com/madmax28/navi ou le projet https://github.com/Red5d/pushbullet-bash/ pour utiliser [Pushbullet](https://www.pushbullet.com).

# [tempo-couleur.sh](./tempo-couleur.sh)

Il faut aussi installer un navigateur web en ligne de commande pour simuler un utilisateur.

`sudo apt install lynx`

Voir les crons pour sa mise en place.

En général, EDF annonce la couleur du lendemain vers 11h30.

![](capture.png)

# [tempo-couleur-retry.sh](./tempo-couleur-retry.sh)

Fonctionne de concert avec le précédent script et permet de le relancer si EDF ne sait pas encore à 11h30 la couleur du lendemain ou qu'il a échoué à récupérer les couleurs.

Voir les crons pour sa mise en place.

# [check_option_tarifaire.sh](./check_option_tarifaire.sh)

Lit les valeurs sur le port série à l'aide d'un circuit électronique : https://www.tindie.com/products/hallard/pitinfo/.

La lecture se fait via le binaire : https://github.com/hallard/teleinfo/

Ensuite, il créé un fichier CSV pour stocker toutes les consommations des tranches horaires et il indique la consommation de la tranche horaire précédente lors du changement (passage HC/HP) ainsi que le prix.

Voir les crons pour sa mise en place.

![image](https://github.com/user-attachments/assets/d142c322-b54e-4502-82b0-6c9529c0a90b)

# Crons

Voici un exemple de mise en place du cron :

```crontab
*/5 * * * * /usr/local/bin/teleinfo -m r -e -q && /home/user/check_option_tarifaire.sh
10 11 * * * /home/user/tempo-couleur.sh
00 */2 * * * /home/user/tempo-couleur-retry.sh
```

# Changelog

- 2024-12-09 :

    EDF a durci la récupération des données. Le script a été retravaillé. Il faut aussi installer un navigateur web en ligne de commande pour simuler un utilisateur.

    `sudo apt install lynx`

    Ajout de scripts et mise à jour du README
