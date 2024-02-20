= Revue de l'état de l'art

== Quelques concepts <sota-concepts>

Cette partie présente des outils du domaine, utiles pour comprendre l'état de l'art avec plus de détails.

#figure(
  image("../assets/convolutional-encoder-decoder.png"),
  caption: [
    Architecture _encoder-decoder_ (encodeur-décodeur) d'un CNN (réseau neuronal de convolutions), c'est-à-dire contenant des couches de convolution successives (#link("https://www.v7labs.com/blog/image-segmentation-guide")[source])
  ]
) <fig-convolutional-encoder-decoder>

Habituellement, la classification d'images s'effectue globalement en faisant se succéder des couches de convolution, que l'on connecte ensuite à une ou plusieurs couches denses (neurones interconnectés).
Le processus permet d'établir une nouvelle représentation de l'image en extrayant ses composantes principales, puis en les matérielisant en classes dans les dernières couches.
Ainsi, une architecture basique qui était utilisé en segmentation sémantique est telle que représentée dans la @fig-convolutional-encoder-decoder : des couches de convolution successives avec une taille de _kernel_ de plus en plus petite afin d'extraire les informations globales de l'image dans un premier temps, puis de plus en plus précises dans un deuxième temps ; le processus est ensuite répété à l'inverse avec des couches de "déconvolution" (le processus inverse d'une convolution, c'est-à-dire qu'une image plus grande est construite à-partir de l'entrée en déplaçant le _kernel_).

Cette approche possède un inconvénient : les premières couches de déconvolution se basent sur la (au mieux, les) dernière(s) couches de convolution, c'est-à-dire que le résultat des premières couches du modèle (les informations plus globales de l'image) se perdent au fur-et-à-mesure.

Conçernant la sortie du modèle, comme vu dans la partie introduction de ce document, chaque pixel se voit assigner une classe.
Si l'image d'entrée est de taille $n times n$ et il y a $y$ classes différentes, alors la sortie du modèle sera un @tenseur $n times n times y$ ; le vecteur correspondant est dit _one-hot encoded_.

=== Encodage one-hot

L'encodage one-hot, aussi appelé encodage 1 parmi $n$, consiste à encoder une variable à $n$ états sur $n$ bits dont un seul prend la valeur 1, le numéro du bit valant 1 étant le numéro de l'état pris par la variable
#footnote[Citation tirée de https://fr.wikipedia.org/wiki/Encodage_one-hot]. Ainsi, en ayant les classes chien, chat et pastèque, soit $vec("chien", "chat", "pastèque")$, la classe pastèque sera représentée par $vec(0, 0, 1)$ en encodage one-hot.
Cette méthode s'avère particulièrement utile dans le domaine du @deep-learning (voire du machine learning en général), car il est admis et facilement constatable que l'usage de valeurs sur les espaces $[0, 1]$ ou $[-1, 1]$ (flottants, $x in DD$) est plus stable numériquement que des valeurs entières ($x in ZZ$) choisies arbitrairement de $0$ à $n$.

=== Comment mesurer les performances ?

La précision, aussi appelée _accuracy_ en anglais, représente les performances du modèle sur une tâche donnée, souvent exprimée en pourcentage.
Une fois une classe assignée à chaque pixel de l'image d'entrée, donc à la sortie du modèle, la question se pose alors du protocole à suivre pour attribuer un score (une précision/_accuracy_) à la répartition des classes proposée. Une méthode simple serait de comparer la classe attribuée à chaque pixel puis de la comparer avec la valeur attendue, puis en retenant $1$ pour une valeur correcte, et $0$ sinon ; enfin, la moyenne de tous les scores des pixels serait faite, donnant le score global de la répartition proposée.
Cette approche est toutefois inadaptée car elle ne tiendrait pas compte du déséquilibre entre les classes. Concrètement, dans un jeu de données, une ou plusieurs classes sont souvent sur-représentées ; par exemple, si la plupart des photos incluent du ciel visible, alors il est probable que le ciel soit surreprésenté, c'est-à-dire que la classe "ciel" correspondante sera beaucoup plus fréquente en nombre de pixels sur l'ensemble du jeu.

La métrique la plus utilisée afin d'exprimer la précision (_accuracy_) en segmentation sémantique est l'@mIoU, en anglais _mean Intersection over Union_. L'_Intersection over Union_ (IoU), pour une classe donnée, correspond à l'espace où les pixels de la classe en question prédits chevauchent ceux attendus divisé par l'union des espaces prédits et attendus, comme illustré dans la @fig-IoU. En d'autres termes, cette métrique exprime la quantité de surface correctement prédite divisé par l'union de la surface correctement prédite, de la surface incorrectement prédite et de la surface attendue non prédite.

#figure(
  image("../assets/IoU.png", height: 20%),
  caption: [
    Formule représentant l'_Intersection over Union_ (#link("https://commons.wikimedia.org/wiki/File:Intersection_over_Union_-_visual_equation.png")[source])
  ]
) <fig-IoU>

D'autres métriques existent également, comme le _dice coefficient_ (_F1 score_), mais sont moins utilisées dans l'état de l'art du domaine de la segmentation sémantique. Sans s'attarder sur les détails, elle est corrélée au @mIoU et diffère en ce qu'elle porte plutôt sur la performance moyenne tandis que le @mIoU exprime plus la performance dans le pire cas.

Cette introduction permettant de présenter les outils standards du domaine, intéressons-nous maintenant aux papiers et modèles étudiés de le cadre de cette revue de l'état de l'art.
En deep learning, l'état de l'art est extrêmement riche et il est impossible d'en faire le tour, c'est pourquoi je présente ici une sélection des papiers que j'ai trouvé les plus pertinents, qui sont à la fois en rapport direct avec le sujet ainsi que d'autres qui permettent de connecter d'autres domaines. Le domaine de la segmentation sémantique est plutôt réduit par rapport à certains autres comme la classification et il est donc important de rester ouvert aux avancées pouvant venir d'ailleurs.

== Modèles basés sur des convolutions

=== U-Net

#figure(
  image("../assets/u-net.png"),
  caption: [
    Architecture du @modèle U-Net (source: @ronneberger_u-net_2015)
  ]
) <fig-u-net>

Le modèle U-Net @ronneberger_u-net_2015 est historiquement une référence car il a introduit les _skip-connections_ (sauts de connexions), comme visible sur la @fig-u-net : ce sont des connexions allant du décodeur vers le décodeur prévenant la perte d'information comme vu précédemment (@sota-concepts).

Dans ce modèle, l'encodeur est découpé en petits blocs, qui sont associés avec leurs équivalent côté décodeur ; l'idée est de combiner les caractéristiques plus haut-niveau (abstraites, globales à l'image) avec des plus basses (plus précises) sans perte d'information.

=== PSPNet

#figure(
  image("../assets/pspnet.png"),
  caption: [
    Vue globale de l'architecture de PSPNet et son _Pyramid Pooling Module_ (source: @zhao_pyramid_2017)
  ]
) <fig-pspnet>

PSPNet @zhao_pyramid_2017 introduit le _Pyramid Pooling Module_ (module de _pooling_ pyramidal) ; le terme _pooling_ (en français : regroupement ou mise en commun) signifie une réduction de la dimension spatiale des données. Comme visible dans la partie `(c)` de la @fig-pspnet, ce module effectue 4 {convolutions, suréchantillonnages} de tailles de _kernel_ différentes en parallèle, puis les concatène dans un CNN afin de produire les prédictions finales en `(d)`.

Ce concept est très intéressant puisqu'il permet d'effectuer une extraction de caractéristiques en parallèle, précédemment effectué de manière séquentielle.

=== DeepLab

Le modèle DeepLab existe sous 4 versions, introduites par 4 papiers dont les auteurs principaux travaillent chez Google.
Nous discutons ici quelques points intéressants apportés par les différentes versions.

==== DeepLab v1 (2014) @chen_semantic_2016
Cette version, à l'origine du modèle DeepLab, présente les _atrous (dilated) convolutions_, soit convolutions dilatées en français. Un _kernel_ d'une convolution dilatée est similaire à celui d'une convolution régulière, sauf qu'un paramètre $r$ est ajouté à sa diagonale, afin de venir "étirer" les pixels sur une plus grande zone, en les espaçant effectivement. Comme illustré sur la @fig-dilated-kernel, un _kernel_ $3 times 3$ dilaté avec $D = 2$ voit chaque pixel qu'il contient séparé de ses voisins de $D = 2$ pixels.

Cela implique qu'un _kernel_ $3 times 3$ verrait approximativement la même chose qu'un _kernel_ $5 times 5$, mais avec seulement 9 paramètres au lieu de 25 en utilisant un taux de dilation de $D = 2$.
Dans les faits, plus d'informations pourront être capturées avec (potentiellement) le même coût calculatoire. Il est alors possible de remplacer un ensemble convolution + @max-pooling par une convolution dilatée !

#figure(
  image("../assets/dilated-convolution.png"),
  caption: [
    Un _kernel_ $3 times 3$ de : \
    `(a)` convolution régulière ou de dilatation $D = 1$ \
    `(b)` dilatation $D = 2$ #sym.space.quad `(c)` dilatation $D = 3$ \
    (source: @heffels_aerial_2020)
  ]
) <fig-dilated-kernel>

La version 1 utilise également un CRF (_Conditional Random Field_) dans les couches denses finales du modèle, qui a pour effet de "lisser" les coutours des objets en éliminant les artéfacts visuels. Pour cela, des connexions aléatoires sont effectuées en basant les décisions sur celles des voisins les plus proches.

==== DeepLab v2 (2016) @chen_deeplab_2017
La version 2 intègre notamment l'ASPP (_Atrous Spatial Pyramid Pooling_) présenté par PSPNet @zhao_pyramid_2017.

==== DeepLab v3 (2017) @chen_rethinking_2017
Cette version présente des convolutions dilatées mises en cascade et/ou en parallèle en faisant varier le taux de dilatation afin d'améliorer l'ASPP de la version 2.

==== DeepLab v3+ (2018) @chen_encoder-decoder_2018
L'ASPP des précédentes versions est combinée avec l'architecture encodeur-décodeur (par exemple de U-Net) ; le résultat est alors un encodeur-décodeur contenant un _pyramid pooling module_ à la fin de l'encodeur.

=== UPerNet

UPerNet @xiao_unified_2018 est un article scientifique qui présente une méthodologie, soit un "framework" (et non un réseau/modèle) permettant d'achever plusieurs tâches de @computer-vision. C'est un connecteur générique de _backbones_ (un _backbone_ est un modèle de classification dont on se sert comme réseau pour extraire les composantes principales des images avant de les segmenter) pour du multi-tâches. Il ne résout pas un problème mais se branche sur plusieurs _backbones_ : c'est la généralisation d'un décodeur en quelque sorte.

L'intuition proposée, pour introduire ce modèle, est que les convolutions ne permettent pas, de par leur nature et malgré leur biais cognitif (un pixel est toujours traité dans son contexte), d'accéder au contexte global de l'image.

Beaucoup d'équipes qui entraînent un nouveau modèle de classification donnent ensuite leur score sur la tâche de segmentation sémantique en utilisant UPerNet.
Même si cette approche est intéressante, il en ressort que les modèles en question sont généralement gros (beaucoup de paramètres) et en ajoutant le coût de l'entraînement d'UperNet, la tâche serait trop coûteuse.

Cependant, la question sous-jacente reste importante : nous étudions le coût de l'entraînement de modèles mais faut-il autoriser les _backbones_ (parties de modèles) pré-entraînés par autrui pour notre entraînement ?

L'ensemble des modèles vus ci-dessus (U-Net, PSPNet, DeepLab et UPerNet) utilisent tous des _backbones_ comme ResNet (un modèle de référence dans la classification d'images) : nous verrons les raisons et répondrons précisément à ce point dans la section méthodologie un peu plus loin.

== Modèles basés sur des Transformers

=== ViT (Vision Transformers)

Le modèle Vision Transformers @dosovitskiy_image_2021 doit être présenté ici car il est l'un des premiers à proposer une adaptation des @Transformer[s] pour la @computer-vision.
C'est un modèle de classification d'images, et son fonctionnement repose sur le découpage de l'image en "patches" (parcelles) puis en y applicant le mécanisme d'attention.

=== FocalNets

Les FocalNets (Focal Modulation Networks) @yang_focal_2022 sont une série de modèles proposant une modification du mécanisme d'attention en effectuant une agrégation plus rapide dans la partie _query_, _key_ et _value_.
Ils utilisent UPerNet pour la segmentation sémantique car c'est un modèle de classification.

=== SegFormer

SegFormer @xie_segformer_2021 propose une approche utilisant quasiment exclusivement des Transformers et leur mécanisme d'attention (modifié).
Dans l'encodeur (nommé MiT pour _Mix Transformer_), l'image d'entrée est découpée en patchs de $4 times 4$, puis en reproduisant un mécanisme similaire à l'ASPP, c'est-à-dire en générant des représentations multi-niveaux à ${1/4, 1/8, 1/16, 1/32}$ de la résolution de l'image d'origine.
Côté décodeur, une simple série de couches denses est utilisée car l'encodeur est considéré comme suffisamment "puissant" ; le coût calculatoire est alors très intéressant.

=== Segmenter

Contrairement à SegFormer, le modèle Segmenter @strudel_segmenter_2021 repose sur un _backbone_ comme ViT @dosovitskiy_image_2021 et traite le problème de segmentation sémantique comme de la séquence vers séquence, similaire au @NLP. Le but est de modéliser le problème de la computer vision par un problème rapportable à du NLP, là où SegFormer souhaite plus radicalement adapter l'architecture à la tâche de la vision.
Il se décline en deux versions : une version où le décodeur est un MLP (c'est-à-dire un ensemble de couches denses, où tous les neurones sont reliés), et une version où un décodeur est basé sur les Transformers.

L'intuition proposée, pour introduire ce modèle, est que les convolutions ne permettent pas, de par leur nature et malgré leur biais cognitif (un pixel est toujours traité dans son contexte), d'accéder facilement au contexte global de l'image. Plusieurs procédés (empiriques) tentent d'y remédier mais complexifiant le modèle inutilement. L'idée est d'utiliser les Transformers, connus dans le NLP comme étant capables d'exploiter des informations globales, malgré la complexité quadratique de leur module d'attention.

=== Segment Anything Model (SAM)

Cette publication scientifique @kirillov_segment_2023, proposée par une équipe de Meta AI Research durant ce projet de fin d'études, a très vite été populaire au sein de la communauté scientifique.

Il remet en question le domaine même de la segmentation sémantique en introduisant une nouvelle tâche, appelée _promptable segmentation_, dont le concept est de produire un résultat similaire à de la segmentation panoptique selon plusieurs entrées possibles : des points sur l'image, un @prompt, etc. afin de segmenter ce que l'utilisateur a demandé.
En effet, celui-ci consiste en deux innovations :

1. Un jeu de données. Habituellement, les jeux de données en segmentation sémantique se font rares. En effet, l'un des plus connus est ADE20K qui contient plus de 20 000 images, mais cela est souvent considéré comme trop faible ; les modèles sont partiellement entraînés sur des jeux plus gros comme le populaire ImageNet (classification) avant d'être affinés sur ADE20K. Ce papier introduit SA-1B, un nouveau jeu de données conçu en collaboration entre des annotateurs humains et un modèle de segmentation, pour un total de plus d'1 milliard de masques et 11 millions d'images.
2. Un modèle, SAM (_Segment Anything Model_), qui possède une particularité intéressante : lors du chargement d'une image, la première partie de l'@inférence est exécutée sur @GPU (dans le cloud), permettant d'extraire les composants principales de l'image, puis la seconde partie est exécutée directement sur l'appareil de l'utilisateur, comme son navigateur ! Le tout permettant d'effectuer divers "requêtes" à l'image après son traitement initial.

Ce papier ne s'adresse donc pas à de la segmentation sémantique mais propose une approche très enrichissante car les applications qui peuvent en découler sont multiples. Par exemple, il est assez évident que Meta vise le domaine de la réalité virtuelle (VR) afin de tendre vers l'AR (_augmented reality_, réalité augmentée) à terme.

== Modèles hybrides convolutions/Transformers

Je n'ai pas trouvé de modèle spécifique à de la segmentation sémantique étant un hybride convolutions + Transformers. Cependant, les nouveaux modèles de classification basés sur des Transformers proposent des résultats en segmentation sémantique en utilisant des frameworks comme UPerNet étant eux-mêmes constitués de couches de convolution, ce qui est donc une sorte d'hybride.

Toutefois, ces modèles sont souvent gros et ne mettent pas en avant une réelle "collaboration" entre @couche-de-convolution[convolutions] et @Transformer[s].
Également, par choix, cette partie n'aura pas été traitée pour se concentrer sur le reste ; la classification est un domaine plus actif que la segmentation sémantique, c'est pourquoi les innovations de ce premier devraient graduellement atteindre les autres domaines.

== Modèles choisis

Suite à cette étude de l'état de l'art, j'ai choisis 4 modèles afin de le représenter au mieux dans le cadre de ce projet.

==== U-Net @ronneberger_u-net_2015
Modèle déjà disponible au sein de l'équipe, une référence du domaine avec une architecture encodeur-décodeur utilisant des @couche-de-convolution[convolutions].

==== DeepLab v3+ @chen_encoder-decoder_2018
Egalement un des piliers du domaine, un incontournable très compétitif dans l'état de l'art, intégrant plusieurs techniques modernes, comme les convolutions dilatées.

==== SegFormer @xie_segformer_2021 et Segmenter @strudel_segmenter_2021
Ces deux modèles sont parmi les premiers à adapter les @Transformer[s] spécifiquement pour le domaine de la @segmentation-sémantique. Il ont été publiés à peu d'intervalle et, curieusement, ne se citent pas l'un et l'autre. Ils apportent chacun des concepts intéressants, inspirés de ViT @dosovitskiy_image_2021.