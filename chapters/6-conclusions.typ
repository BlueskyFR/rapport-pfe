= Conclusions

Dans ce projet de fin d'études, nous avons cherché à montrer en quoi il vaut mieux utiliser des @couche-de-convolution[couches de convolution] ou des @Transformer[s] afin de répondre à la problématique _"pourquoi devrions-nous utiliser des mécanismes basés sur l'attention en vision par ordinateur ?"_, dans un contexte de modèles d'IA générative devenant toujours plus coûteux à entraîner ainsi que de l'effervescence du @NLP.

Nous avons pu voir que les approches existantes étaient limitantes même si techniquement intéressantes car elles n'étaient pas étudiées pour des applications de @HPC, et ne proposaient pas de comparaison plus fondamentales entre les convolutions et les Transformers.

Notre proposition a été d'ajouter un oeil "performance" en optimisant des bases de codes afin de pouvoir les comparer, en appliquant notre problématique au domaine de la segmentation sémantique.

Nous avons pu constater que les modèles basés sur des @couche-de-convolution[couches de convolution] ont l'avantage d'être plus facilement optimisés à-travers les différentes bibliothèques de code existantes et seront donc certainement préférées sur des jeux de données plus petits, alors que la capacité potentielle de mémorisation des Transformers sera plutôt mise à profit à grande échelle, sur de très larges jeux de données.

Toutefois, notre étude possède des limites : il faudrait multiplier les observations avec divers paramètres, comme par exemple en finalisant les entraînements des modèles restants pour venir ajuster nos propos.

Dans le futur, cette étude pourrait être appliquée à d'autres sous-domaines de la @computer-vision, en testant également d'autres systèmes de parallélisation, comme une pile logicielle basée sur *Alpa + Jax + Ray* qui ne rentrait finalement pas dans le cadre de ce PFE !

Enfin, ce PFE a été bien plus que ce rapport : durant mon alternance, j'ai pu développer des solutions qui doivent toujours être maintenues, nous avons accueilli une doctorante dans le cadre du programme MIAI sur Champollion afin d'aider la recherche et j'ai également apporté de l'aide à d'autres collègues qu'ils m'ont bien souvent rendu en échange !

Je pense que ce projet de fin d'études aura été une très riche expérience.

#pagebreak()