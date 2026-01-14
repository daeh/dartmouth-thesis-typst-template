#import "dcthesis.typ": *

#show: dcthesis.with(
  title: [Pretty Okay: A summary of technological methods for determining the veracity of certain obnoxious phrases],
  author: "The Myth",
  degree: "Doctor of Philosophy",
  field: "Quantitative Biomedical Sciences",
  school: "Guarini School of Graduate and Advanced Studies",
  date: "December 2026",

  advisor: [LGF],
  examiner-1: [The Mustache],
  examiner-2: [The Big Cheese],
  examiner-3: "Totally Real Subfield",
  dean: [F. Jon Kull, Ph.D.],
  dean-title: "Dean of the Guarini School of Graduate and Advanced Studies",

  // copyright: (year: 2026, name: "Your Name"),  // Uncomment to add copyright page
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

// Back matter
#backmatter[
  #bibliography("references.bib", style: "apa", title: "References")
]
