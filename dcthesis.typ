// ============================================================================
// DARTMOUTH THESIS TEMPLATE - dcthesis.typ
// ============================================================================
// Typst implementation of the Dartmouth PhD thesis template (dcthesis.cls)
// Conforming to Dartmouth Graduate School thesis guidelines
//
// Font: New Computer Modern (matches LaTeX Computer Modern default)
// Version: 1.0
// Date: 2026-01-11
// ============================================================================

// ----------------------------------------------------------------------------
// Line Height Calculation
// ----------------------------------------------------------------------------
// Typst 'leading' measures gap between lines (bottom edge to top edge).
// LaTeX 'baselineskip' measures baseline-to-baseline distance.
// Conversion formula: leading = baseline - (line-height-ratio × font-size)
//
// The line-height-ratio is font-specific and must be empirically tuned.
// Initial value for New Computer Modern: 0.65 (to be refined through comparison)
// ----------------------------------------------------------------------------

// Double-spacing ratio for body text
#let line-height-ratio = 0.8847

#let calc-leading(font-size, baseline) = {
  baseline - (line-height-ratio * font-size)
}

// ----------------------------------------------------------------------------
// State Variables for Headers
// ----------------------------------------------------------------------------
// Track current chapter and section names for fancyhdr-style headers

#let chapter-state = state("chapter", none)
#let section-state = state("section", none)

// Pending short title for next heading (consumed when heading is rendered)
#let pending-short-title = state("pending-short-title", none)

// Dictionary of short titles, keyed by heading body text
#let short-titles = state("short-titles", (:))

/// Sets a short title for page headers when the full heading is too long.
///
/// Place immediately before a heading to provide an abbreviated version
/// for the running header. The short title appears in the page header
/// while the full title appears in the document body.
///
/// #example(```
/// #short[Methods]
/// == Methodological Approaches to Investigating Complex Phenomena
/// ```)
///
/// - title (content, str): The abbreviated title for headers
///
/// -> none
#let short(title) = {
  pending-short-title.update(title)
}

/// Main Dartmouth thesis template function.
///
/// Applies complete thesis formatting conforming to Dartmouth Graduate School
/// guidelines. Includes page layout, typography, heading styles, title page
/// generation, and page numbering. Use with a show rule to format your document.
///
/// #example(```
/// #show: dcthesis.with(
///   title: [My Thesis Title],
///   author: "Jane Doe",
///   degree: "Doctor of Philosophy",
///   field: "Computer Science",
///   date: "June 2026",
///   advisor: [Prof. Smith],
///   examiner-1: [Prof. Jones],
///   examiner-2: [Prof. Brown],
///   examiner-3: [Prof. Wilson],
/// )
///
/// #frontmatter[
///   = Abstract
///   ...
/// ]
///
/// #mainmatter[
///   = Introduction
///   ...
/// ]
/// ```)
///
/// - title (content, str, none): Thesis title displayed on title page
/// - author (str, none): Author name for title page and PDF metadata
/// - degree (str): Degree name (default: "Doctor of Philosophy")
/// - field (str, none): Field of study
/// - date (str, none): Graduation date (e.g., "December 2026")
/// - school (str): Graduate school name
/// - university (str): University name
/// - location (str): University location
/// - advisor (content, str, none): Thesis advisor (committee chair)
/// - examiner-1 (content, str, none): Committee member 1
/// - examiner-2 (content, str, none): Committee member 2
/// - examiner-3 (content, str, none): Committee member 3
/// - dean (str): Dean name for signature line
/// - dean-title (str): Dean title for signature line
/// - variant (str): Title page variant: "standard", "engineering", or "mals"
/// - copyright (dictionary, none): Copyright info with `year` key; `name` defaults to author
/// - hyphenate (bool): Enable automatic hyphenation
/// - text-kwargs (dictionary): Additional arguments for `set text()`
/// - page-kwargs (dictionary): Additional arguments for `set page()`
/// - document-kwargs (dictionary): Additional arguments for `set document()`
/// - body (content): Document content
///
/// -> content
#let dcthesis(
  // === Document Metadata ===
  title: none,
  author: none,
  degree: "Doctor of Philosophy",
  field: none,
  date: none,
  // === Institution ===
  school: "Guarini School of Graduate and Advanced Studies",
  university: "Dartmouth College",
  location: "Hanover, New Hampshire",
  // === Examining Committee ===
  advisor: none,
  examiner-1: none,
  examiner-2: none,
  examiner-3: none,
  dean: "F. Jon Kull, Ph.D.",
  dean-title: "Dean of the Guarini School of Graduate and Advanced Studies",
  // === Title Page Variant ===
  // Options: "standard", "engineering", "mals"
  variant: "standard",
  // === Copyright Page ===
  // Set to (year: int, name: "string" or content) to include a copyright page
  copyright: none,
  // === Typography Options ===
  hyphenate: true, // Set to false to disable hyphenation (useful for proofreading)
  // === Advanced Overrides ===
  text-kwargs: (:), // Additional arguments passed to `set text()`
  page-kwargs: (:), // Additional arguments passed to `set page()`
  document-kwargs: (:), // Additional arguments passed to `set document()` (e.g., keywords, date)
  // === Document Body ===
  body,
) = {
  // ==========================================================================
  // DOCUMENT METADATA (PDF properties)
  // ==========================================================================
  // Visual fields (title, author) from first-level args
  // Additional metadata (keywords, date) via document-kwargs

  let doc-specs = (
    title: title,
    author: if author != none { (author,) } else { () },
    ..document-kwargs,
  )
  set document(..doc-specs)

  // ==========================================================================
  // FONT CONFIGURATION
  // ==========================================================================

  set text(
    font: "New Computer Modern",
    size: 12pt,
    top-edge: "cap-height",
    bottom-edge: "descender",
    lang: "en",
    region: "US",
    hyphenate: hyphenate,
    ..text-kwargs,
  )

  // Math font
  show math.equation: set text(
    font: "New Computer Modern Math",
  )

  // ==========================================================================
  // PAGE LAYOUT
  // ==========================================================================
  //
  // Why different top margins for title page vs other pages?
  // --------------------------------------------------------
  // LaTeX uses geometry{top=1.25in} uniformly, but actual content position differs:
  // - Title page (\thispagestyle{empty}): content starts at ~1in from top
  // - Regular pages: content starts at ~1.25in + headheight + headsep from top
  //
  // This happens because fancyhdr reserves header space (headheight=16pt + headsep)
  // on regular pages even when empty style is used elsewhere. The title page,
  // being inside the titlepage environment with empty style, doesn't have this
  // overhead applied the same way.
  //
  // In Typst, we must explicitly use different margins to match this behavior:
  // - Title page: top: 1in (via page() override)
  // - Regular pages: top: 1.25in + 8pt (accounts for header space difference)
  //
  // Alternative approaches considered:
  // - Uniform margins with phantom header on title page: adds complexity
  // - Adjusting header-ascent to absorb the difference: harder to reason about
  // The explicit different-margins approach is clearest for maintenance.

  set page(
    paper: "us-letter",
    margin: (
      left: 1.5in, // Binding requirement
      top: 1.25in + 8pt, // See comment above for why this differs from title page
      bottom: 1in,
      right: 1in,
    ),
    numbering: none, // Controlled per section
    header: none, // Set dynamically
    footer: none, // Set dynamically
    // header-ascent controls how far header is raised into margin (higher = further from body)
    header-ascent: 16pt + 8pt, // NB use this to control the position of the line after the header. use inset to control the position of the text itself.
    // LaTeX footer position: footskip (~0.25in) from body bottom
    footer-descent: 0.35in, // NB use this to control the position of the footer text
    ..page-kwargs,
  )

  // ==========================================================================
  // PARAGRAPH SETTINGS
  // ==========================================================================

  set par(
    first-line-indent: 1.5em, // Matches LaTeX book class default (18pt at 12pt)
    leading: calc-leading(12pt, 24pt), // Double spacing (baselineskip = 24pt)
    spacing: calc-leading(12pt, 24pt),
    justify: true,
    linebreaks: "optimized",
    justification-limits: (
      // for typst 0.14.0 and later
      spacing: (min: 80%, max: 100%), // The spacing entry defines how much the width of spaces between words may be adjusted.
      tracking: (min: -0.009em, max: 0.02em), // The tracking entry defines how much the spacing between letters may be adjusted.
    ),
  )

  // Enable heading numbering (required for counter(heading) to work properly)
  set heading(numbering: "1.1.1.1")

  // ==========================================================================
  // HEADING STYLES
  // ==========================================================================

  // Chapter Headings (Level 1)
  // Matches dcthesis.cls lines 220-231 (titlesec [display] configuration)
  // LaTeX font sizes at 12pt: \LARGE=20pt, \Huge=25pt
  // titlesec [display] default spacing: 50pt before-sep, 40pt after-sep
  show heading.where(level: 1): it => {
    // Reset section state when entering new chapter
    section-state.update(none)
    // Update chapter state for headers (LaTeX \leftmark) - placed after content
    // so counter is read at the correct time

    // LaTeX book class forces chapters to start on new pages (\clearpage)
    pagebreak(weak: true)

    // titlesec default before-sep: 50pt from top margin to first rule
    // Must use v() because block(above:) collapses at page top
    v(58.5pt)

    align(
      center,
      block(
        above: 0pt,
        below: 50.5pt,
        width: 100%,
        breakable: false,
        stack(
          dir: ttb,
          spacing: 12pt, // 1pc gap from bottom rule to title (matches LaTeX \vspace{1pc})
          // Bordered block with top/bottom rules containing chapter label
          // Structure matches LaTeX: rule -> 10pt -> text -> 12pt (sep) -> rule
          block(
            above: 0pt,
            below: 0pt,
            width: 100%,
            stroke: (top: 1pt, bottom: 1pt),
            inset: (top: 25pt, bottom: 25pt),
            {
              // Use baseline bottom-edge so inset measures from baseline to stroke
              // (matches LaTeX where sep is from baseline to next rule)
              set text(top-edge: "cap-height", bottom-edge: "baseline")
              text(
                size: 20pt,
                font: "New Computer Modern Sans",
                weight: "regular",
              )[
                #if type(it.numbering) == function {
                  // Custom numbering (appendices) - numbering function returns full label
                  counter(heading).display(it.numbering)
                } else {
                  // Standard numbering - prepend "Chapter"
                  [Chapter #counter(heading).display("1")]
                }
              ]
            },
          ),
          v(30pt),
          // Chapter title: \Huge\bfseries = 25pt bold
          text(size: 25pt, weight: "bold")[#it.body],
        ),
      ),
    )

    // Update chapter state for headers (LaTeX \leftmark)
    // Format: "CHAPTER N.  TITLE" or "SUPPLEMENT A.  TITLE" for appendices
    chapter-state.update(
      if type(it.numbering) == function {
        [#upper(counter(heading).display(it.numbering))#h(1em)#upper(it.body)]
      } else {
        [CHAPTER #counter(heading).display("1")#h(1em)#upper(it.body)]
      },
    )
  }

  // Section Headings (Level 2)
  // Matches dcthesis.cls lines 233-240 (titlesec [frame] style)
  // LaTeX font sizes at 12pt: \large=14pt, \Large=17pt
  // Frame stroke uses \fboxrule default = 0.4pt
  show heading.where(level: 2): it => {
    // Check for pending short title and consume it
    context {
      let short = pending-short-title.get()
      if short != none {
        pending-short-title.update(none)
        // Store in dictionary for header lookup
        let key = repr(it.body)
        short-titles.update(d => {
          d.insert(key, short)
          d
        })
      }
      // Store short title (or full title) for header - keyed by heading body
      let header-title = if short != none { upper(short) } else { upper(it.body) }

      // Label text: \sffamily\large = sans-serif 14pt, with \enspace (0.5em) padding
      let label = text(
        font: "New Computer Modern Sans",
        size: 14pt,
        weight: "regular",
      )[#h(0.5em)#if type(it.numbering) == function {
          // Appendix mode - just show number (e.g., "A.1")
          counter(heading).display(it.numbering)
        } else {
          // Standard mode - "Section 1.1"
          [Section #counter(heading).display("1.1")]
        }#h(0.5em)]

      // Title text: \Large\bfseries = 17pt bold, centered
      let title = text(
        size: 17pt,
        weight: "bold",
      )[#it.body]

      // Frame parameters
      let stroke-width = 0.4pt // \fboxrule default
      let frame-inset = 8pt // titlesec sep parameter
      let label-inset = 0.5em // Horizontal offset from frame edge

      block(above: 1.6em, below: 1.3em, width: 100%)[
        // The frame with title content inside
        #rect(
          width: 100%,
          stroke: stroke-width,
          inset: (
            left: frame-inset,
            right: frame-inset,
            // Extra top padding to make room for the label on the border
            top: frame-inset + 14pt,
            bottom: frame-inset + 9pt,
          ),
        )[
          #align(center, title)
        ]

        // Overlay the label on top border (positioned from top-left of the block)
        // dy centers the label vertically on the border line
        #place(
          top + left,
          dx: label-inset,
          dy: -0.5em,
        )[
          // White background breaks the border line behind the text
          #box(
            fill: white,
            inset: (x: 1pt, y: 3pt),
          )[#label]
        ]
      ]

      // Update section state for headers (LaTeX \rightmark)
      // Uses short title if provided, otherwise full title
      let header-num = if type(it.numbering) == function {
        counter(heading).display(it.numbering)
      } else {
        counter(heading).display("1.1")
      }
      section-state.update[#header-num#h(1em)#header-title]
    }
  }

  // Subsection Headings (Level 3)
  // Matches dcthesis.cls lines 242-247
  show heading.where(level: 3): it => {
    let num = if type(it.numbering) == function {
      counter(heading).display(it.numbering)
    } else {
      counter(heading).display("1.1.1")
    }
    block(
      above: 2.5em,
      below: 0.67em,
      width: 100%,
      stroke: (bottom: 0.4pt),
      inset: (bottom: 0.42em),
    )[
      #text(weight: "bold")[
        #num. #it.body
      ]
    ]
  }

  // Subsubsection Headings (Level 4)
  // Matches dcthesis.cls lines 249-254 (run-in style)
  // Uses block() to prevent first-line-indent on following paragraph (from CogSci pattern)
  show heading.where(level: 4): it => {
    v(2.5em, weak: true)
    (
      block(above: 0pt, below: 0pt)
        + text(
          weight: "bold",
          style: "italic",
          it.body + [. ] + h(0.5em, weak: false),
        )
    )
  }

  // ==========================================================================
  // TITLE PAGE
  // ==========================================================================

  // Signature line helper (2.66667in width)
  // Matches LaTeX \@signatureline
  // Extra 1pt compensates for minipage [t] alignment differences
  let signature-line(name) = {
    box(width: 2.66667in)[
      #v(0.3in + 1pt)
      #line(length: 2.66667in, stroke: 0.4pt)
      #name
    ]
  }

  // Long signature line for dean (5.5in width)
  // Matches LaTeX \@longsignatureline
  let long-signature-line(content) = {
    box(width: 5.5in)[
      #v(0.3in + 1pt)
      #line(length: 2.66667in, stroke: 0.4pt)
      #content
    ]
  }

  // Generate title page based on variant
  if variant == "standard" {
    // LaTeX \bigbreak is approximately 12pt with some glue
    let bigbreak = v(12pt, weak: false)

    // Title page with isolated margins (main.tex uses \newgeometry{top=1in})
    // Using page() function to scope margins to just this page
    page(
      margin: (
        left: 1.5in,
        top: 1in,
        bottom: 1in,
        right: 1in,
      ),
    )[
      // Single spacing for title page
      #set par(
        leading: calc-leading(12pt, 14.5pt),
        spacing: calc-leading(12pt, 14.5pt),
        first-line-indent: 0pt,
      )

      #align(center)[
        // LaTeX \begin{center} adds ~\topsep before first element
        #v(4pt)

        // Title: \bfseries \MakeUppercase{\@title}
        #text(weight: "bold", upper(title))

        #bigbreak

        // Submission text
        A Thesis \
        Submitted to the Faculty \
        in partial fulfillment of the requirements for the \
        degree of

        #bigbreak

        #degree

        #bigbreak

        in

        #bigbreak

        #field

        #bigbreak

        by #author

        #bigbreak

        #school \
        #university \
        #location

        #bigbreak

        #date

        // \vfill - inside the center environment in LaTeX
        #v(1fr)

        // tabular[t]{cc} - Tuned grid with horizontal offsets to match LaTeX
        #grid(
          columns: (3in, 2.66667in),
          column-gutter: 0pt,
          row-gutter: 1.4pt,
          align: (center, left),
          // Row 1: "Examining Committee:" with 42.55pt left inset to match LaTeX x=378.55
          [], box(width: 2.66667in, inset: (left: 42.55pt))[Examining Committee:],
          // Row 2: phantom underline | Advisor signature with +7pt horizontal offset
          hide(box(width: 3in)[#line(length: 3in)]),
          box(width: 2.66667in + 7pt, inset: (left: 7pt))[#signature-line([#advisor, Chair])],
          // Rows 3-5: empty | Member signatures with +7pt horizontal offset
          [], box(width: 2.66667in + 7pt, inset: (left: 7pt))[#signature-line(examiner-1)],
          [], box(width: 2.66667in + 7pt, inset: (left: 7pt))[#signature-line(examiner-2)],
          [], box(width: 2.66667in + 7pt, inset: (left: 7pt))[#signature-line(examiner-3)],
          // Dean: spans both columns, LEFT-aligned with -6pt horizontal offset
          grid.cell(colspan: 2, align: left)[#h(-6pt)#long-signature-line([#dean \ #dean-title])],
        )

        // LaTeX tabular/center adds ~10pt internal spacing after content
        // This reduces v(1fr) above and pushes committee up
        #v(10.3pt)
      ]
    ]
  }

  // LaTeX dcthesis.cls creates a blank page after title page
  // (from \null\vfil in maketitle, even when no copyright page)
  // This is the back side of the title page when printed
  pagebreak()
  pagebreak()

  // Copyright page (if requested)
  // Normalize copyright: none, false, or empty dict all mean "no copyright page"
  // If name is omitted, defaults to author argument
  let copyright-info = if copyright == none or copyright == false or copyright == (:) {
    none
  } else if type(copyright) == dictionary and "year" in copyright {
    (
      year: copyright.year,
      name: copyright.at("name", default: author),
    )
  } else {
    assert(
      false,
      message: "copyright must be (year: int) or (year: int, name: \"string\"), got: " + repr(copyright),
    )
  }

  if copyright-info != none {
    v(1fr)
    align(center)[
      Copyright by \
      #copyright-info.name \
      #copyright-info.year
    ]
    v(1fr)
    pagebreak()
  }

  // ==========================================================================
  // DOCUMENT BODY
  // ==========================================================================

  body
}

// ----------------------------------------------------------------------------
// Document Structure Functions
// ----------------------------------------------------------------------------

/// Wraps front matter content with Roman numeral page numbering.
///
/// Front matter includes abstract, preface, acknowledgments, table of contents,
/// and lists of figures/tables. Pages are numbered with lowercase Roman numerals
/// starting at ii (title page counts as i). Level 1 headings are unnumbered.
///
/// #example(```
/// #frontmatter[
///   = Abstract
///   This thesis investigates...
///
///   = Preface
///   I would like to thank...
///
///   #outline(title: "Contents")
/// ]
/// ```)
///
/// - body (content): Front matter content
///
/// -> content
#let frontmatter(body) = {
  set page(
    header: none,
    footer: align(center, context counter(page).display("i")),
    numbering: "i",
  )

  // Disable heading numbering for front matter
  set heading(numbering: none)

  // Unnumbered chapter headings for front matter (matches LaTeX \chapter*)
  // LaTeX \chapter* produces a left-aligned bold title (book class default)
  // LaTeX yMin ~188pt, need v() to position title correctly
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    v(90pt) // Tuned to match LaTeX \chapter* vertical position

    block(
      above: 0pt,
      below: 50.5pt,
      text(size: 25pt, weight: "bold")[#it.body],
    )
  }

  counter(page).update(2) // Start at ii (title page is i)

  body
}

/// Wraps main thesis content with Arabic page numbering and running headers.
///
/// Main matter contains the numbered chapters of the thesis. Pages are numbered
/// with Arabic numerals starting at 1. Running headers display chapter and
/// section titles in small caps. Chapter pages have no header (plain style).
///
/// Use `#show: appendices` within mainmatter to switch to appendix numbering.
///
/// #example(```
/// #mainmatter[
///   = Introduction
///   This chapter introduces...
///
///   == Background
///   Previous work has shown...
///
///   = Methods
///   We employed the following methods...
///
///   #show: appendices
///   = Supplementary Materials
///   Additional data...
/// ]
/// ```)
///
/// - body (content): Main thesis content (chapters and appendices)
///
/// -> content
#let mainmatter(body) = {
  set page(
    header: context {
      // LaTeX book class uses \thispagestyle{plain} on chapter pages
      // (no header, just footer). Check if this specific page has a chapter heading.
      let dominated-headings = query(heading.where(level: 1)).filter(h => h.location().page() == here().page())
      if dominated-headings.len() > 0 {
        return none
      }

      // Get chapter from state
      let chap = chapter-state.get()

      // Query for first section on this page (like LaTeX \rightmark)
      let sections-on-page = query(heading.where(level: 2)).filter(h => h.location().page() == here().page())
      let sect = if sections-on-page.len() > 0 {
        let s = sections-on-page.first()
        let nums = counter(heading).at(s.location())
        let num = nums.slice(0, calc.min(2, nums.len())).map(str).join(".")
        // Check for short title in dictionary
        let key = repr(s.body)
        let shorts = short-titles.get()
        let title = if key in shorts { upper(shorts.at(key)) } else { upper(s.body) }
        [#num#h(1em)#title]
      } else {
        section-state.get()
      }

      // Build header content
      // Left: \rightmark (section) - "N.N  TITLE" in small caps
      // Right: \leftmark (chapter) - "CHAPTER N.  TITLE" in small caps (only if no section)
      let left-mark = if sect != none {
        smallcaps[#sect]
      } else { [] }

      // Show chapter only if no section (to reduce overlap)
      let right-mark = if sect == none and chap != none {
        smallcaps[#chap]
      } else { [] }

      // Header with rule (matches \headrulewidth{.1pt})
      // Font: \sffamily\sc = sans-serif small caps, normal size (12pt)
      // Use place() to absolutely position left/right marks - avoids wrapping issues
      block(
        width: 100%,
        height: 1em,
        stroke: (bottom: 0.1pt),
        inset: (bottom: 2pt),
      )[
        #set text(font: "New Computer Modern Sans", size: 12pt)
        #place(left + horizon)[#left-mark]
        #place(right + horizon)[#right-mark]
      ]
    },
    footer: align(center, context counter(page).display("1")),
    numbering: "1",
  )

  counter(page).update(1) // Reset to 1

  body
}

/// Wraps back matter content with continued page numbering and simplified headers.
///
/// Back matter typically contains the bibliography and any additional references.
/// Page numbering continues from main matter. Headers show only the chapter title
/// (right-aligned) without section information. Level 1 headings are unnumbered.
///
/// #example(```
/// #backmatter[
///   #bibliography("references.bib", style: "apa", title: "References")
/// ]
/// ```)
///
/// - body (content): Back matter content (bibliography, indices)
///
/// -> content
#let backmatter(body) = {
  set page(
    header: context {
      // LaTeX book class uses \thispagestyle{plain} on chapter pages
      let chapter-on-page = query(heading.where(level: 1)).filter(h => h.location().page() == here().page())
      if chapter-on-page.len() > 0 {
        return none
      }

      let chap = chapter-state.get()
      if chap == none {
        return none
      }

      let right-mark = smallcaps[#chap]

      // Header with rule (matches \headrulewidth{.1pt})
      // Use place() for consistent positioning
      block(
        width: 100%,
        height: 1em,
        stroke: (bottom: 0.1pt),
        inset: (bottom: 4pt),
      )[
        #set text(font: "New Computer Modern Sans", size: 12pt)
        #place(right + horizon)[#right-mark]
      ]
    },
    footer: align(center, context counter(page).display("1")),
    numbering: "1",
  )

  // Disable heading numbering for back matter (like frontmatter)
  set heading(numbering: none)

  // Unnumbered chapter headings for back matter (matches LaTeX \chapter*)
  // Updates chapter-state to just the title (no "CHAPTER N" prefix)
  let backmatter-heading(it) = {
    // Update chapter state to just the uppercased title
    chapter-state.update(upper(it.body))

    pagebreak(weak: true)
    v(90pt) // Match frontmatter positioning

    block(
      above: 0pt,
      below: 50.5pt,
      text(size: 25pt, weight: "bold")[#it.body],
    )
  }

  show heading.where(level: 1): backmatter-heading

  // Apply same heading style to bibliography's internal heading
  show bibliography: it => {
    show heading.where(level: 1): backmatter-heading
    it
  }

  // Continue page numbering from mainmatter
  body
}

/// Switches heading numbering to appendix style (A, B, C...).
///
/// Use within mainmatter to mark the transition from numbered chapters to
/// lettered appendices. Chapters become "Appendix A", "Appendix B", etc.
/// Sections within appendices are numbered as A.1, A.2, B.1, etc.
///
/// #example(```
/// #mainmatter[
///   = Introduction
///   Main chapter content...
///
///   #show: appendices
///
///   = Supplementary Data
///   This becomes "Appendix A"...
///
///   = Code Listings
///   This becomes "Appendix B"...
/// ]
/// ```)
///
/// - body (content): Appendix content
///
/// -> content
#let appendices(body) = {
  counter(heading).update(0)
  counter("appendices").update(1)

  set heading(
    numbering: (..nums) => {
      let vals = nums.pos()
      let value = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".at(vals.at(0) - 1)
      if vals.len() == 1 {
        return "Appendix " + value
      } else {
        return value + "." + nums.pos().slice(1).map(str).join(".")
      }
    },
  )
  [#pagebreak() #body]
}
