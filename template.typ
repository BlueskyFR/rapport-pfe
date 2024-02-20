// Ensimag template by Hugo Cartigny 🍉,
// inspired from the LaTeX original version (available on the intranet)

#let PFE(
  title: "",
  subtitle: "",

  author: "",
  year-and-option: [ 3#super[ème] année -- Option ISI ],
  enterprise: (
    name: "NOM ENTREPRISE",
    logo: none,
    address: (name: "", line1: "", line2: "")
  ),
  internship-supervisor: "",
  school-tutor: "",
  supervisors: (),
  dates: (from: "", to: ""),

  abstract: [],
  acknowledgements: [],
  body,
) = {
  // Set the document's basic properties.
  set document(title: title, author: author)
  set page(numbering: "1", number-align: center) // , margin: (inside: 3.2cm, outside: 2.5cm)
  //set text(font: "Source Sans Pro", lang: "fr")
  set text(font: "New Computer Modern", size: 12pt, lang: "fr")

  //show heading.where(level: 4): it => text(weight: "bold", it.body + [AAA.])

  // Only underline when link points towards a string (url)
  show link: it => if type(it.dest) == "string" { underline[#it] } else { it }


  // ### Title page ###
  // Enterprise + Ensimag logos
  if enterprise.logo != none {
    place(top + left, image(enterprise.logo, height: 8%))
  }
  place(top + right, pad(top: 1mm, image("assets/logo-ensimag.png", height: 8%)))
  
  v(10%)

  // School name
  align(center, [
    Grenoble INP -- ENSIMAG \
    École Nationale Supérieure d'Informatique et de Mathématiques Appliquées
  ])

  // Main content
  align(center + horizon, [
    #text(20pt, [ Rapport de projet de fin d'études ])

    #v(1cm)
    Effectué chez #enterprise.name

    #v(2cm)

    // Main title
    #rect(
      stroke: 1pt + black,
      width: 100%,
      outset: 4pt,
      text(22pt, title)
    )

    // Subtitle
    #v(.5cm)
    _#subtitle;_

    // Student/Author
    #v(2cm)
    #author \
    #year-and-option

    #dates.from -- #dates.to

    // Footer
    #v(4cm)
    #grid(
      columns: (1fr, 1fr),
      align(left, [
        *#enterprise.address.name* \
        #enterprise.address.line1 \
        #enterprise.address.line2
      ]),
      
      align(right, block(
        align(left, [
          *Responsable de stage* \
          ~~~#internship-supervisor

          *Tuteur de l'école* \
          ~~~#school-tutor
        ])
      )),
    )
    
  ])
  
  pagebreak(to: "odd")

  // ### Abstract page ###
  set par(justify: true)

  v(1fr)
  align(
    center,
    heading(
      outlined: false, numbering: none,
      text(0.85em)[Résumé]
    )
  )
  abstract
  v(1.618fr)
  pagebreak()

  // ### Acknowledgements page ###
  v(1fr)
  align(
    center,
    heading(
      outlined: false, numbering: none,
      text(0.85em)[Remerciements]
    )
  )
  acknowledgements
  v(1.618fr)
  pagebreak()

  // ### Table of contents ###
  outline(depth: 2, indent: true)
  pagebreak()


  // ### Main body ###

  body
}