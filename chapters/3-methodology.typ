#import "@preview/tablex:0.0.5": tablex //, rowspanx, colspanx

#let HPE-green = rgb("#01A982")
#let HPE-orange = rgb("#FF8300")

= Méthodologie <méthodologie>

Dans cette partie, nous présenterons la méthodologie qui a été utilisée pour conduire les expériences durant ce projet de fin d'études.
Cette méthodologie à pour objectif d'apporter des éléments de réponse aux questions suivantes : vaut-il mieux utiliser des convolutions ou des Transformers pour la tâche de segmentation sémantique ? Des modèles basés sur ces technologies se mettent-ils bien à l'échelle sur un supercalculateur ?
Cette méthodologie reste cependant idéaliste sur certains points (par exemple PyTorch, qui peut contenir des différences de performances en son sein), dont nous reparlerons plus tard.

== Choix préalables

=== Jeu de données

Pour cette étude nous choisissons le jeu de données ADE20K @zhou_semantic_2018, introduit en 2018. Il figure systématiquement parmi les plus utilisées dans le domaine de la @segmentation-sémantique, et pour cause : il possède 22 210 images et 150 classes
#footnote[
  Les deux jeux de données contiennent en réalité bien plus de classes, mais nous nous intéressons ici au nombre utilisable en pratique ; les nombres cités sont donc les ensembles habituellement utilisés, ce qui signifie que les classes comportent chacunes suffisamment d'exemples pour être correctement représentées.
] <fn-datasets>,
une diversité des plus intéressantes dans le domaine.

En comparaison, le jeu PASCAL Context (2010) @mottaghi_role_2014, qui étend le PASCAL VOC 2010 pour le rendre compatible avec la segmentation sémantique, contient 59 classes
#footnote(<fn-datasets>)
(ensemble habituellement utilisé) pour 10 103 images.

=== Modèles avec _backbones_

Certains modèles (DeepLab, Segmenter) utilisent des _backbones_, c'est-à-dire que leur architecture est "branchée" à un modèle de classification placé en amont, un _feature extractor_ (extracteur de caractéristiques).
Généralement, des modèles de type ResNet sont utilisés car ceux-ci sont très connus et bien optimisés de par leur grande maturité. Ils doivent leur nom au fait qu'ils sont pré-entraînés sur un ou plusieurs jeu(x) de données de classification au préalable ; et l'on utilise leur couches [ de convolution ] comme des outils permettant d'extraire des caractéristiques à différentes échelles suite à leur "expérience" sur des jeux de classification, afin de la transposer à d'autres tâches.

Il s'avèrent d'ailleurs particulièrement utiles sur des petits jeux de données comme ADE20K (comparativement à d'autres, comme ImageNet @deng_imagenet_2009 (classification) qui comporte \~1.2 million d'images), en partant du principe que beaucoup de notions définissant un objet d'un point de vue généraliste peuvent se retrouver dans d'autres sources de données.

Ces _backbones_ posent donc un problème de biais de par leur natures variées et leur pré-entraînements, c'est pourquoi je choisis de les autoriser mais sans pré-entraînements, pour que tous les modèles partent avec les mêmes chances : nous souhaitons comparer les modèles dans leur capacité à restituer des connaissances.

Il est également envisageable d'effectuer une comparaison avec pré-entraînements, mais cela ne rentre malheureusement pas dans le cadre de ce projet de fin d'études.

== Facteurs de comparaison

Dans cette section, nous souhaitons aborder les configurations communes entre les modèles ainsi que ceux qui permettrons de les différencier dans le cadre de notre étude.

#figure(
  kind: table,
  tablex(
    columns: 2,
    inset: 8pt,
    align: (right, left),
    auto-vlines: false,
    [*Configurations communes*], [*Critères de comparaison*],
    [Précision], text(HPE-green)[*Énergie (Wh)*],
    [Utilisation des GPUs], text(HPE-green)[*Scalabilité*],
    [Framework (PyTorch)], [Nombre de paramètres],
    [Environnement (Champollion)], [],
    [Nombre de paramètres], []
  ),
  caption: [
    Liste des configurations communes et de comparaison \
    pour l'entraînement des différents modèles
  ]
)

=== Configurations communes

==== Précision
Le but est d'entraîner tous les modèles afin d'atteindre une _accuracy_ (précision) commune. Cela permettra d'évaluer leurs temps de convergence. Cependant, un modèle peut théoriquement converger plus lentement en utilisant moins d'énergie
#footnote[
  Cela ne peut pas signifier non plus qu'il mettra beaucoup plus longtemps à converger car un serveur consomme de l'énergie en étant _idle_ (inactif), soit dans la durée ; converger lentement ne peut donc pas représenter un avantage, l'idée est ici seulement d'être souple dans notre approche.
].
Nous souhaitons pour cela maximiser l'utilisation des @GPU[s] afin de garantir (autant que possible) un code optimisé, laissant le coeur du modèle et ses capacités s'exprimer pleinement, en déplaçant le @bottleneck au niveau des GPUs.

==== Bottlenecks
Lors de l'entraînement d'un modèle sur un supercalculateur, plusieurs facteurs, dont certains sont illustrés sur la @fig-bottlenecks, peuvent être limitants.
Le GPU est généralement le composant le plus cher d'un système, donc le but est d'optimiser les calculs pour qu'il soit le point bloquant (_bottleneck_) lors de l'entraînement. Pour cela, le reste de l'infrastructure doit être dimensionné de manière cohérente, par exemple en terme de communication si le multi-noeud est important pour la tâche choisie.

Ces _bottlenecks_ peuvent être analysés par des outils de monitoring par exemple : il s'agit de solutions permettant de surveiller l'activité sur une ou plusieurs machines. J'ai eu l'occasion de développer une solution de bout-en-bout venant se connecter directement à notre _job scheduler_ (ordonnanceur de tâches) dans le cluster, en affichant une interface web liée à la tâche actuelle afin de lire l'activité des @GPU[s], des CPUs, du stockage, des communications réseau et même de la consommation électrique du/des serveur(s) !

#figure(
  image("../assets/bottlenecks.png"),
  caption: [
    Interactions entre les différents composants d'un système lors d'un entraînement de modèle de deep learning sur un seul noeud d'un cluster de calcul
  ]
) <fig-bottlenecks>

#let b(content) = {
  text(HPE-orange)[*#content*]
}

- #b[Le stockage] : coût fixe pour chaque fichier donc les gros fichiers sont à privilégier
- #b[La mémoire] : si la RAM est trop petite, le serveur peut se mettre à _swap_ (_offloading_ (déchargement) sur le disque - très pénalisant)
- #b[Les CPUs] : si trop d'opérations se font sur les processeurs, ceux-ci peuvent devenir limitants. Dans les grandes lignes, durant un entraînement de deep learning, les CPUs doivent s'occuper des opérations de chargement, décodage et augmentation des données, en les _streamant_ (communiquant en flux asynchrone) au @GPU[s]
- #b[Les communications] : la @fig-bottlenecks représente les communications entre les GPUs et les CPUs ainsi qu'entre les GPUs eux-mêmes, mais ne montre pas les communications inter-serveurs dans le cas dans entraînement distribué multi-noeuds. En effet, tous ces points peuvent poser problème, notamment dans le cadre d'entraînement de modèles de @NLP, où les communications sont souvent très impactantes (les couches étant réparties sur plusieurs GPUs, en particulier).

==== Utilisation des GPUs
Afin de déplacer le bottleneck vers les GPUs, nous devons vérifier deux critères qui permettent de s'en assurer de manière plutôt fiable :

1. L'utilisation est à 100% de manière quasi-constante, ce qui montre qu'ils ne sont pas inactifs
2. L'utilisation d'énergie est proche du seuil maximal annoncé par le constructeur : dans le cas des GPUs NVIDIA, dépasser la consommation maximale annoncée est un bon signe qu'un code est optimisé

Le critère d'utilisation des GPUs peut même être étendu : les modèles vont tous devoir être optimisés à la main pour respecter les critères ci-dessus.

==== Framework
Le framework populaire @PyTorch a été choisi pour l'implémentation des 4 modèles choisis, ce qui permet d'avoir un critère supplémentaire en commun pour cette comparaison.

==== Environnement de calcul
Le choix de l'environnement matériel sera discuté un peu plus loin.

==== Nombre de paramètres
Le nombre de paramètres des modèles est à la fois un critère commun car un nombre de paramètres égal peut vouloir dire capacité de mémoire identique, mais dans les faits les types numériques des paramètres peuvent être différents et leur impacts individuels varier.
Essayer d'avoir un nombre de paramètres similaire permet toutefois d'approximer grossièrement le coût calculatoire de l'entraînement.

=== Critères de comparaison

2 facteurs nous permettrons de différencier les modèles dans leurs performances :

==== Énergie
Pour des configurations communes données, l'énergie consommée pour converger, mesurée en Wh (Watt #sym.dot heures), diffèrera et sera notre critère d'évaluation.
L'énergie consommée prend en compte la somme des puissances perçues par les blocs d'alimentation des serveurs durant tout l'entraînement, ce qui signifie que des facteurs externes comme les _switchs_, les climatisations et le réseau ne sont pas pris en compte. En effet, leur impact énergétique reste minime une fois réparti sur tout le datacenter.

==== Scalabilité
Un modèle peut se comporter différemment lorqu'il est entraîné sur un ou plusieurs GPUs, ainsi que sur un ou plusieurs serveurs : ces différences de comportement peuvent se manifester sous la forme d'une convergence qui diffère lorsque l'entraînement est mis à l'échelle, ou des moins bonnes performances de calcul. Nous inspecterons alors les différents comportements afin de constater des potentiels problèmes.

== Choix de l'environnement

Dans cette section, nous discutons les choix d'environnement. Ces choix peuvent varier en fonction des conditions de (re)production de ces travaux, mais leur explicitation permet de comprendre les conditions dans lesquelles nous avons obtenu nos résultats et de les extrapoler à d'autres environnements si nécessaire.

=== Champollion

Dans le lab (datacenter expérimental) de Grenoble, nous possédons un supercalculateur construit en partenariat avec nos partenaires, mis à disposition en interne mais également pour des travaux de recherche via l'institution #link("https://miai.univ-grenoble-alpes.fr")[MIAI].

Ce supercalculateur est composé de 20 serveurs HPE Apollo 6500 Gen10+. Chaque serveur est équipé de 2 processeurs AMD 7763, 8 GPUs NVIDIA A100 SXM4 (l'architecture SXM permet d'avoir, en plus du bus PCIe gen4 (32 GB/sec unidirectionnel), un bus NVLink permettant des taux de transfert de 300 GB/sec inter-GPUs), 1 TB de mémoire RAM, 4 cartes InfiniBand HDR offrant un taux de transfert inter-serveurs total de 800 Gb/sec (soit 100 GB/sec) ainsi qu'une connexion Ethernet 100 Gb.

==== InfiniBand
L'InfiniBand est un standard de communication réseau utilisé dans le calcul hautes performances qui se caractérise par un débit très élevé et un temps de latence très faible. Il est utilisé pour l'interconnexion de données entre serveurs, mais aussi avec des systèmes de stockage.

Le but est de reproduire une portion d'un supercalculateur livré chez un client afin de pouvoir exécuter des démonstrations, des @benchmark[s] ou des expériences en interne.

Le lab de Grenoble est géré par les différentes personnes qui composent l'équipe, et tout le monde peut donc participer, ce qui permet d'avoir une vue concrète et un grand contrôle du matériel sur lequel nos codes tournent, contrairement à une solution (non-HPC) cloud (Azure, AWS...).

=== HPE MLDE

Comme présenté précédemment @MLDE permet de paralléliser des entraînements de deep learning via une solution conteneurisée. Une fois une solution entraînable avec la plateforme, il est facile de la partager à d'autres personnes dans le but de la reproduire, étant donné sa nature conteneurisée.
Suite à son rachat par HPE, c'est une solution que nous souhaitons pousser chez nos clients sur leurs machines, c'est pourquoi il nous semble évident de devoir proposer, au possible, une implémentation compatible @MLDE dans le cadre de ce projet.

== Challenges

=== Compatibilité avec MLDE

Parmi les modèles choisis, U-Net est déjà compatible avec MLDE, tandis que SegFormer, Segmenter et DeepLab ne le sont pas.

SegFormer et Segmenter ont publiés des implémentations basées sur #link("https://github.com/open-mmlab/mmcv")[MMCV], qui est une surcouche de PyTorch facilitant la création de modèles. Le problème de ce framework est qu'il cache notamment le processus d'entraînement, bloquant un grand nombre d'optimisations.
Toutefois, MLDE propose un module MMCV qui pourrait peut-être être réemployé.

Conçernant DeepLab, une implémentation officielle existe également mais est très personnalisée (la base de code est complexe) et difficile à porter, c'est pourquoi le modèle devra peut-être être réécrit.

=== Des environnements différents

Les entraînements s'effectuant sur une base de code Python, le réel challenge se situe certainement au niveau des environnements (logiciels). En effet, Python ne dispose pas de standard robuste dans le domaine du deep learning, et encore moins en ce qui concerne le @HPC. Installer un environnement directement (nativement) sur une machine est compliqué à cause de la manipulation de variables d'environnement, mais obtenir un conteneur avec un environnment aligné avec l'état de l'art est une tâche ardue.

== Pour aller plus loin

Idéalement, une recherche d'hyperparamètres pourrait être faite : elle consiste à chercher les jeux d'hyperparamètres régissant les caractéristiques principales des modèles jusqu'à en trouver la meilleure configuration selon un critère donné. Ici, le critère serait la quantité d'énergie utilisée pour l'entraînement, afin d'atteindre la précision cible en utilisant le minimum d'énergie pour chaque configuration (par exemple en diminuant le nombre de paramètres).