// Instructions:
// 0. enter the top level nix shell
// 1. run `typst-watch intro-slides.typ`

#import "@preview/touying:0.5.5": *
#import "slidetheme.typ"
#import "@preview/note-me:0.2.1": *
#import "@preview/fontawesome:0.4.0": *
#import "@preview/tiaoma:0.2.1": qrcode
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

#show raw: slidetheme.colorize-code(palette)
#show math.equation: it => slidetheme.colorize-math(math-palette, it)

// #set raw(syntaxes: "Lean4.sublime-syntax", theme: "Catppuccin Latte.tmTheme")
#set text(font: "Fira Sans", weight: "light", size: 20pt)

// TODO how to set emoji font for all emojis?
#show finger.front: set text(font: "Noto Emoji")
#show snowflake: set text(font: "Noto Emoji")
#show package: set text(font: "Noto Emoji")
#show whale: set text(font: "Noto Emoji")
#show book: set text(font: "Noto Emoji")

#let bullets = (snowflake,)
// MEGATUNKKAUS
#set list(
  marker: n => {
    let bullet = text(
      size: 0.65em,
      bullets.at(calc.rem-euclid(n, bullets.len())),
    )
    style(styles => place(dx: -measure(bullet, styles).width - 0em, bullet))
  },
  indent: 0.65em,
  tight: true,
)
#show list: it => pad(
  left: 0.65em,
  {
    set block(above: 0.65em)
    // set list(indent: 0em) // override indent from first level lists
    it
  },
)

#set footnote.entry(
  separator: line(
    length: 30%,
    stroke: 1pt + slidetheme.default-colors.primary-light,
  ),
)
#let github = fa-icon("github")

// #show raw: it => box(
//   fill: rgb("#eff1f5"),
//   inset: 8pt,
//   radius: 12pt,
//   text(fill: rgb("#4c4f69"), it)
// )

#show link: set text(slidetheme.default-colors.primary-dark)

#let s = slidetheme.register(
  footer: link("https://github.com/OtaNix-ry/workshop/blob/" + sys.inputs.rev + "/2025-01-22/slides/intro-slides.typ")[Presentation source code],
)
#let s = (s.methods.info)(
  self: s,
  title: [
    Nix workshop
  ],
  subtitle: [OtaNix ry #box(baseline: 0.15em, image("otanix.svg", height: 1em))],
  author: [Luukas Pörtfors],
  date: datetime(year: 2025, month: 1, day: 22),
  institution: [Aalto University],
)
#let (init, slides, touying-outline, alert, speaker-note) = utils.methods(s)
#show: init

#show strong: alert

// #let (slide, empty-slide, title-slide, new-section-slide, focus-slide, custom-slide) = utils.slides(s)
#show: slides


// Presentation starts

== Workshop outline

#grid(
  columns: (1fr, 3fr, 1fr),
  row-gutter: 4%,
  [1500-1505], [Welcoming words], [Luukas],
  [1505-1510], [What is OtaNix ry?], [Luukas],
  [1510-1520], [What is Nix?], [Matias],
  [1520-1545], [Demo: Home-manager on Ubuntu], [Niklas and Joonas],
  [1545-1800], [Freeform hacking], [Everyone],
)

== What is OtaNix?

#grid(
  columns: (2fr, 1fr),
  [
    - A registered student association under AYY
    - Established in late 2024
    - We currently have $x$ members
    - Our goal is to unite people interested in Nix and NixOS
      - Achieved via events like this one
    - We also have a Telegram channel
  ],
  [
    #box(fill: white, inset: 1em)[#qrcode(
        "https://t.me/+CdoHb3N7" + "_hI1MzA8",
        options: (
          scale: 6.0,
          bg-color: white,
        ),
      )#align(center)[#text(black)[OtaNix ry Telegram]]]
  ],
)
