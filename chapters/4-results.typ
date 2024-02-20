#import "@preview/tablex:0.0.5": tablex //, rowspanx, colspanx

#let HPE-green = rgb("#01A982")

= Résultats

Dans cette partie, nous développerons les résultats obtenus lors de nos expérimentations suivant la méthodologie précédemment décrite, en la confrontant aux problématiques rencontrées ne permettant pas d'avoir autant de résultats qu'espéré.

== Contraintes technologiques

J'ai rencontré de nombreuses limitations technologiques durant la réalisation de ce projet de fin d'études, et souhaite partager dans ce rapport les étapes importantes et bloquantes de ce processus d'optimisation, ne permettant pas d'aboutir à tous les résultats au terme de ce projet; en effet, un échec peut également être considéré comme un résultat.

=== Technologies initiales

Nous verrons ici quel était l'état des projets correspondants aux modèles choisis, tels que j'ai pu les récupérer.

==== U-Net
U-Net, le modèle de référence sur lequel nous souhaitions nous baser, utilise une base de code que nous devions modifier afin de rendre l'entraînement compatible avec notre jeu de données : ADE20K.
Les technologies alors utilisées ne sont pas dépréciées mais méritaient une mise à jour : @CUDA est en version 11.3 alors que la 12.1 est désormais disponible, @PyTorch utilise la version 1.10 alors que la 2.01 est disponible, et ceci sans parler de leurs propres dépendences.

Mettre à jour les piles logicielles est, pour moi, une étape primordiale car en calcul hautes performances, l'amélioration continue est recherchée. @CUDA, dont l'objectif principal est d'accélérer des calculs sur @GPU, en est un exemple. Dans un domaine évoluant aussi vite que le @deep-learning, un retard de mises à jour de plus d'un an comme ici représente un écart potentiel considérable.

==== SegFormer et Segmenter
Ces deux modèles, tous deux écrits par des doctorants, ont été programmés en utilisant la librairie #link("https://github.com/open-mmlab/mmsegmentation")[MMSegmentation], elle-même basée sur #link("https://github.com/open-mmlab/mmcv")[MMCV]. Ces librairies sont des abstractions basées sur @PyTorch et ne permettent pas, par exemple, de personnaliser la boucle d'entraînement, réduisant alors le contrôle que nous avons sur les algorithmes, et rendant ainsi difficile l'optimisation des différentes opérations exécutées pendant l'entraînement des modèles. Par ailleurs, je constate que les entraînements respectifs sont très peu optimisés en utilisant des outils de monitoring (système de mesure).

En effet, comme visible sur la @fig-segmenter-first-overview, nous pouvons constater que les @GPU[s] sont sous-utilisés : comme mentionné précédemment dans la méthodologie, le taux moyen d'utilisation est de 80%, et nous remarquons que des périodes où un seul GPU est utilisé de manière prolongé sont présentes (phase de validation). D'autre part, nos soupçons sont confirmés en regardant la puissance moyenne consommée, ici d'environ 150W en moyenne par GPU (plus de 400W peuvent être attendus sur un GPU A100 SXM4 comme dans ce cas).

#figure(
  image("../assets/segmenter-first-overview.png"),
  caption: [
    Premier aperçu de l'entraînement via un système de monitoring
  ]
) <fig-segmenter-first-overview>

==== DeepLab v3+
Une #link("https://github.com/google-research/deeplab2")[implémentation officielle] est disponible, utilisant le framework @TensorFlow. La base de code est très vaste et complexe à prendre en main, ce qui rend compliqué son optimisation pour fonctionner sur notre supercalculateur avec nos technologies.

=== Technologies choisies

Suite aux points de départs desquels nous sommes partis, les choix principaux suivants ont été réalisés.

==== U-Net
Mise à jour de la pile logicielle et prise en charge du nouveau jeu de données.

==== SegFormer et Segmenter
Mise à jour vers les nouvelles versions d'MMCV et MMSegmentation, puis tentative d'optimisation en l'état afin d'éviter de devoir réimplémenter les modèles.

==== DeepLab v3+
Une tentative de réimplémentation a été réalisée avec @TensorFlow mais a échouée du fait de la mauvaise prise en charge de ce framework par @MLDE. Il a alors été jugé plus rentable d'effectuer une nouvelle réimplémentation avec @PyTorch.

=== MLDE

Réaliser ce projet de fin d'études en utilisant @MLDE aura eu au final un impact très négatif sur l'avancement du projet.
Cette plateforme présentant de très gros avantages comme le suivi des expériences, de leurs résultats ou encore la parallélisation "automatique", je suis aujourd'hui en mesure d'affirmer qu'elle n'est pas adaptée
#footnote[
  À moins d'utiliser la #link("https://docs.determined.ai/latest/model-dev-guide/apis-howto/api-core-ug.html")[Core API], pour les connaisseurs, qui était ici un trop gros investissement étant donné nos points de départs
]
pour des travaux nécessitant des ressources au niveau de l'état de l'art comme dans cette étude.

En effet, MLDE est basée sur un système de conteneurisation (donc utilisant des @conteneur[s]) pré-conçus, c'est-à-dire qu'en personnaliser un pour une tâche donnée est un long processus car celui-ci n'a pas été pensé pour. Après de nombreux échanges avec les équipes de @DeterminedAI, il a été déterminé qu'il ne serait pas possible de mettre à jour les piles logicielles comme je le voulais, même si cela ne m'a pas empêché de continuer à essayer de contourner ces limitations par la suite.

== Entraînements

Dans cette partie, nous exposons les résultats obtenus lors des entraînements réussis de U-Net et de SegFormer.

#figure(
  kind: table,
  tablex(
    columns: 4,
    inset: 8pt,
    align: (left, horizon + center, horizon + center, horizon + center),
    auto-vlines: false,
    [*Model*], [*Param \#*], [*Training time*], [*Energy used*],
    [*U-Net*], [6.7M], [9 min], [302 Wh],
    [*SegFormer*], [3.7M], [38 min], [1700 Wh],
  ),
  caption: [
    Résultats de l'entraînement des modèles U-Net et SegFormer sur un noeud (8 GPUs) du supercalculateur Champollion, pour une précision cible de 16 mIoU.
  ]
) <tb-results>

Comme vu dans la méthodologie (@méthodologie), ces modèles ont été entraînés sans pré-entraînement sur d'autres jeux de données au préalable, mais sont partis de zéro. Pour ces raisons, nous ne pouvons pas les comparer à l'existant, les papiers dont ils sont issus utilisant le pré-entraînement car celui-ci est quasiment obligatoire si l'on souhaite obtenir des résultats compétitifs avec le reste de l'état de l'art.

Nous avons essayé de choisir des modèles dont les nombres de paramètres sont les plus proches entre eux afin de rendre la comparaison plus fiable. Ici le modèle U-Net dispose de 6.7 millions de paramètres, contre 3.7 millions pour SegFormer.

La précision (_accuracy_) cible est fixée à 16 @mIoU, suite à des limitations rencontrées pendant l'entraînement, sans quoi nous aurions pu monter jusqu'à environ 32 mIoU, point qu'il est difficile de dépasser sans pré-entraînement d'après mes tests.
Lorsque le jeu de données n'est pas assez grand, comme ici si l'on poursuit l'entraînement, un phénomène nommé _overfitting_ se produit alors : le modèle commence à mémoriser le jeu de données d'entraînement, et on voit alors apparaître une divergence entre les fonction de coût (_loss_) d'entraînement et de validation, comme visible dans la @fig-u-net-overfitting. En effet, à-partir d'environ 1000 batch (paquets de données) entraînés, la fonction de coût de validation (en orange) s'éloigne de la bleue. Sur ce schéma, les _loss_ finales correspondent respectivement à 49 mIoU (jeu d'entraînement) et 32 mIoU (jeu de validation).

#figure(
  image("../assets/u-net-overfitting.png"),
  caption: [
    Illustration du phénomène d'overfitting lorsque l'entraînement de U-Net sans pré-entraînement sur ADE20K est poursuivit (_loss_ d'entraînement en bleu, _loss_ de validation en orange)
  ]
) <fig-u-net-overfitting>

Comme visible dans le @tb-results, U-Net a demandé moins d'énergie ($~6 times$ moins) que pour l'entraînement que SegFormer, même si ce dernier possédait moins de paramètres (3.7 millions contre 6.7 millions pour U-Net) !
La différence est également visible sur les temps d'entraînement, où U-Net a nécessité 9 minutes contre 38 pour SegFormer.

Les détails de consommation d'énergie sont disponibles dans les @fig-u-net-power-consumption et @fig-segformer-power-consumption : en moyenne 2.25 kW pour U-Net contre 2.75 kW pour SegFormer.

#figure(
  image("../assets/u-net-power-consumption.png"),
  caption: [
    Consommation d'énergie durant l'entraînement de U-Net
  ]
) <fig-u-net-power-consumption>

#figure(
  image("../assets/segformer-power-consumption.png"),
  caption: [
    Consommation d'énergie durant l'entraînement de SegFormer
  ]
) <fig-segformer-power-consumption>

Les différences dans les résultats pourraient s'expliquer de plusieurs manières, mais en voici plusieurs plausibles :

==== Kernels CUDA
Un _kernel_ @CUDA (un noyau de calcul CUDA) est une routine compilée pour des accélérateurs (par exemple des @GPU[s]) distincte du programme principal mais utilisée par celui-ci. Il consiste en une implémentation optimisée d'une ou plusieurs opérations. Idéalement, un calcul sur @GPU est constitué d'une suite d'exécution de _kernels_.

Le @Transformer étant une technologie récente, peu de _kernel_ CUDA existent pour définir de telles opérations. De plus, des papiers comme SegFormer viennent redéfinir l'essence même de certains composants du Transformer pour la vision, c'est pourquoi leur implémentation ne peut pas être aussi efficace qu'un composant largement utilisé comme une couche de convolution qui, elle, dispose de multiples kernels depuis des années déjà.

==== Mémorisation de l'information et généralisation
Certaines équipes @dai_coatnet_2021
#footnote[
  Voir l'abstract du papier cité. Cet article scientifique est d'ailleurs un exemple d'architecture hybride convolutions/self-attention en classification
]
affirment que les @Transformer[s] possèdent une meilleur capacité à mémoriser mais qu'ils font preuve de moins bonne capacités de généralisation que les @couche-de-convolution[couches de convolution], dû à un bias induit par leur nature (traitement de pixels dans leur contexte/entourage).

Les résultats que nous exposons dans cette partie montrent donc qu'un modèle basé sur des @couche-de-convolution[couches de convolution] semble être moins coûteux à entraîner qu'un modèle basé sur des @Transformer[s], que ce soit en termes de temps, d'énergie (électricité) ou d'argent (prix de l'électricité + temps d'utilisation des machines).