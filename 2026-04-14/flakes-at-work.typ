#import "@preview/touying:0.6.1": *
#import "slidetheme.typ"
#import emoji: *

#let palette = (
  rgb("#7287fd"), // lavender
  rgb("#209fb5"), // sapphire
  rgb("#40a02b"), // green
  rgb("#df8e1d"), // yellow
  rgb("#fe640b"), // peach
  rgb("#e64553"), // maroon
)
#let math-palette = palette.map(c => c.darken(20%))

#show raw.where(block: true): set text(size: 15pt)
#show raw: slidetheme.colorize-code(palette)
#show math.equation: it => slidetheme.colorize-math(math-palette, it)

#set text(font: "Fira Sans", weight: "light", size: 20pt)

#show arrow.t: set text(font: "Noto Color Emoji")
#show face.cool: set text(font: "Noto Color Emoji")
#show face.explode: set text(font: "Noto Color Emoji")
#show monkey.see: set text(font: "Noto Color Emoji")
#show skull: set text(font: "Noto Color Emoji")

#set list(tight: true)
#show list: it => pad(
  left: 0.65em,
  {
    set block(above: 0.65em)
    it
  },
)

#set footnote.entry(
  separator: line(
    length: 30%,
    stroke: 1pt + slidetheme.default-colors.primary-light,
  ),
)

#show link: set text(slidetheme.default-colors.primary-dark)
#show strong: it => text(fill: slidetheme.default-colors.secondary-light, it)

#show: slidetheme.otanix-theme.with(
  config-info(
    title: [Flakes at Work],
    subtitle: [How flakes can be utilized in a workplace environment],
    author: [Luukas Pörtfors],
    date: datetime(year: 2026, month: 4, day: 14),
    institution: [OtaNix ry #box(baseline: 0.15em, image("otanix.svg", height: 1em))],
  ),
)

#let title-slide = slidetheme.title-slide
#let slide = slidetheme.slide
#let focus-slide = slidetheme.focus-slide

#title-slide()

== Overview

=== Presentation goals
- The idea of this presentation is to showcase:
  - very practical things regarding flakes
  - parts of a flake-heavy workflow
  - useful in a company/large project where nix users are first-class citizens

== Flake components


#slide(align: top)[
  === Inputs
  - local directories
  - private git inputs
  - public git inputs
  - non-flakes
][
  === Outputs
  - packages
  - apps
  - formatters
  - checks
  - devShells
  - overlays
  - nixosModules
  - nixosConfigurations
  - templates
]

== The obvious: project devShells

#slide(composer: (2fr, 1fr))[
  The most obvious, immediate benefit of nix users being first-class citizens

  === Setting up development environment
  + Open project
  + Run `nix develop`
  + Start working
][
  #image("gymnastics.png")
]

== The obvious: nix builds are reproducible

#slide(composer: (2fr, 1fr))[
  Perhaps even more obvious

  === Building the project
  + Install nix
  + `nix build`

  Bonus: Cross-compilation is also #strike[trivial] much easier to setup with Nix
][
  #image("works-on-my-machine.jpg")
]

== Sharing shells with colleagues

#slide(composer: (2fr, 1fr))[
  ```
  > Colleague: hi, what tools do you use to do <thing>?
  > me: `nix develop <thing-shell>`
  > Colleague: this is the way.
  > me: this is the way.
  ```
][
  #image("this-is-the-way.jpg")
]

== Running the CI on any machine

#slide(composer: (3fr, 1fr))[
  - Anti-pattern: Developing against the CI
  - With nix, you can run the CI locally on your machine
  - `nix build` locally will do the exact same thing as `nix build` on the CI machine
    - this has the additional benefit of making the CI script trivial (install nix, run nix build)
  - `nix flake check` will run CI checks (fmt check, even NixOS integration tests #emoji.face.explode)
][
  #image("ci.png")
]

== Writing (internal) tools and scripts for everyone to use

#slide(composer: (2fr, 1fr))[
  Scenario: Developer from team A wants to use an internal tool from team B

  === With Nix (Team B creates flake app)
  + `nix run <team-b/repo>#tool`

  === Without Nix
  + clone repo
  + figure out how to build the tool
  + figure out what runtime dependencies are used
  + iterate 2 & 3
  + cry
][
  #image("cry.jpg")
]

== Enforcing company-wide standards with a nix library

- All company codebases can use unified components:
  - Formatters & Linters
  - Overlays
  - package generation functions
    - e.g. `buildCrate` that wraps Crane
  - could expose flake templates
- Can be maintained by the Nix gurus and used by everyone

== Getting started with Nix in CI

=== Action plan

+ Create a devshell, (CI = `nix develop` + normal CI) $<--$ This is already great!
+ Start running builds with `nix build`
+ Move CI scripts to flake checks and flake apps

#focus-slide[#link("https://github.com/lajp/bank-barcode/blob/main/flake.nix")[Example of a flake setup for Rust]]
