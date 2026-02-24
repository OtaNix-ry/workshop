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
    title: [Writing Nix],
    subtitle: [_The slides are based on a talk I did in July at the Czech Nix meetup_],
    author: [Luukas Pörtfors],
    date: datetime(year: 2026, month: 2, day: 25),
    institution: [OtaNix ry #box(baseline: 0.15em, image("otanix.svg", height: 1em))],
  ),
)

#let title-slide = slidetheme.title-slide
#let slide = slidetheme.slide
#let focus-slide = slidetheme.focus-slide

#title-slide()

== Structure

#grid(
  columns: (1fr,) * 2,
  column-gutter: 1em,
  image("images/what_is_nix.webp"),
  [
    #set text(20pt)
    + General tips & tricks (Nix language)

    + Packaging tips & tricks

    + Packaging demo

    + NixOS tips & tricks

    + NixOS demo

    + Q&A
  ],
)

= The Nix language

== It's just a programming language

#grid(
  columns: (1fr, 1fr),
  [
    #set text(30pt)
    ```nix
    nix-repl> 2 + 2
    4
    nix-repl> "hel" + "lo"
    "hello"
    ```
  ],
  [
    #set text(20pt)
    - values, operators and types

    - declaring and calling functions

    - data structures

    - Nix is _a real programming language_
      - unlike JSON or YAML
  ],
)

== Functional programming

#grid(
  columns: (1fr,) * 2,
  [
    #set text(24pt)
    ```nix
      let sum = l:
        if l == [] then 0
        else (builtins.head l) +
          (sum (builtins.tail l));
      in sum [1 2 3 4 5]
      15
    ```
  ],
  [
    #set text(18pt)
    - Nix might look unfamiliar to other languages you know

    - Nix is a _functional_ programming language:
      - no loops
      - no mutability
      - laziness (this is very important in Nix)
      - ...

    - Nix is not the softest landing to FP
      - If you want to really learn it, try Haskell#footnote[There's an amazing MOOC course on Haskell: https://haskell.mooc.fi]

  ],
)

== Key language constructs
#slide[
  ```nix
  # 1. Basic values
  42  3.14  "hi"  true  null

  # 2. Let binding
  let x = 10; y = 20; in x + y

  # 3. Attr set
  { name = "pkg"; version = "1.0"; }

  # 4. List
  [ 1 2 3 "four" ]

  # 5. Functions
  x: x + 1
  { a, b }: a + b
  ```][
  ```nix
  # 6. Application
  (x: x * 2) 5

  # 7. Conditional
  if 1 < 2 then "yes" else "no"

  # 8. With
  with { a = 1; b = 2; }; a + b

  # 9. Inherit
  let s = { a = 1; }; in { inherit (s) a; }

  # 10. Interpolation
  let n = "nix"; in "hi ${n}"

  # 11. Import
  import ./file.nix
  ```
]


#slide(title: [Errors and Debugging techniques])[
  #figure(
    caption: [Image source: https://www.reddit.com/r/NixOS/comments/1fgop43/sorry_guys_im_learning/],
    supplement: [],
    numbering: none,
    image("images/nixos-error.jpeg"),
  )
][
  #set text(20pt)
  - Most errors are based on assertions, lack of assertions cause errors to be difficult to find and interpret

  - `lib/debug.nix` for broken expressions

  - `nix repl` for debugging larger entities
]

#slide(title: [Trace examples])[
  #grid(
    columns: (1fr,) * 2,
    row-gutter: 2em,
    ```nix
    nix-repl>traceVal "hello"
    trace: hello
    "hello"
    ```,
    ```nix
    nix-repl>myfun = x: trace "myfun called" x
    nix-repl>(myfun 1) + 1
    trace: myfun called
    2
    ```,

    ```nix
    nix-repl> pkgs.lib.traceSeqN 1 home-manager.users 1
    trace: {
      lajp = {…};
    }
    1
    ```,
    ```nix
    nix-repl> pkgs.lib.traceSeqN 2 home-manager.users 1
    trace: {
      lajp = {
        accounts = {…};
        age = {…};
        assertions = […];
        dbus = {…};
        # ...
      };
    }
    1
    ```,
  )
]

#slide(title: [Documentation])[
  //#box(width: 100%, height: 100%, fill: yellow, align(
  //  center + horizon,
  //)[funny meme])
  #image("images/nix-documentation.jpg", height: 100%, fit: "stretch")
][
  #set text(20pt)
  - Unfortunately it's difficult to find
  - A few tricks
    + search.nixos.org
    + Searching `github:NixOS/nixpkgs`
    + GitHub search `lang:Nix keyword`
    + Asking LLMs (!!)
]

= Packaging tips & tricks

#slide(title: [The anatomy of a Nix package])[
  #show raw.where(block: true): set text(size: 12pt)
  ```nix
  # Arguments
  { lib, stdenv, fetchurl }:

  # Function body (call to stdenv.mkDerivation)
  stdenv.mkDerivation {
    # package name/version (shown in store path)
    pname = "pv";
    version = "1.9.31";

    # fetch sources by calling fetchurl
    src = fetchurl {
      url = "...";
      hash = "...";
    };

    # Package metadata (license, maintainers, ...)
    meta = {
      license = lib.licenses.gpl3Plus;
      # ...
    };
  }
  ```
][
  #set text(20pt)
  - a package is a function -- a recipe
    - aka. derivation
  - for stdenv:
    - inputs:
      - buildInputs
      - nativeBuildInputs
    - phases:
      - patchPhase
      - configurePhase
      - buildPhase
      - installPhase
      - etc.
  - metadata #emoji.face.explode
]

#slide(title: [Nixpkgs -- Grandma's Nix cookbook])[
  #image("images/nixpkgs-sloc.png")
][
  #set text(24pt)
  - If you're looking for something, it's probably in nixpkgs:
    - `pkgs.build${lang}Package`
    - trivial builders and writers
    - `pkgs.stdenv`
    - `pkgs.makeWrapper`
]

#focus-slide[
  #set text(60pt, weight: "bold")
  Demo: Packaging
]

#focus-slide[
  #set text(60pt, weight: "bold")
  Challenge:\
  package something!
]

== Suggestions

#slide[
  - Package your own software

  - Package something you need

  - Some suggestions from awesome-cli
][
  - clipboard — C++/C (CMake)
  - deadlink — Python (PyPI wheel binary)
  - file-type-cli — Node.js (npm)
  - get-port-cli — Node.js (npm)
  - ggc — Go (buildGoModule)
  - gzip-size-cli — Node.js (npm)
  - hasha-cli — Node.js (npm)
  - organize-rt — Rust (Cargo)
  - parse-columns-cli — Node.js (npm)
  - pipe_exec — C (Makefile)
  - pm — Shell (bash/zsh scripts)
  - strip-json-comments-cli — Node.js (npm)
  - xiringuito — Shell (bash scripts)
]


// do something
// 1. blmgr
// 2. sanamahti
// 3. more complicated Rust example (with db?)

= NixOS tips & tricks

#slide(title: [Getting started with NixOS])[
  #figure(
    caption: [Image source: https://kumardamani.net/post/nixos-p1/],
    supplement: [],
    numbering: none,
    image("images/wanna-try-nixos.jpg"),
  )
][
  #set text(20pt)
  - Start simple
    - Don't try to understand 5k SLOC of someone else's code #emoji.monkey.see
    - I recommend starting with a server configuration, perhaps in a VM

  - Find help:
    - search.nixos.org/options
    - NixOS wiki & manual
    - GitHub search (now more than ever)
    - a bunch of guides exist#footnote[NixOS & Flakes Book https://nixos-and-flakes.thiscute.world/]
]

#slide(title: [#strike[Configuring] Declaring your system #emoji.face.cool])[
  #box(height: 80%, inset: 1em, fill: color.blue.lighten(80%), quote(
    block: true,
    attribution: [Phil Karlton, adapted],
    [
      There are two hard things in #strike[Computer Science] NixOS: #strike[cache invalidation] secret management and #strike[naming things] state.
    ],
  ))
][
  #set text(20pt)
  - Structuring your configuration
    - options, `mkIf` pattern
    - per-system `imports` pattern
    - module system

  - portability (= "borrowing" config from others)
]

#slide(title: [Writing NixOS modules])[
  #figure(
    caption: [Image source: https://www.reddit.com/r/NixOS/comments/p132mz/when_you_discover_nixos/],
    supplement: [],
    numbering: none,
    box(stroke: black + 4pt, image("images/nixos-docker.png")),
  )
][
  #set text(20pt)
  - declarative configuration \ (#emoji.arrow.t we like this one)

  - knowing systemd helps

  - responsible state management

  - secrets as paths (e.g. `passwordFile`)

  - hardening #emoji.skull
]

#focus-slide[
  #set text(60pt, weight: "bold")
  Demo:\
  Writing a NixOS module
]

#focus-slide[
  #set text(60pt, weight: "bold")
  Challenge:\
  Write your own module
]

#focus-slide[
  #set text(60pt, weight: "bold")
  Thanks!
]
