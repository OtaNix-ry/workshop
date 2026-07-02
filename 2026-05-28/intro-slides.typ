// Instructions:
// 0. enter the top level nix shell
// 1. run `typst-watch 2026-02-25/intro-slides.typ`

#import "@preview/touying:0.6.1": *
#import "slidetheme.typ"
#import "@preview/tiaoma:0.2.1": qrcode

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
    title: [Nix meetup \@ Monad],
    author: [OtaNix ry & Monad Oy],
    date: datetime(year: 2026, month: 5, day: 28),
    //institution: [OtaNix ry],
  ),
)

#let title-slide = slidetheme.title-slide
#let slide = slidetheme.slide
#let focus-slide = slidetheme.focus-slide

#title-slide()

== Meetup outline

#grid(
  columns: (1fr, 3fr, 1fr),
  row-gutter: 4%,
  [1830-1845], [Welcoming words], [Luukas & Santeri],
  [1845-1855], [Nix -- A solution with problems], [Matias],
  [1900-1910], [Project showcase -- llm-jail], [Luukas],
  [1910-1920], [Current state of Nixpkgs CUDA (Infra)], [\@SomeoneSerge],
  [1920-1930], [Configuration with wrappers], [Roy],
  [\*], [Networking], [Everyone],
)

#focus-slide[= Enjoy!]
