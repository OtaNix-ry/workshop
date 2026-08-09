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
    title: [Nix Workshop -- PGP, YubiKey, and NixOS],
    author: [Luukas Pörtfors],
    date: datetime(year: 2026, month: 8, day: 10),
    institution: [OtaNix ry #box(baseline: 0.15em, image("otanix.svg", height: 1em))],
  ),
)

#let title-slide = slidetheme.title-slide
#let slide = slidetheme.slide
#let focus-slide = slidetheme.focus-slide

#title-slide()

== Workshop outline

// Fill in the schedule rows by hand.
#grid(
  columns: (1fr, 3fr, 1fr),
  row-gutter: 4%,
  [1900], [], [],
  [1800], [Food #emoji.pizza], [Everyone],
)

== What is OtaNix?

#grid(
  columns: (2fr, 1fr),
  [
    - A student association under AYY
      - The Nix user group of Aalto
    - Our goal is to bring together people interested in Nix and NixOS
    - We organize workshops and meetups
    - Join our Telegram channel for announcements and discussion
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

#focus-slide[= Enjoy!]
