= Citations and References

This chapter demonstrates how to use citations in your thesis. The bibliography entries are defined in `references.bib` and rendered at the end of the document.

== Bibliography Configuration

This template uses the APA citation style with a single bibliography at the end of the document. You can change the style by passing a different builtin style name to the `bibliography()` function in `main.typ`. You can also use custom CSL (Citation Style Language) files. See the Typst documentation for more information.

If you prefer separate bibliographies at the end of each chapter, use the #link("https://typst.app/universe/package/alexandria/", [alexandria]) package.

The Typst bibliography function use Hayagriva as its backend. References can be passed as a path to a BibLaTeX `.bib` file or a Hayagriva `.yaml`/`.yml` file.

=== Parenthetical Citations

A parenthetical citation places the full reference in parentheses. Write the citation key directly:

- `@shepard1987` produces: @shepard1987
- `@fodor1988` produces: @fodor1988

=== Narrative Citations

For narrative citations where the author name is part of the sentence, use the `cite` function with `form: "prose"`:

- `#cite(<heidersimmel1944>, form: "prose")` produces: #cite(<heidersimmel1944>, form: "prose")

For example: #cite(<heidersimmel1944>, form: "prose") demonstrated that observers attribute intentions to geometric shapes.

=== Multiple Citations

Multiple works can be cited together by listing them consecutively:

- `@fodor1988 @moggi1991` produces: @fodor1988 @moggi1991

=== Specific Locators

To cite a specific page, chapter, or section, add the locator after a comma:

- `@shepard1987[p.~1320]` produces: @shepard1987[p.~1320]

== Tables, Figures, and Data

This section demonstrates how to include tables, figures, and dynamically loaded data in your thesis.

=== Reading External Data

Typst can read values from external files, which is useful for reporting statistics that may change as you refine your analysis. For example, the participant count can be stored in a separate file and inserted into the text.

#let n-participants = read("../data/participants.txt").trim()

In our study, #emph[n] = #n-participants participants completed the experimental protocol. This value is read from `data/participants.txt`, so updating that file automatically updates the manuscript.

=== Tables

Tables are created using the `table` function and wrapped in `figure` for captioning and cross-referencing.

#figure(
  table(
    columns: 4,
    align: (left, center, center, center),
    table.header([*Condition*], [*Mean*], [*SD*], [*_n_*]),
    [Control], [2.34], [0.89], [14],
    [Treatment A], [3.67], [1.12], [15],
    [Treatment B], [4.21], [0.95], [13],
  ),
  caption: [Descriptive statistics by experimental condition.],
) <tab:descriptives>

As shown in @tab:descriptives, Treatment B produced the highest mean response. Tables can be cross-referenced using their label (e.g., `@tab:descriptives`).

=== Figures

Figures are inserted using the `image` function, also wrapped in `figure` for captioning.

#figure(
  rect(
    width: 80%,
    height: 2in,
    fill: luma(95%),
    stroke: 0.5pt,
    align(center + horizon)[
      _Placeholder for figure_ \
      Replace with: `image("figures/your-image.png")`
    ],
  ),
  kind: image,
  caption: [Example figure placeholder. Replace with actual image using `image("path/to/file.png")`.],
) <fig:example>

@fig:example shows a placeholder that can be replaced with an actual image. Supported formats include PNG, JPEG, SVG, and PDF.

To insert an actual image:

```typst
#figure(
  image("figures/results.png", width: 80%),
  caption: [Experimental results across conditions.],
) <fig:results>
```
