# Notice de Gallicanet

- Gallicanet calcule et affiche des graphes de réseaux à partir de la recherche par proximité dans le corpus de presse océrisé en français de Gallica.
- Développé par [Benjamin Azoulay](mailto:benjamin.azoulay@ens-paris-saclay.fr) et <a href="https://regicid.github.io/" target="_blank">Benoît de Courson</a>, il est intégralement rédigé en langage <a href="https://www.r-project.org/" target="_blank">R</a> et présente une interface graphique interactive <a href="https://shiny.rstudio.com/" target="_blank">Shiny</a>.
- Les données produites sont téléchargeables par l’utilisateur. Le <a href="https://github.com/regicid/docker_gallicanet" target="_blank">code source</a> de Gallicanet est libre d'accès et de droits.

### Fonctionnement de l'application
- L'utilisateur importe dans Gallicanet une liste de syntagmes dont il veut cartographier les relations (format .csv, encodage UTF-8, séparés par une virgule).
- Gallicanet filtre les termes de la liste aparaissant trop peu dans le corpus durant la période temporelle programmée pour produire un résultat significatif. Ce seuil, fixé par défaut à 100 occurrences, peut être modifié par l'utilisateur. 
- Le logiciel établit une liste de toutes les combinaisons possibles deux-à-deux entre les termes recherchés. Ces liens sont polaires. Ainsi le lien Louis Aragon -> Paul Eluard se distingue de la relation Paul Eluard -> Louis Aragon. Le nombre de combinaisons possibles est le carré du nombre de termes contenus dans la liste filtrée.
- Gallicanet utilise ensuite la recherche par proximité de Gallica pour dénombrer les coocurrences des combinaisons déterminées. La distance est fixée par défaut à 50 caractères, mais peut être modifiée par l'utilisateur.
- Ce nombre est ensuite pondéré par le nombre d'occurrences du premier des deux termes dans le corpus. Il en résulte un indicateur polarisé de la force des liens entre deux termes tel que, par exemple :

<script type="text/javascript"
        src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.0/MathJax.js?config=TeX-AMS_CHTML"></script>

$$ polar_\textrm{Louis Aragon - Paul Eluard} = \frac{\textrm{nombre de fascicules présentant au moins une coocurrence Louis Aragon - Paul Eluard}}{\textrm{nombre de fascicules mentionnant au moins une fois Louis Aragon durant la période}} $$

$$ polar_\textrm{Paul Eluard - Louis Aragon} = \frac{\textrm{nombre de fascicules présentant au moins une coocurrence Paul Eluard - Louis Aragon}}{\textrm{nombre de fascicules mentionnant au moins une fois Paul Eluard durant la période}} $$

- Ces deux ratios sont ensuite fusionnés sous la forme d'une moyenne apolaire telle que, par exemple : 

$$ ratio_\textrm{Louis Aragon - Paul Eluard} = \frac{polar_\textrm{Louis Aragon - Paul Eluard}}{polar_\textrm{Paul Eluard - Louis Aragon}} $$

- Dans l'interface graphique, l'utilisateur définit la force minimale des liens affichés dans le graphique de réseau. Cette valeur est comprise entre 0 (toutes les relations sont tenues pour des liens quelque soit leur intensité) et 1 (aucune relation n'est assez forte pour être tenue pour un lien).
- Plus cette valeur est élevée et plus le graphe se fragmente sous forme de clusters. Les individus isolés ne sont pas figurés dans le graphe de réseau.
- L'utilisateur peut aussi réhausser le seuil minimal d'occurrences nécessaire pour qu'un individu de la liste initiale soit figuré sur le graphe.
- L'épaisseur des liens est proportionnelle à l'intensité des relations entre deux individus.
- Le diamètre des cercles est proportionnel au nombre de liens entretenus par un individu avec les autres.
- L'individu situé au coeur du réseau ainsi que ses liens sont de couleur rouge. L'utilisateur peut choisir l'individu situé au coeur du réseau.
- L'utilisateur peut se déplacer sur le graphe. La fonction Autoscale permet de dézoomer au maximum pour visualiser l'intégralité du réseau. La fonction Reset axis recentre la fenêtre sur le coeur de réseau.
- L'utilisateur peut faire disparaitre les étiquettes afin de désengorger le graphe ou d'étudier la forme du réseau. Un clic sur la légende permet d'occulter le figuré correspondant. 

