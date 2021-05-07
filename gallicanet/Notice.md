# Notice de Gallicapresse

- Gallicapresse est un programme représentant graphiquement la structure des résultats de recherches réalisées dans le corpus de presse de [Gallica](https://gallica.bnf.fr/).
- Il vient en complément de l'outil [Gallicagram](https://shiny.ens-paris-saclay.fr/app/gallicagram) et permet ainsi la maîtrise du corpus sous-jacent.
- Développé par [Benjamin Azoulay](mailto:benjamin.azoulay@ens-paris-saclay.fr) et [Benoît de Courson](https://regicid.github.io/), il est intégralement rédigé en langage [R](https://www.r-project.org/) et présente une interface graphique interactive [Shiny](https://shiny.rstudio.com/).
- Les données produites et les graphiques interactifs sont téléchargeables par l’utilisateur. Le [code source](https://github.com/regicid/docker_gallicapresse) de Gallicapresse est libre d'accès et de droits.


## Extraction

- Gallicapresse procède à l’extraction des données de recherche renvoyées par l’[API de recherche de Gallica](https://api.bnf.fr/fr/api-gallica-de-recherche). Il est paramétré pour des recherches à l’intérieur de bornes chronologiques définies par l’utilisateur. Le corpus est restreint à la presse française océrisée (journaux et revues en mode texte disponible).
- Gallicapresse compile ensuite les données html sous la forme d'un tableau de données CSV exploitable.
- Le programme nettoie certaines données (ville de publication, titre de presse d'origine) pour les lisser et les harmoniser.
- Dans Gallicapresse, les numéros sans jour de publication sont enregistrés au premier jour du mois et les numéros sans mois de publication au premier jour de l'année. L'utilisateur peut supprimer les numéros sans mois de publication enregistré en cochant la case correspondante. Attention, la répartition mensuelle des numéros dans la base de presse de Gallica n'est pas homogène (pic annuel en janvier) et n'est pas indiquée dans Gallicapresse. Reportez-vous à votre recherche dans Gallicagram pour la connaître.

## Options de recherche
- L'utilisateur ne peut entrer qu'une seule requête dans le champ correspondant. 
- La requête conditionnelle "OU" est disponible et s'effectue avec le signe "+" placé entre deux syntagmes.

## Précautions d'usage
- La génération d'un rapport de recherche peut être très longue et est fonction croissante du nombre de résultats. Quand le délai de traitement estimé s'avère prohibitif, l'utilisateur peut ouvrir sa recherche dans Gallica et obtenir le rapport de recherche correspondant au format.csv depuis les serveurs de la BnF. Une fois téléchargé par l'utilisateur, ce rapport de recherche peut être importé dans Gallicapresse. Il faut alors cliquer sur le bouton "Générer le graphique" pour lancer l'analyse sur ce tableau de données.

## Données représentées
- Gallicapresse représente la distribution chronologique des résultats de recherche selon quatre variables d'intérêt : la ville de publication du journal, le titre de presse d'origine, la classification thématique de Dewey proposée par la BnF pour ce titre de presse et la périodicité des titres de presse.
- Gallicapresse affiche aussi dans deux diagrammes distincts les valeurs les plus importantes : principaux titres de presse d'origine ; principales villes de publication des numéros retournés par la recherche ; principales thématiques de classement pour ces numéros ; périodicité.
- Gallicapresse affiche par défaut ces résultats en valeur absolue. Une option permet l'affichage de ces mêmes analyses en valeurs relatives.
- Une cartographie interactive permet la spatialisation des données. Attention : un même journal peut avoir plusieurs villes de publication différentes. Il est alors compté plusieurs fois sur les diagrammes géographiques ainsi que sur la cartographie.

## Corpus
- Se reporter à la notice de [Gallicagram](https://shiny.ens-paris-saclay.fr/app/gallicagram)
