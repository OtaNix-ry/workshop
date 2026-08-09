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
    title: [Pretty Good Privacy (PGP)],
    subtitle: [What is PGP and how to use it],
    author: [Luukas Pörtfors],
    date: datetime(year: 2026, month: 8, day: 10),
    institution: [OtaNix ry #box(baseline: 0.15em, image("otanix.svg", height: 1em))],
  ),
)

#let title-slide = slidetheme.title-slide
#let slide = slidetheme.slide
#let focus-slide = slidetheme.focus-slide

#title-slide()

#slide[
  #quote(
    block: true,
    attribution: [Bruce Schneier],
  )[PGP is the closest you're likely to get to military-grade encryption.]
]


== Overview

+ Symmetric vs. Asymmetric crypto
+ Keys, keypairs, and subkeys
+ Algorithms
+ PGP vs. GPG
+ Example: Using GPG
+ Hardware keys


== Symmetric vs. Asymmetric crypto

#columns(2)[
  === Symmetric
  - (en|de)crypting uses the same key
  - The entire key is private

  #image("symm.svg")

  #colbreak()
  === Asymmetric
  - (en|de)crypting use different keys
  - The key has a public and a private part

  #image("asymm.svg", width: 70%)
]

== Keys, keypairs, and subkeys

- A *key* is a string of character used by a cryptographic algorithm to encode or decode data
- A *key pair* refers to a pair of a *public* and *private* key in asymmetric crypto
-

== Algorithms

== PGP vs. GPG

== Example: Using GPG

== Hardware keys
