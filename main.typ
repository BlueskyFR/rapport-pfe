#import "template.typ": PFE
#import "glossary.typ": enable-glossary, term-glossary, acronym-glossary

#show "noeud": "nœud"
#show "noeuds": "nœuds"
#show "coeur": "cœur"
#show "oeil": "œil"

// Style for the LaTeX logo
#let TeX = style(styles => {
  let e = measure(text(1em, "E"), styles)
  let T = "T"
  let E = text(1em, baseline: e.height / 4, "E")
  let X = "X"
  box(T + h(-0.1em) + E + h(-0.125em) + X)
})
#let LaTeX = style(styles => {
  let l = measure(text(1em, "L"), styles)
  let a = measure(text(0.7em, "A"), styles)
  let L = "L"
  let A = text(0.7em, baseline: a.height - l.height, "A")
  box(L + h(-0.3em) + A + h(-0.1em) + TeX)
})

// Some style for citations
#set cite(style: "alphanumeric")
#show cite: set text(rgb("#7630EA"))

// Raw `text` color (not code blocks)
#show raw.where(block: false): set text(fuchsia) // blue or fuchsia?

// This is supposed to be in the template but nested show rules
// slow down the compiler (bug)
// Set run-in subheadings, starting at level 3.
#show heading: it => {
  if it.level >= 4 {
    parbreak()
    text(weight: "bold", it.body + [.#sym.space.quad])
  } else {
    v(.2em)
    it
    v(.6em)
  }
}

// Front page
#show: PFE.with(
  title: "Transformers pour la vision par ordinateur",
  subtitle: [Pourquoi devrions-nous utiliser des mécanismes basés sur l'attention \ en vision par ordinateur ?],

  author: "Hugo CARTIGNY",
  year-and-option: [ 3#super[ème] année en alternance -- Double diplôme MSIAM ],
  dates: (from: "13 février 2023", to: "31 août 2023"),
  
  enterprise: (
    name: "Hewlett Packard Enterprise",
    logo: "assets/logo-hpe.png",
    address: (
      name: "HPE",
      line1: "5 Rue Raymond Chanas",
      line2: "38320 Grenoble",
    ),
  ),

  internship-supervisor: "Bruno MONNET",
  school-tutor: "Olivier FRANÇOIS",
  
  supervisors: (
    (name: "Bruno Monnet", email: "bruno.monnet@hpe.com", affiliation: "Maître d'apprentissage"),
    (name: "Olivier François", email: "olivier.francois@univ-grenoble-alpes.fr", affiliation: "Tuteur pédagogique"),
  ),

  
  abstract: [
    L'arrivée des Transformers pour le traitement du langage naturel a permis le développement de modèles génératifs fondamentaux tels que GPT-4, plus connu sous sa version conversationnelle ChatGPT.
    Le domaine de la vision par ordinateur a lui aussi bénéficié de cette avancée, sous le nom de *vision transformers*, offrant alors une alternative aux couches de convolution, ces dernières ayant déjà fait leurs preuves.
    Nous nous posons alors une simple question: _pourquoi devrions-nous utiliser des mécanismes basés sur l'attention en vision par ordinateur ?_

    Pour y répondre, nous allons nous intéresser au coût énergétique lié à l'entraînement de ces différentes architectures appliqué à la tâche de la *segmentation sémantique*, et verrons qu'il est même possible de les combiner. Nous détaillerons dans un premier temps le protocole mis en place permettant de comparer les entraînements, puis nous étudierons leur scalabilité sur plusieurs noeuds de calcul en utilisant *HPE MLDE*.

    (Enfin, si le temps le permet, nous étudierons la performance de MLDE comparé à une pile logicielle *Alpa + Jax + Ray* en terme d'efficacité énergétique).

    Dans le cadre fixé par ce projet de fin d'études, nous verrons notamment qu'un modèle basé sur des couches de convolution nécessite moins d'énergie pour atteindre une précision (_accuracy_) cible fixée qu'un modèle basé sur des Transformers, et tenterons d'expliquer ces écarts en formulant des hypothèses.
  ],

  acknowledgements: [
    Je tiens avant tout à remercier Bruno Monnet qui a été mon maître d'apprentissage durant ces 3 années d'alternance à l'Ensimag ; il m'a accompagné dans cette découverte du monde de l'entreprise et m'a introduit au monde fabuleux du calcul hautes performances associé à l'intelligence artificielle en me faisant rejoindre une équipe qui regorge de talent.

    Je souhaite exprimer ma gratitude à Olivier François, mon tuteur pédagogique côté école qui m'a suivi durant ce projet, qui m'a suggéré de rediger ce document comme un rapport scientifique : j'ai trouvé cela très adapté à mon sujet et j'ai pu découvrir une méthode de rédaction que je pourrai sans aucun doute réutiliser dans le futur !

    Je souhaite remercier tous les collègues avec lesquels j'ai pu travailler : Hana Malha, Frederic Ciesielski, Jean Pourroy, Sébastien Cabaniols, Philippe Vettori, Scott Johnson ainsi que ma manager Nathalie Viollet, sans oublier mon coach de l'ombre Amar Zitouni.
    
    Je remercie également mes confrères apprentis et stagiaires qui m'ont accompagné durant mon parcours, dans l'ordre : Nicolas Guerroudj, Tom Capelle, Théo Rozier, Tibault Dorn, Arvind Candassamy, Clémence Mayjonade, Arnaud Hincelin, Emilien Tellier, Sari Boussouar et Nicolas Diniz.

    Une pensée particulière à mes camarades de promotion : Tanguy Paymal, Gaspard Andrieu, Thomas Vincent, Romain Lopez mais aussi tous les autres que j'oublie (trop de monde !).

    Je remercie évidemment ma famille pour leur soutien moral durant ce projet, aussi bien pendant les bonnes que les mauvaises phases : leur présence et leurs encouragements ont été très importants pour moi.

    Dans le cadre de ce rapport, je remercie Jean Pourroy et Hana Malha pour leur aide et précieux conseils, ainsi que Jean pour sa #link("https://theses.hal.science/tel-03249275v1/document")[thèse] dont je me suis inspiré du style !

    Enfin, je remercie le projet #link("https://typst.app")[Typst] @madje_programmable_2022 d'avoir vu le jour, proposant un fantastique outil en remplacement de #LaTeX pour la rédaction de cet ouvrage!
  ],
)

// Enable glossary
#show: enable-glossary

#align(horizon)[
  
  = Légende
  
  Ce document utilise les conventions suivantes : en prendre connaissance vous permettra de rendre votre lecture plus agréable !

  - *Gras*: Référence cliquable au glossaire ou à la liste d'acronymes
  - _Italique_: mot(s) en anglais
  - #underline[Souligné]: lien vers une ressource externe (e.g. un site web) cliquable
  - Figure 1: référence à une figure dans le document, cliquable
  - @xie_segformer_2021: référence à une publication scientifique, cliquable pour accéder à l'entrée de la bibliographie correspondante
]

#pagebreak(weak: true)

// Pagebreaks for level 1 titles from here
#show heading: it => {
  if it.level == 1 {
    //set page(numbering: none)
    pagebreak(weak: true, to: "odd")
    //set page(numbering: "1")
    it
    v(.2em)
  } else { it }
}

= Glossaire

#term-glossary[
  
  / computer vision: Vision par ordinateur. Branche de l’intelligence artificielle qui traite de la façon dont les ordinateurs peuvent acquérir une compréhension de haut niveau à partir d'images ou de vidéos numériques.
  / CUDA: CUDA est une technologie permettant de programmer des GPUs en C++ (langage de programmation) pour exécuter des calculs généraux à la place du processeur central (CPU). Elle est développée par NVIDIA pour ses cartes graphiques, et utilise un pilote unifié utilisant une technique de streaming (flux continu).
  / benchmark: Code ou ensemble de codes permettant de mesurer la performance d'une solution et d'en vérifier ses fonctionnalités.
  / bottleneck: Goulot d'étranglement. Dans un code HPC, point limitant le calcul car représentant la partie la plus lente, retardant le reste des composants interragissant avec.
  / cluster: Grappe de serveurs sur un réseau, ferme ou grille de calcul.
  / conteneur: Enveloppe virtuelle permettant de distribuer une application avec tous les éléments dont elle a besoin pour fonctionner (fichiers, environnements, librairies...). Un conteneur peut fonctionner sur la plupart des systèmes utilisant le noyau Linux car il le partage à l'exécution, n'impactant donc pas les performances. Cela permet de reproduire très facilement une expérience sur un autre système, en plus de pouvoir l'isoler du reste du système pendant son exécution.
  / couche de convolution: Type de couche d'un @modèle de @deep-learning, permettant de calculer une sortie en déplaçant un _kernel_ (matrice carrée) sur une matrice d'entrée (i.e. en effectuant une convolution sur l'entrée). A ne pas confondre avec un CNN (_Convolutional Neural Network_, qui désigne un modèle complet composé, entre autres, de couches de convolution).
  / deep learning: #link("https://fr.wikipedia.org/wiki/Apprentissage_profond")[Apprentissage profond]. Sous-domaine de l'intelligence artificielle qui utilise des réseaux neuronaux pour résoudre des tâches complexes, grâce à des architectures articulées de différentes transformations non linéaires.
  / Determined.AI: Rachetée par HPE en 2021, entreprise développant une solution open-source du même nom permettant de paralléliser des entraînements de @modèle[s] sur un cluster de calcul.
  / entraînement: En @deep-learning, l'entraînement consiste à estimer un modèle à-partir d'observations en nombre fini (un jeu de données) dans le but de résoudre une tâche. Cette phase est également appelée "apprentissage", et est réalisée avant la phase d'@inférence qui consiste en son exploitation.
  / IA générative: Ensemble des techniques d'intelligence artificielle permettant de générer du contenu, le plus souvent du texte, des images ou des médias à-partir de @prompt.
  / inférence: La phase d'inférence représente l'exécution d'un modèle une fois qu'il a été entraîné. Pour cela, il est possible d'appliquer de nombreuses optimisations afin d'augmenter les performances lors de la mise en production, comme de la quantification qui consiste à réduire le nombre de bits sur lesquels les paramètres du @modèle sont stockés afin de pouvoir en traiter plus en parallèle.
  / max-pooling: En deep-learning, couche fonctionnant de la même manière qu'une @couche-de-convolution mais sans paramètres ; son _kernel_ $n times n$ effectue l'opération $max()$ sur les pixels qu'il traite : cela a alors pour effet d'effectuer une "moyenne" de l'image en gardant les valeurs les plus fortes par région. Cette opération est souvent employée pour réduire la taille de l'image/d'un tenseur en réduisant le coup calculatoire.
  / modèle: En deep learning, également appelé réseau de neurones; formé de couches parallèles et/ou successives contenant des paramètres entraînables.
  / neurone: Représentation mathématique simplifiée d'un neurone physique, représenté par $y = "activation"(w dot x + b)$, où $w$ et $b$ sont des paramètres entraînables, et `activation` est une fonction non-linéaire (par exemple $"ReLU"(x) = max(0, x)$).
  / prompt: Invite sous forme de texte, phrase ou instruction donnée à un @modèle.
  / PyTorch: Bibliothèque logicielle basée sur le langage de programmation Python permettant de réaliser des calculs tensoriels nécessaires notamment pour le @deep-learning, en utilisant le CPU et le GPU, supportant @CUDA. Initialement développé par Facebook (Meta) et #link("https://www.silicon.fr/pytorch-fondation-linux-encadrement-gafam-447164.html")[confié] fin 2022 à la fondation Linux.
  / segmentation sémantique: Sous-domaine de la @computer-vision, consistant à attribuer une classe (chien, chat, route, voiture...) à chaque pixel d'une image, sans pour autant pouvoir différencier plusieurs instances d'une même classe.
  / tenseur: Objet mathématique. Un tenseur est un tableau multidimensionnel qui est une sorte de généralisation du concept de matrice ou de vecteur ; il possède une ou plusieurs dimensions (une "forme") et les données qu'il contient ont toutes le même type (entiers, flottants...).
  / TensorFlow: Bibliothèque logicielle développée par Google, similaire et concurrente à @PyTorch. Elle propose aussi des composants plus haut niveau (plus d'abstraction) et orientée objet, ce qui la rend plus accessible mais permet à PyTorch d'être généralement préférée pour le monde de la recherche.
  / Transformer: Type de couche d'un @modèle de @deep-learning, basé sur un mécanisme dit de "_self-attention_" permettant de calculer une sortie en associant un contexte à une entrée (e.g. un mot). Plus d'informations dans l'#link(<transformers-def>)[introduction aux Transformers].

]

#pagebreak(weak: true)

= Acronymes

#acronym-glossary[
  
  / FLOP: _Floating Point Operation;_ opération à virgule flottante
  / FLOPS: _Floating Point Operation per Second;_ nombre d'opérations à virgule flottante par seconde (FLOP/s). #emoji.warning Ne pas confondre avec FLOPs (plusieurs FLOP)
  / GPU: _Graphics Processing Unit;_ processeur graphique. Carte physique de calcul massivement parallèle, particulièrement utile pour accélérer les entraînement de @modèle[modèles] en @deep-learning, ces derniers étant principalement constitués de multiplications matricielles
  / HPC: _High Performance Computing;_ calcul haute performance
  / HPE: Hewlett Packard Enterprise
  / LLM: _Large Language Model(s);_ modèle(s) de langage de grande taille. Généralement de plusieurs dizaines voire centaines de milliards de paramètres
  / mIoU: _mean Intersection over Union;_ intersection sur l'union moyenne. Aussi connue sous le nom d'#link("https://fr.wikipedia.org/wiki/Indice_et_distance_de_Jaccard")[indice de Jaccard], cette métrique permet de mesurer la distance entre deux répartitions de classes au sein d'une image en @segmentation-sémantique
  / MLDE: Machine Learning Development Environment. Nom commercial de la solution open-source #link("https://determined.ai")[Determined.AI] (#link(<DeterminedAI>)[voir glossaire])
  / NLP: _Natural Language Processing;_ traitement automatique du langage naturel
  / PFE: projet de fin d'études
  / SOTA: _State-of-the-art;_ état de l'art

]

#pagebreak(weak: true)

#set heading(numbering: "1.1.")

#include "chapters/1-introduction.typ"
#include "chapters/2-SOTA.typ"
#include "chapters/3-methodology.typ"
#include "chapters/4-results.typ"
#include "chapters/5-discussions.typ"
#include "chapters/6-conclusions.typ"

= Bibliographie

Vous pouvez retrouver dans cette section l'ensemble des papiers cités dans ce document, par ordre alphabétique.

#bibliography("PFE.bib", style: "chicago-author-date", title: none)