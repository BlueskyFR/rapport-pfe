// Get the sequence type this way since it is not freely available in the public Typst API
// (used later, just getting it once here)
#let sequence-type = [a *b*].func()
#let space-type = [ ].func()

#let first-non-italic-sentence-from-seq(seq) = {
  let first-sentence = []

  for content in seq.children {
    // If it is text, search for "." and split on it
    if content.func() == text and "." in content.text {
      first-sentence += content.text.split(".").first()
      break
    } else if content.func() != emph {
      // Else just add it to the current sentence,
      // but skip italic (emph) blocks as they may contain term translations

      // Also skip content if it is empty text
      let zz = content.func()
      if content.func() == space-type {
        continue
      }
      
      first-sentence += content
    }
  }

  return first-sentence
}

#let first-sentence(content) = {
  let content-type = content.func()
  
  if content-type == text {
    return content.text.split(".").first()
  }
  else if content-type == sequence-type {
    return first-non-italic-sentence-from-seq(content)
  }
  else {
    panic("The passed content should be either text or a sequence!")
  }
}