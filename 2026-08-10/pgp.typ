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
    author: [Luukas Pörtfors, Niklas Halonen],
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

- A *cryptographic key* (or just key) is a string of character used by a cryptographic algorithm to encode or decode data #pause
- A *key pair* refers to a pair of a *public* and *private* key in asymmetric crypto. The word "key" is also often used for "key pair" #pause
- A *subkey* is a keypair used for a specific role or roles: *encryption*, *signing* or *authentication* #pause
- In PGP, a *key* (certificate) is really a collection of keypairs: a primary *certification* key plus subkeys, and identification metadata
- The word "key" can refer to any of the above (or even just a public key), but we use it only to refer to a PGP key

== Keys, keypairs, and subkeys in PGP

#box[
  #image("gpg_key_generation.png", height: 90%)

  Images from: https://web.archive.org/web/20251027132314/https://rgoulter.com/blog/posts/programming/2022-06-10-a-visual-explanation-of-gpg-subkeys.html
]


#image("gpg_export_key.png")

== Algorithms

=== A table of popular cryptographic algorithms

#table(
  columns: (1fr,) * 3,
  table.header([*Algo*], [*Type*], [*Supported by YubiKey*]),

  [AES], [Symmetric], [Yes\*],
  [ChaCha20], [Symmetric], [No],
  [RSA], [Asymmetric], [Yes],
  [ECDSA], [Asymmetric], [Yes],
  [Ed25519], [Asymmetric], [Yes],
  [X25519], [Asymmetric], [Yes],
)

\* AES is supported for PIV management-key operations.

== How PGP encryption works

#box[
  #image("gpg_encrypt.png", height: 90%)

  Image from: https://medium.com/@rushikajayasinghe/what-is-pretty-good-privacy-pgp-6327e760587d
]

== PGP vs. GPG

- GNU Privacy Guard (GnuPG or GPG) is an implementation of the OpenPGP specification based on PGP #pause
- GPG has since diverged from OpenPGP in favor of their own LibrePGP standard #pause
- GPG implements and may recommend usage of non-standard extensions not supported by all implementations of OpenPGP #pause

TL;DR: (Open)PGP is the standard, GnuPG is the _de-facto_ implementation for PC.

== Example: Using GPG

+ Alice, Bob, and Carol each have a PGP certificate (key)
  - They share their *public* keys with eachother #pause
+ Alice sends a *secret* message to Bob who is able to decrypt it
  - Carol is not able to decrypt it #pause
  - Alice is also not able to decrypt it #pause
+ Alice sends another message to Bob, this time also *signing* it and adding themselves as a recipient
  - Alice is able to decrypt and see the signature
  - Bob is able to decrypt and see the *untrusted* signature #pause
  - If Bob trusts Alice's key, they can *sign* (certify) it and share the signed key #pause
+ Alice sends a signed message to Carol
  - Carol is able to decrypt it and sees the *indirectly trusted* (undefined) signature

== Web of Trust

#figure(
  caption: [By Kku - Own work, CC BY-SA 4.0, https://commons.wikimedia.org/w/index.php?curid=80652637],
  image("Web_of_Trust-en.svg"),
)

// == Hardware keys



== Sources

- https://medium.com/@rushikajayasinghe/what-is-pretty-good-privacy-pgp-6327e760587d
- https://users.ece.cmu.edu/~adrian/630-f04/PGP-intro.html
