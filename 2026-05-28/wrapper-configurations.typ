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
    title: [Configuration with wrappers],
    author: [Roy Långsjö],
    date: datetime(year: 2026, month: 5, day: 28),
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
  image("images/nix_logo.svg"),
  [
    #set text(20pt)
    + What are wrappers?
    + Why use them?
    + How to make them
  ],
)

= What are wrappers?

== Lightweight scripts around another executable

#grid(
  columns: (0.95fr, 1fr),
  [
    #set text(30pt)
    ```bash
    #! /nix/store/.../bin/bash -e
    export KITTY_CONFIG_DIRECTORY='/nix/store/...-KITTY_CONFIG_DIRECTORY'

    exec -a "$0" "/nix/store/.../bin/.kitten-wrapped"  "$@"
    ```
  ],
  [
    #set text(19pt)
    - Small scripts (or binaries) that do some kind of setup before executing the real executable
    - Used everywhere in Nixpkgs to make programs work
    - Same mechanism can be used to make something look at configuration in an
      arbitrary place#footnote[If the program supports it]
  ],
)

== Why use them?
#set text(20pt)
- Completely self-contained configuration as part of the package
- `nix run` from anywhere
- Same configuration can be used with any configuration 'paradigm'
  - NixOS, Home Manager, nix-darwin, ...
- Fast iteration, build only your wrapper instead of the whole config

Downsides:
- Not all programs have a flag or env var to specify config
  source

== First building block: `symlinkJoin`

#grid(
  columns: (1.20fr, 1fr),
  [
  ```nix
  pkgs.symlinkJoin {
    name = "symlink-package";
    paths = [ pkgs.hello ];
    postBuild = ''
      echo 'echo hello' > $out/bin/hello2
      chmod +x $out/bin/hello2
    '';
  }
  ```
  ```bash
  $ ls result/bin/
  hello -> /nix/store/...-hello-2.12.3/bin/hello
  hello2
  ```
],
[
  #set text(18pt)
  - symlinkJoin is a trivial build helper #footnote[https://nixos.org/manual/nixpkgs/stable/#chap-trivial-builders]
    that symlinks each file from packages in `paths` to the result
  - Allows changing the output of a derivation without causing a rebuild
])

== The second building block: `makeWrapper`
#grid(
  columns: (1fr, 1fr),
  [
    ```bash
    $ wrapProgram $out/bin/executable \
        --set ENVVAR VALUE \
        --add-flag '--something'
    ```
  ],
  [
    #set text(18pt)
    - Set-up hook placed in `nativeBuildInputs` that gives access to `makeWrapper`
      and `wrapProgram` in build phases
    - Used to create the actual wrapper script around the real executable
    - Also exists `makeBinaryWrapper` which make small compiled binaries instead
      of bash scripts
      - `makeWrapper` and `makeBinaryWrapper` don't behave exactly the same
  ]
)
==
#slide[
  ```bash
  $ ls -la $out/bin/
  -r-xr-xr-x 1 root root  198  1. 1.  1970 executable
  -r-xr-xr-x 1 root root    0  1. 1.  1970 .executable-wrapped

  $ cat $out/bin/executable
  #! /nix/store/i27rhb3nr65rkrwz36bchkwmav6ggsmn-bash-5.3p9/bin/bash -e
  export ENVVAR='VALUE'
  exec -a "$0" "/nix/store/...-my-wrapper/bin/.executable-wrapped"  '--something' "$@"
  ```
]

= How to configure via wrappers

== Steps
#slide[
  #set text(22pt)
  1. Find an env var or flag that tells the program where to look for its config
    - Quick grep through a manpage usually works
    - This is the biggest hurdle, as not everything has one
  2. `symlinkJoin` + `wrapProgram`
]

== Putting it together
#grid(columns: (1.15fr,1fr),
  [
    ```nix
      let
        zdotdir = pkgs.writeTextDir ".zshrc" ''
          # zshrc stuff
        '';
      in
      pkgs.symlinkJoin {
        name = "zsh-wrapped";
        paths = [ pkgs.zsh ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/zsh \
            --set ZDOTDIR "${zdotdir}"
        '';
      }
    ```
  ],
  [
  #set text(19pt)
  - Zsh derivation which takes the config out of `"${zdotdir}"`
  - Could also point it at a relative path `"${./zdotdir}"` that contains the `.zshrc`
  ]
)

== nix-wrapper-modules
- https://github.com/BirdeeHub/nix-wrapper-modules
- Project aiming to provide NixOS/Home Manager like modules to configure
  programs via wrappers
- NixOS and Home Manager has modules for a lot more programs
- Modules can only configure the program (i.e. no systemd services or such)


= Questions?
