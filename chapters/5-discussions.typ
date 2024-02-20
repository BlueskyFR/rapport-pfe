= Discussions

Dans cette partie, nous analyserons de manière critique l'approche développée dans les précédentes parties.

== Forces de l'approche

Le point de vue @HPC d'une solution de @deep-learning n'est que rarement abordé dans l'état de l'art, les résultats montrant un meilleur score sur un jeu de données attisant généralement plus la curiosité des lecteurs. Dans un contexte où l'on cherche délibérément le "toujours plus", il nous semble bon de se poser la question "comment consommer moins ?".

Paradoxalement, répondre à cette question passe par de la consommation de notre côté, pour pouvoir fournir ces résultats. Cependant, la rentabilité de ce coût sera déterminée par la réutilisation de ce travail par la suite, via le présent document par exemple ou par la méthodologie que nous présentons.

Enfin, une des forces de notre approche est la généricité de la méthodologie, qui peut s'appliquer à tout type d'accélérateur et de système afin d'effectuer une comparaison du même type.

== Faiblesses de l'approche

Dans notre démarche, il est possible d'observer que de nombreux éléments sont "uniques". Par exemple l'environnement d'exécution (un seul type de serveur donc un seul type de GPU, etc.), le framework (PyTorch seulement), nos résultats (un seul modèle de chaque type) ou encore MLDE (un seul outil de parallélisation).

==== MLDE
D'une manière générale, des technologies comme @MLDE rajoutent des couches d'abstraction au-dessus d'une couche déjà existante (dans ce cas, PyTorch). Avec le recul, dans un contexte de recherche très près de l'état de l'art, ce détail est très important car il limite immédiatement notre capacité à innover en dépendant d'un facteur supplémentaire, c'est-à-dire d'avoir moins de contrôle sur notre solution ; ce qui vient en contradiction avec le domaine du @HPC où il s'agit souvent, justement, de contrôle sur les opérations.

De la redondance dans les outils est donc nécessaire afin de stabiliser les résultats ; cela vient compléter les critères communs lors d'une comparaison, afin que les réelles différences puissent ressortir sans être masquées par des facteurs externes.

Le "problème" que nous essayons de résoudre peut-être représenté comme un espace infini-dimensionnel dans lequel nous devons chercher notre réponse, donc nous ne pourrons jamais avoir un environnement parfait : la difficulté est de déterminer quels facteurs sont les plus importants et peuvent avoir le plus d'influence sur les résultats.

Une question intéressante que nous pouvons nous poser est si, au final, les différences entre les couches de convolution et les Transformers n'étaient pas liées à l'implémentation ? Celle-ci varie en fonction des frameworks voire même en fonction du matériel utilisé, donc il se pourrait qu'elle soit en fait prédominante dans tous les tests effectués si nous généralisions à d'autres frameworks.

== Notre approche répond-elle à la problématique ?

Je pense que cette approche répond à la problématique _"pourquoi devrions-nous utiliser des mécanismes basés sur l'attention en vision par ordinateur ?"_ en investiguant les différences entre les couches de convolution et les Transformers dans le contexte d'entraînement de modèles de deep learning appliqué à la tâche de segmentation sémantique.

== Pistes de poursuites

Cette étude se déroulant sur 6 mois, le sujet pourrait très largement être approfondi, sur de nombreux axes ! En voici quelques exemples.

Dans un premier temps, finaliser les entraînements des deux autres modèles (DeepLab v3+ et Segmenter) serait un vrai plus, et adapter tous les modèles pour les rendre compatible avec @MLDE (tâche très compliquée sans réaliser de compromis).

Deuxièmement, effectuer les tests à nouveau mais avec les phases de pre-training serait très intéressant car les capacités mémorielles des @Transformer[s] seraient plus solicitées.

Ensuite, une comparaison bas niveau entre les convolutions et les Transformers serait une bonne chose. Un exemple d'une telle comparaison est effectué dans @li_can_2021, mais je pense qu'il serait mieux de l'axer sur une comparaison au niveau des @FLOP[s] et de l'énergie liée.

Enfin, le deep learning et l'intelligence artificielle en général sont des domaines où de nombreux articles scientifiques paraîssent tous les jours, et il est donc probable que les meilleures méthodes et choix émergent simplement empiriquement dans le futur !

== Impact environnemental et sociétal

Dans cette section, nous verrons les aspects liés à l'impact environnemental et sociétal de ce PFE.

==== Estimation de la consommation énergétique au travail
Pendant ce PFE de 6 mois, j'estime la consommation des équipements suivants, utilisés au travail :
- Ordinateur portable + 2 écrans: 200 kWh
- Supercalculateur Champollion, en état inactif (hors charge), hors infrastructure externe (clims, _switchs_...), à partager entre les utilisateurs : 89 000 kWh
- Éclairage : 240 kWh

==== Déplacements
Mes déplacements ont été réalisés en utilisants les transports en communs ou en trotinette électrique, soit environ 1.68kg $"CO"_2"eq"$.

==== Politique de la structure d'accueil
D'après les informations que j'ai pu trouver, HPE est engagé dans la réduction de l'impact environnemental de ses clients mais ne donne pas d'exemples précis concernant sa _supply chain_.

L'entreprise a toutefois annoncé qu'elle souhaitait atteindre le "Net 0" émissions dans sa _value chain_ d'ici 2040
#footnote[https://www.hpe.com/us/en/living-progress.html].

==== Impact sociétal du produit fini
Le produit fini, dans notre cas cette étude à-travers ce rapport et les codes associés, a le potentiel d'aider à réduire la consommation d'énergie (d'électricité) sur les entraînements de deep learning en mettant en lumière les différences entre les technologies étudiées, par exemple sur des entraînements à large échelle.