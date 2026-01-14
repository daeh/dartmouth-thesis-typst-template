//
// Dartmouth College Thesis Template in Typst
//

#import "dcthesis.typ": *

#let hyphenate = true // Set to false to disable hyphenation (useful for proofreading)

#show: dcthesis.with(
  title: [A Study in Typst Thesis Templates],
  author: [Author Name],
  degree: "Doctor of Philosophy",
  field: "Psychological and Brain Sciences",
  school: "Guarini School of Graduate and Advanced Studies",
  date: "December 2026",

  advisor: [Advisor One Name],
  examiner-1: [Advisor Two Name],
  examiner-2: [Advisor Three Name],
  examiner-3: [Advisor Four Name],
  dean: [F. Jon Kull, Ph.D.],
  dean-title: "Dean of the Guarini School of Graduate and Advanced Studies",

  // copyright: (year: 2026),  // Uncomment to add copyright page

  hyphenate: hyphenate,
)

// ============================================================================
// FRONT MATTER
// ============================================================================

#frontmatter[
  = Abstract

  Write your abstract here.

  = Preface

  Preface and Acknowledgments go here!

  // Table of Contents (automatic)
  #outline(
    title: "Contents",
    indent: auto,
    depth: 3, // Match LaTeX: chapters, sections, subsections (not subsubsections)
  )

  // List of Tables (optional)
  // #outline(
  //   title: "List of Tables",
  //   target: figure.where(kind: table),
  // )

  // List of Figures (optional)
  // #outline(
  //   title: "List of Figures",
  //   target: figure.where(kind: image),
  // )
]

// ============================================================================
// MAIN MATTER
// ============================================================================

#mainmatter[
  #include "sections/ch-1.typ"
  #include "sections/ch-2.typ"

  // ==========================================================================
  // APPENDICES
  // ==========================================================================

  #show: appendices // Switch to appendix numbering
  #include "sections/supp-1.typ"
]

// ============================================================================
// BACK MATTER
// ============================================================================

#backmatter[
  #bibliography("references.bib", style: "apa", title: "References")
]
