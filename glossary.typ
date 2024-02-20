/* Glossary code by Hugo Cartigny (BlueskyFR) 🍉

👉 The glossary library contains 2 types of glossaries: terms and acronyms.
1. Terms: when referenced, simply links to glossary where full definition
   can be found;
2. Acronyms: when referenced the first time, the full name is displayed,
   followed by the abreviation in parentheses, while from the second time
   only the abreviation is printed.
In any case, the @abreviation can be customized per-instance by using the
@abreviation[override] Typst syntax; for example it is useful for plurals.

✨ The glossary displays its items using level 99 headings,
since it is not yet possible to create labels to normal text sections

⚠️ The glossary applies custom styling on lvl 99 headings, so make sure to avoid
overriding this style after enabling it! It is best to enable it after every other custom styling.

This global dictionnary holds the state for both the term and
acronys glossaries, so that we have a single source to query
when @referencing terms from the body of the document

TODO: explain better that italic is ignored + "s" alone in supplement is appended at the end directly

*/

#import "utils.typ": first-sentence

#let glossary = state("glossary", (:))

// Self note: globals work when using `import`, but not show rules, which need to
// be scoped using `show` or by passing doc in param, like in `display-glossary`
#let page-refs-color = rgb("#7630EA")

#let enable-glossary(doc) = {
  // Hide the numbering for level 99 titles
  show heading.where(level: 99): it => text(weight: "regular", it.body)
  
  // When a term is @referenced, query the glossary to display accordingly
  show ref: r => {
    locate(loc => {
      // The reference target is a label, and this label is the safe (escaped)
      // version of the term it refers
      let safe-label = str(r.target)
      // Search for all elements having this label attached
      let res = query(r.target, loc)
  
      // If the source exists (should always be the case since it includes the
      // current one) and the first occurrence is in the glossary (heading level 99)
      if res.len() > 0 and res.first().func() == heading and res.first().level == 99 {
        let glossary-entry = glossary.at(loc).at(safe-label)
  
        // Get the term from the glossary, or replace it by the user-specified 
        // supplement (override) if given
        let custom-term-supplied = r.citation.supplement != none
        let term = glossary-entry.term

        if custom-term-supplied {
          // If the supplement is only "s", then we append it to the term
          // It's a handy trick when writting!
          if r.citation.supplement == [s] {
            term += [s]
          } else {
            term = r.citation.supplement
          }
        }
        
        // If it is the first reference to the term, display its definition too
        link(res.first().location(), {

          // Print the full term name first only if it is an acronym, no custom
          // term (override) has been applied and it is the first reference to it
          if glossary-entry.is-acronym and not custom-term-supplied and glossary-entry.ref-locs.len() == 0 {
            let definition = glossary-entry.def

            // We want to extract the first sentence from the definition and display it.
            // For that, `definition` should either be a [ string ] or a sequence
            let first-sentence = first-sentence(definition)
            
            [*#first-sentence* (#term)]
          }
          else [*#term*]
        
        })
  
        // Add location to the term's ref list if the current page
        // is not already listed
        glossary.update(v => {
          // If this page is not in, push the loc in!
          if v.at(safe-label).ref-locs.all(l => l.page != loc.page()) {
            v.at(safe-label).ref-locs.push(
              // Current page loc
              loc.position()
            )
          }
          v
        })
      }
      else { r } // Otherwise just return the ref as it is
    })
  }

  doc
}

// Takes a scope (`section`) and transforms its term lists into glossary,
// by adding them to the global glossary state. The `acronym-mode` param
// controls whether the full definition is printed on first citation later.
#let display-glossary(section, acronym-mode: true, indent-defs: false) = {
  show terms: list => {
    let terms-grid = ()
    // Add terms to glossary
    for item in list.children {
      // A safe label generated from the term, to make it @able
      let safe-label = (
        item.term.text
          /// \s is whitespace; \W is non-word char
          // Trim spaces on both ends
          .trim(regex("\s"))
          // Replace spaces by "-"
          .replace(regex("\s"), "-")
          // Replace weird chars by nothing
          .replace(regex("[^\w-]"), "")
      )
      
      glossary.update(v => {
          v.insert(
            safe-label,
            (
              is-acronym: acronym-mode,
              term: item.term.text,
              // Holds the list of the locations referencing the term
              ref-locs: (),
              // The actual term definition
              def: item.description,
            )
          )
  
          // Return the new state with the added entry
          v
      })

      if indent-defs {
        // Term
        terms-grid.push([
          #set par(justify: false) // Don't justify the term title
          #heading(level: 99, numbering: "1")[*#item.term*]
          #label(safe-label)
        ])
  
        // Definition
        terms-grid.push([
          #item.description
          // Pages where the term is referenced
          #show: text.with(page-refs-color)
          #locate(loc => {
            glossary.final(loc).at(safe-label).ref-locs
              .map(l => link(l, str(l.page)))
              .join(", ")
          })
        ])
      
      } else [
        // Display items directly one by one since we don't need to build a grid
        // Use a level 99 title so it doesn't conflict with regular ones
        // and it can be refered to by @citations
        #heading(level: 99, numbering: "1")[
          *#item.term*:~~#item.description
          // Pages where the term is referenced
          #show: text.with(page-refs-color)
          #locate(loc => {
            glossary.final(loc).at(safe-label).ref-locs
              .map(l => link(l, str(l.page)))
              .join(", ")
          })
        ]
        #label(safe-label) \
      ]
    }

    if indent-defs {
      grid(
        columns: (1fr, 4fr),
        column-gutter: 2mm,
        row-gutter: 8mm,
        ..terms-grid
      )
    }
  
    // 🐛 Debug
    //[acronym-mode: #acronym-mode \ ]
    //glossary.display()
  }

  section
}

// ❤️ Aliases for user import
#let term-glossary(section, indent-defs: true) = {
  display-glossary(section, acronym-mode: false, indent-defs: indent-defs)
}
#let acronym-glossary(section, indent-defs: true) = {
  display-glossary(section, acronym-mode: true, indent-defs: indent-defs)
}