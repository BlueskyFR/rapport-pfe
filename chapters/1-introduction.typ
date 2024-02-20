= Introduction

// Problématique, objectif et articulation du pré-rapport

// Contexte utile pour situer le stage dans son environnement (entreprise,  service, mission, etc.) - 2 pages max.

// Présenter de manière concise et compréhensible par une personne non spécialiste du domaine la pb du projet - ~5 pages
  // Contexte (workflow simplifié)
  // Travail à réaliser ou pb à résoudre
  // Objectifs précis attendus

// Solutions techniques étudiées ou mises en oeuvre - ~10 pages
  // Synthèse de l'existant + contraintes inhérentes au projet w/ bibliographie précise
  // Description solutions envisagées + outils qui seront utilisés
  // Protocole d'évaluation envisagé pour valider votre solution ou mesurer son efficacité

// Présenter l'état de votre avancement - ~2 pages
  // Planning prévisionnel montrant ce qui a déjà été fait et ce qu'il reste à faire (Gantt)

// Impressions personnelles sur les 6 premières semaines (difficultés, à venir, journée type, enseignements tirés à ce stade...) - 1 page max.

// Prise en compte de l'impact environnemental et sociétal - 1 page max.
  // Estimation conso énergétique pendant le travail lié au PFE (bureau, ordinateur, autres dispositifs...)
  // Quels déplacements ont été réalisés pour mener à bien le projet ?
  // La structure d'accueil du PFE met-elle en oeuvre une politique en faveur du développement durable ? Sous quelle forme ?
  // Quel impact sociétal aura le produit fini du PFE ?

// Références bibliographiques

// Annexes facultatives (captures d'écran, code, diagrammes...) : inclure seulement des informations pertinentes bonifiant le rapport

// --------------------------------

/*

Présenter le sujet d'étude, niveau général puis arruver sur le point précis traité dans le travail.
-> Permet de poser la problématique (générale, mais aussi à quoi on répond)

- Présenter le domaine général dans lequel le travail a lieu (e.g. définir les termes importants)
- Puis poser une question dans ce contexte (la problématique)

*/

L'arrivée récente des @LLM et de l'@IA-générative[IA générative] dans le grand public a bouleversé nos repères : en quelques semaines seulement, une grande partie de la population s'est émerveillée devant les réponses impressionantes de #link("https://openai.com/chatgpt")[ChatGPT] (OpenAI) et l'art, parfois même photoréaliste, généré avec #link("https://www.midjourney.com")[Midjourney], #link("https://stability.ai/stablediffusion")[Stable Diffusion] ou encore #link("https://openai.com/dall-e-2")[Dall#sym.dot\E 2], à-partir d'une simple phrase.

Ces technologies, désormais populaires, ont un point commun : ce sont des @modèle[s] de @deep-learning qui ont été entraînés sur des gigantesques jeux de données.

== Qu'est-ce que le deep learning ?

Le deep learning est un domaine ou l'on essaye de résoudre un problème en "entraînant" un modèle. Le modèle est une structure comportant plusieurs couches parallèles et/ou successives, formant une suite d'opérations mathématiques, semblable à une multiplication de plusieurs matrices comportant chacune des "paramètres". Ces paramètres viennent transformer l'entrée (numérique) du modèle, donnant alors une représentation intermédiaire qui sera passée en entrée à la couche d'après. La dernière couche fournit alors un résultat interprétable. En fonction de l'exactitude du résultat, une #link("https://fr.wikipedia.org/wiki/R%C3%A9tropropagation_du_gradient")[rétropropagation] du gradient de l'erreur va être faite sur les paramètres du modèle, par itérations, afin de tendre vers un meilleur résultat la fois suivante : c'est ce que l'on appelle l'@entraînement.

Lors de l'entraînement, les réponses du modèle sont confrontées à celles pré-établies du jeu de données. Un jeu de données associe un lot d'entrées à un lot de sorties correspondantes.

Il est également possible d'imaginer le deep learning comme suit : lorsque le processus associant une sortie à une entrée est connu, il est possible de le programmer, avec du #link("https://fr.wikipedia.org/wiki/Code_source")[code] par exemple. Si cependant le processus n'est pas connu mais qu'il est possible d'établir un jeu de données listant des entrées et leurs sorties, en suffisamment grand nombre, alors il est possible de recourir à des méthodes comme du machine learning ou du deep learning.

Le deep learning est un sous-ensemble du machine learning qui repose, comme vu ci-dessus, sur l'apprentissage de représentations de données par opposition à des algorithmes qui sont, eux, plus spécifiques à une tâche.

#figure(
  image("../assets/nlp-compute-growth.png"),
  caption: [
    Evolution du nombre de @FLOP[*FLOPs* (Floating Point Operations)] requis pour l'entraînement de @modèle[s]
    de l'@SOTA en @computer-vision, @NLP et speech (synthèse de voix) (#link("https://medium.com/riselab/ai-and-memory-wall-2cb4265cb0b8")[source])
  ]
) <fig-nlp-compute-growth>

== Contexte

Depuis l'arrivée des transformers, la taille des @LLM[s] n'a cessé d'augmenter, de manière globalement exponentielle mais très largement supérieure à la loi de Moore
#footnote[Nous ne nous intéressons pas ici à l'exactitude de la loi de Moore mais à la différence d'ordre de grandeur dans les évolutions].
Cette dernière suit approximativement l'évolution de la puissance de calcul disponible (nombre de transistors sur un microprocesseur) et montre que celle-ci double environ tous les 2 ans. Comme visible sur la @fig-nlp-compute-growth les LLMs, eux, voient leur puissance calculatoire requise multipliée par plus de 10 chaque année depuis 2018 pour un total d'environ 750 en 2 ans, à titre comparatif. Cela montre bien une chose, outre le fait qu'une limite va être atteinte tôt ou tard : les moyens de calculs requis deviennent de plus en plus coûteux et l'on va, dans ce contexte, vite devoir parler de supercalculateur lors de l'entraînement d'un (très) grand modèle.

Nous avons ici pris l'exemple des @LLM[s] afin de mettre en avant leurs tailles spectaculaires (parfois jusqu'à plus d'1T ($10^12$, mille milliards) de paramètres !), mais cela est en fait applicable à tout le domaine de l'@IA-générative. Ceci résulte en des modèles dont l'entraînement nécessite toujours plus de @GPU[processeurs graphiques (GPUs)].

Cette politique de "toujours plus" est permise notamment grâce à une technologie qui se met très bien à l'échelle lorsqu'elle est parallélisée : le @Transformer.

#align(
  center + bottom,
  grid(
    columns: (55%, 45%),
    column-gutter: 10pt,
    [
      #figure(
        image("../assets/transformer-model-architecture.png", height: 50%),
        caption: [
          Architecture d'un modèle @Transformer \
          (source: @vaswani_attention_2023)
        ]
      ) <fig-transformer-model-architecture>
    ],
    [
      #figure(
        image("../assets/transformer-model-qkv.png", height: 35%),
        caption: [
          Architecture du mécanisme de _multi-head attention_ \
          (source: @vaswani_attention_2023)
        ]
      ) <fig-transformer-model-qkv>
    ],
  )
)

== Transformers <transformers-def>

Les Transformers ont été introduits et popularisés par le papier _Attention Is All You Need_ @vaswani_attention_2023.
Ils sont inspirés de travaux précédents sur l'attention @bahdanau_neural_2016 @kim_structured_2017 @parikh_decomposable_2016 et comportent plusieurs mécanismes intéressants ; une des notions principales est la _multi-head attention_ (attention multi-têtes) qui est basée sur le mécanisme de _self-attention_ (auto-attention) : l'idée est de permettre au modèle de formuler des "requêtes" d'un mot par rapport aux autres dans la phrase, et de former ainsi des vecteurs de contexte. Par exemple, dans la phrase "Cette pastèque est sucrée", le vecteur de contexte de `sucrée` donnerait beaucoup d'importance à `pastèque`, mot auquel il se rapporte.

La @fig-transformer-model-architecture illustre l'architecture d'un modèle Transformer, où l'on peut isoler 2 types de blocs (en gris) : à gauche l'_encoder_ qui va, dans un contexte de traduction de français vers anglais par exemple, venir "encoder" la phrase originale en français ; à droite, le _decoder_ qui va recevoir les informations de l'_encoder_ tout en se référant à la portion de phrase déjà traduite en anglais, dans le but de prédire quel sera le prochain mot : on parle alors de _"masked" multi-head attention_.

Comme illustré dans la @fig-transformer-model-qkv, le mécanisme de _multi-head attention_ est consitué de 3 couches denses mises en parallèle, dans le but d'imiter un système similaire à une base de données, permettant d'effectuer des "requêtes" entre les différents mots de la phrase.

En effet, les Transformers ont la particularité d'être parallélisables à l'entraînement, c'est à dire que l'on va pouvoir prédire $n$ mots à la fois en masquant la partie de la phrase que le modèle n'est pas sensé connaître dans chaque partie concurrente.
Durant la phase d'@inférence cependant, c'est-à-dire la phase on l'on va tester le modèle afin de l'utiliser sur des nouvelles données, l'exécution sera forcément séquentielle car il faudra générer le mot $n - 1$ pour générer le mot $n$.

En pratique, les mots ne sont pas générés ou utilisés tels quels directement, ils sont découpés en _tokens_. Par exemple `bonjour`, étant lui-même un mot peu commun, pourrait être découpé en `bon ##jour` : `bon` et `jour` sont deux radicaux potentiellement plus fréquents (le préfixe `##` désigne la suite d'un mot). Cela permet par exemple d'avoir `jour`, puis `jour ##s` une fois au pluriel !

A la base présenté comme un outil dans le domaine du @NLP, la communauté scientifique a essayé (et essaye encore, à l'heure où je rédige ces mots) d'appliquer les @Transformer[s] à d'autres domaines que le texte comme la @computer-vision[vision], pourtant à l'origine dominée par des @couche-de-convolution[couches de convolution] ou dérivé(e)s.

#figure(
  image("../assets/convolution-layer.png"),
  caption: [
    Convolution sur une matrice 6x6 avec un kernel de taille 3x3
    (#link("https://www.datakeen.co/3-deep-learning-architectures-explained-in-human-language-2/")[source])
  ]
) <fig-convolution-layer>

== Couches de convolution

Les @couche-de-convolution[couches de convolution] effectuent une convolution sur l'entrée qui leur est fournie, comme illustré ci-dessus dans la @fig-convolution-layer. Pour cela un _kernel_, de taille arbitraire, est appliqué en haut à gauche, puis chacun de ses paramètres est multiplié par la valeur qu'il recouvre ; chacun des 9 résultats sont en suite additionnés ensemble pour donner, ici, un résultat de $-5$. Le kernel est ensuite déplacé vers la droite et vers le bas de sorte à ce que toutes les cases de la matrice de résultat aient été remplies.
En déplaçant un kernel de 3x3 sur une matrice 6x6, nous avons une matrice 4x4 en résultat, à cause du kernel ne pouvant pas être centré sur la case en haut à gauche. Pour prévenir cela, il est généralement appliqué un _padding_, qui peut par exemple être constitué d'une bande de zéro autour de la matrice d'entrée, permettant ainsi de garder une matrice 6x6 en sortie.

Les couches de convolution sont particulièrement adaptées au traitement d'images car elles permettent de traiter des pixels dans leur contexte. En regardant les couches de convolution d'un modèle après entraînement, on s'apperçoit qu'elles détectent des motifs, plutôt simples dans les premières couches, mais qui deviennent de plus en plus complexes au fur-et-à-mesure qu'elles s'enchaînent. Comme d'habitude en deep learning, les séries de transformations non-linéaires vont permettre de détecter des motifs complexes en se combinant.

Nous aurons l'occasion de reparler de certains détails conçernant les @Transformer[s] et les @couche-de-convolution[couches de convolution] par la suite, le but était ici de donner l'intuition de leur fonctionnement.

Ayant vu ces éléments, nous pouvons d'ores et déjà nous poser la question suivante : *devons-nous utiliser les Transformers, les couches de convolution ou un mix des deux ?*
Nous allons voir ci-après d'autres éléments nous permettant de préciser cette question.

== Entreprise

@HPE, née de la séparation d'HP en 2 entitées en 2015, a hérité de la partie services aux entreprises avec notamment la vente de supercalculateurs, qui apparaissent d'ailleurs très régulièrement au #link("https://top500.org")[Top 500].
La performance est le coeur de métier d'HPE, et c'est là que l'expertise de l'entreprise vient croiser celle de ses clients : en effet, lors de la livraison d'un supercalculateur une _acceptance_ doit être passée, venant démontrer la conformité de la machine ainsi livrée, en termes de performance brute sur des tâches choisie par le client comme critères.

Etant donné que nous parlons de supercalculateurs, cela signifie que les charges de travail sont à grande échelle et doivent donc être optimisées.
L'entraînement d'un @LLM émet l'équivalent carbone ($"CO"_2"eq"$) de 25 à 50 allers-retours Paris-New York en avion pour 1 passager
#footnote[Source : https://eco-calculateur.dta.aviation-civile.gouv.fr],
selon le pays
#footnote[Source : https://app.electricitymaps.com/zone/FR].
D'autre part, celui-ci coûte cher en électricité : de 400 à 1500 MWh en moyenne @luccioni_estimating_2022, soit de 3 à 10 millions de kilomètres parcourus en Tesla Model 3
#footnote[Source : https://www.tesla.com/fr_ch/support/european-union-energy-label]
!

== Equipe

J'ai eu la chance de réaliser mon alternance ainsi que ce projet de fin d'études dans l'équipe HPC & AI (_High Performance Computing and Artificial Intelligence_, Calcul Haute Performances et Intelligence Artificielle), qui se situe dans le centre de compétences de Grenoble qui possède une expertise mise à disposition de la zone EMEA (_Europe, Middle East and Africa_).

Le site de Grenoble est l'un des rares sites à disposer d'un lab, c'est-à-dire d'un petit datacenter dans lequel du matériel est constamment testé (avec des @benchmark[s]) et mis à disposition de clients, nous permettant ainsi d'effectuer des tests à grande échelle.

L'équipe est plutôt orientée HPC, mais travaille aussi bien sur les parties entraînement qu'inférence côté IA. De mon côté, ce @PFE s'articule principalement sur la partie entraînement IA car c'est dans cette phase que les calculs massivement parallélisés interviennent et nécessitent des supercalculateurs.

Nous avons choisi la @segmentation-sémantique car il s'agit d'un domaine pour lequel nous avons déjà un modèle de référence. Ce domaine a le potentiel d'apporter des connaissances pouvant servir pour diverses applications par la suite, comme dans la conduite autonome ou tout simplement en tant que @benchmark pour l'équipe, afin de profiler un système pour une tâche clée dans le futur.

== Segmentation sémantique

La segmentation sémantique est un sous-domaine de la @computer-vision, consistant à attribuer une classe (chien, chat, route, voiture...) à chaque pixel d'une image, formant ainsi des sortes de masques à la fin étant donné que les pixels proches ont tendance à avoir la même classe.
La segmentation sémantique ne permet pas de différencier deux chiens sur une image mais les identifiera tous deux comme "du chien"
#footnote[Citation d'un grand philosophe, Frederic Ciesielski],
contrairement à la segmentation d'instances qui, elle, saura différencier les deux chiens mais sans savoir qu'ils sont tous les deux des chiens ; seulement qu'ils sont différents : on dit qu'ils représentent différentes instances.

La combinaison de la segmentation sémantique et d'instances existe : la segmentation panoptique, qui attribue une classe et une instance à chaque pixel.

Comme vu précédemment, le modèle que nous possédons permet de faire de la segmentation sémantique, c'est pourquoi c'est la tâche que nous choisissons.

== Objectifs

Le #link("https://www.top500.org")[Top500] classe deux fois par an les 500 supercalculateurs les plus puissants de la planète. Le #link("https://www.top500.org/lists/green500/")[Green500] classe les supercalculateurs du Top500 selon un critère d'efficacité énergétique : dans la liste de juin 2023, les premiers développent plus de 60 GFLOPs/Watt. On constate un rapport de 4 entre le $1^"er"$ et le $50^"ème"$ de la liste et de 14 entre le $1^"er"$ et le $100^"ème"$. D'autre part, les 50 premiers systèmes comportent des accélérateurs (comme des @GPU[s]).
Dans ce contexte, il est alors intéressant de vouloir réduire sa consommation, une fois la machine déployée en phase de production.
Le pays d'installation a alors de l'importance quant au type d'énergies utilisées pour fabriquer de l'électricité, comme le charbon en Allemagne.
Même si des progrès peuvent probablement être faits du côté de la fabrication du matériel, cette étude s'adresse à la partie logicielle qui a sans doutes un fort impact durant la vie du supercalculateur.

Notre objectif est ainsi de comparer l'efficacité énergétique des deux architectures de modèles, Transformers et convolutions, pour un problème donné de @computer-vision. Cela nous permettra par exemple de déterminer l'impact du mécanisme d'attention (_self-attention_) des Transformers.
Pour cela, des critères communs doivent également être définis : je choisis, entre autres, la précision (_accuracy_) du modèle, et le jeu de données (nous détaillerons les points communs dans la méthodologie).
Ensuite, des modèles représentatifs de l'état de l'art devront être choisis.

Nous pourrons profiter de la scalabilité (mise à l'échelle) des modèles basés sur les Transformers ou les convolutions quand ceux-ci sont parallélisés sur plusieurs noeuds avec HPE @MLDE.

== HPE MLDE

_Hewlett Packard Enterprise Machine Learning Development Environment_ est une plateforme dévelopée par @DeterminedAI, déployée sur un @cluster de calcul, permettant de faire de l'entraînement distribué de @modèle[s], c'est-à-dire sur plusieurs unités de calcul (ici des @GPU[s]) en parallèle. Paralléliser un entraînement est nécessaire dans certains cas si le modèle est trop gros pour un seul @GPU, et permet d'une manière générale d'accélérer l'entraînement.
L'entraînement d'un modèle peut être parallélisé de plusieurs manières : par exemple en disposant d'une copie du modèle par accélérateur (GPU) mais en fournissant à chaque instance des données différentes, ou en séparant les couches du modèle en plusieurs parties puis en les plaçant chacune sur un GPU différent. Cette dernière méthode introduit des communications supplémentaires et est utile notamment quand le modèle est trop grand pour la mémoire d'un seul accélérateur.
MLDE propose également de l'_hyperparameter tuning_, soit de l'optimisation d'hyperparamètres : ces derniers sont des paramètres globaux du modèle (nombre de couches, leur taille, etc.) afin de trouver la configuration optimale ; l'idée est de représenter les différentes valeurs des hyperparamètres comme un espace $n$-dimensionnel et de le parcourir avec une méthode efficace @li_system_2020, limitant les calculs inutiles.

Enfin, pour conclure cette liste des objectifs, si le temps l'avait permis j'aurais aimé étudier les différences de performances entre @MLDE et un pile logicielle constituée d'#link("https://github.com/alpa-projects/alpa#readme")[Alpa], #link("https://github.com/google/jax#readme")[JAX] et #link("https://www.ray.io")[Ray], dont nous discuterons brièvement dans les pistes de poursuites.

== Livrables

Nous souhaitons qu'il ressorte de ce projet de fin d'études plusieurs livrables. Premièrement, ce document lui-même comportera une méthodologie détaillant comment estimer l'énergie consommée par l'@entraînement d'un modèle.
Deuxièmement, une seconde méthodologie viendra compléter la première en montrant comme étudier la scalabilité (mise à l'échelle) en étudiant l'entraînement d'un modèle.
Troisièmement, les recettes d'entraînement pour chacun des modèles seront fournies, compatibles directement avec HPE MLDE si possible.

== Plan du document


Dans un premier temps nous passerons en revue l'état de l'art dans le contexte de cette étude, puis nous introduirons la méthodologie. Nous présenterons ensuite nos résultats en les analysant, et effectueront une critique de ce projet de fin d'études. Enfin, nous concluerons.