#import "template.typ": PFE

#show "noeuds": "nœuds"

// Front page
#show: PFE.with(
  title: "Using Transformers for computer vision",
  subtitle: "Why should we use attention-based mechanisms in computer vision?",

  author: "Hugo CARTIGNY",
  year-and-option: [ 3#super[ème] année en alternance -- Double diplôme MSIAM ],
  dates: (from: "13 février 2023", to: "31 août 2023"),
  
  enterprise: (
    name: "Hewlett Packard Enterprise",
    logo: "logo-hpe.png",
    address: (
      name: "HPE",
      line1: "5 Rue Raymond Chanas",
      line2: "38320 Grenoble",
    ),
  ),

  internship-supervisor: "Bruno MONNET",
  school-tutor: "Olivier FRANÇOIS",
  
  authors: (
    (name: "Hugo", email: "hugo@hpe.com", affiliation: ""),
    (name: "Bruno Monnet", email: "bruno.monnet@hpe.com", affiliation: "Maître d'apprentissage"),
    (name: "Olivier François", email: "olivier.francois@univ-grenoble-alpes.fr", affiliation: "Tuteur pédagogique"),
  ),

  
  abstract: [
    L'arrivée des transformers pour le traitement du langage naturel a permis le développement de modèles gigantesques tels que GPT-4, plus connu sous sa version conversationnelle ChatGPT.
    Le domaine de la vision par ordinateur a lui aussi bénéficié de cette avancée, sous le nom de *vision transformers*, offrant alors une alternative aux couches de convolution, ces dernières ayant déjà fait leurs preuves.
    Nous nous posons alors une simple question: _pourquoi devrions-nous utiliser des mécanismes basés sur l'attention en vision par ordinateur ?_

    Pour y répondre, nous allons nous intéresser au coût énergétique lié à l'entraînement de ces différentes architectures appliqué à la tâche de la *segmentation sémantique*, et verrons qu'il est même possible de les combiner. Nous détaillerons dans un premier temps le protocole mis en place permettant de comparer les entraînements, puis nous étudierons leur scalabilité sur plusieurs noeuds de calcul en utilisant *HPE MLDE*.

    (Enfin, si le temps le permet, nous étudierons la performance de MLDE comparé à une stack *Alpa + Jax + Ray* en terme d'efficacité énergétique)
  ],
)

// Content

= Introduction
#lorem(60)

== In this paper
#lorem(20)

=== Contributions
#lorem(40)

= Related Work
#lorem(500)
