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
    title: [NixOS & Flakes],
    author: [Roy Långsjö],
    date: datetime(year: 2026, month: 4, day: 14),
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
    + What are flakes?
    + The problem with channels
    + Other flake quirks
    + NixOS + HM config with flakes
  ],
)

= Flakes

== Inputs & outputs

#grid(
  columns: (0.95fr, 1fr),
  [
    #set text(30pt)
    ```nix
    {
      description = "My flake";
      inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs";
      };
      outputs = { nixpkgs, ... }@inputs: {
        packages = { ... };
        nixosConfigurations = { ... };
        devShells = { ... };
      };
    }
    ```
  ],
  [
    #set text(19pt)
    - Need the experimental features `nix-commmand` and `flakes`
      enabled

    - A flake.nix defines `inputs` and `outputs`
      - Think of it like a function

    - `inputs` are other flakes/Nix code#footnote[Usually flakes or Nix code, but can be anything] that get fetched and passed to your function
      - `man nix3-flake` for input types

    - The `outputs` block uses those `inputs` to define _what_ it outputs #footnote[Output schema: https://wiki.nixos.org/wiki/Flakes#Output_schema]

    - `flake.nix` is an _entrypoint_ to your other Nix code, keep it simple
  ],
)

== Simple flake.nix

#slide[
  ```nix
  {
    inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    outputs = { nixpkgs, self }@inputs:
      let
        system = "x86_64-linux";
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages.${system}.default = pkgs.hello; # nix run
        nixosConfigurations.my-hostname = nixpkgs.lib.nixosSystem {
          modules = [ ./configuration.nix ]; # nixos-rebuild --flake .
        };
        devShells.${system}.default = pkgs.mkShell {
          packages = [ pkgs.python3 ]; # nix develop
        };
      };
  }
  ```
]

== The nix3 CLI
#slide[
  ```bash
  # nix2 -> nix3 'equivalent' commands
  nix-shell -p hello  -> nix shell nixpkgs#hello
  nix-shell           -> nix develop
  nix-store           -> nix store
  nix-build           -> nix build
  nix-instantiate     -> nix eval
  nixos-rebuild       -> nixos-rebuild --flake <flakeref>

  # other commands
  nix run nixpkgs#hello # runs the 'hello' package's main program
  nix flake <init|update|lock|show|metadata> # working with flake.nix/flake.lock
  nix repl # read eval print loop
  nix registry # flake registry
  ```
]

= The problem with channels

== Reproducibility... mostly
#slide[
  ```nix
  { pkgs ? import <nixpkgs> { }, }:
  pkgs.mkShell {
    packages = [
      pkgs.python3 # 3.4? 3.9? 3.15?
    ];
  }
  ```
][
  #set text(20pt)
  - You'll get the same packages, but no guarantee of version
  - Works fine today, might fail tomorrow
  - Can rollback, _but only_ if you don't garbage collect your previous channels
]

== flake.lock
#grid(columns: (0.8fr, 1fr),
[
  ```json
  {
  "nixpkgs": {
    "locked": {
      "lastModified": 1775710090,
      "narHash": "sha256-ar3rofg+...",
      "owner": "NixOS",
      "repo": "nixpkgs",
      "rev": "4c1018dae018162ec87...",
      "type": "github"
    },
    "original": {
      "owner": "NixOS",
      "ref": "nixos-unstable",
      "repo": "nixpkgs",
      "type": "github"
    }
  }
  ```
],
[
  #set text(19pt)
  - Each input (and its inputs) gets an entry in the lockfile
  - Every type of input will at least store the hash of the content
  - Git type inputs will also get the exact commit

  - Importantly the `flake.lock` file is part of your repo/project,
    and should be tracked in a VCS
  - Everyone will have the same version of everything
  - Need to roll back? Just revert the update with your VCS

  - Other pinning solutions such as `npins`, `niv` can also do this
])

= Other flake stuff
== Purity
#grid(columns: (1fr, 1fr), [
  ```nix
  # flake.nix
  {
    outputs = _: {
      system = builtins.currentSystem;
      time = builtins.currentTime;
      path = import /absolute/path.nix;
    };
  }
  ```
  ```bash
  $ nix eval .#system
  error: attribute 'currentSystem' missing
  $ nix eval .#time
  error: attribute 'currentTime' missing
  $ nix eval .#path
  error: access to absolute path '/absolute' is forbidden in pure evaluation mode (use '--impure' to override)
  ```
], [
  - Flakes enforce purity
    - No impure builtins
    - No paths outside the flake#footnote['Flake' refers to a filesystem tree with a `flake.nix` at
      its root]
    - Bypass with `--impure`
  - Copies the whole flake to the store when it has changed
    - Big repo$->$ slow copies
    - Secrets in repo$->$ world readable in `/nix/store`
    - Unavoidable even with `--impure`
])

== Git awareness
#grid(columns: (1fr, 1fr), [
  ```nix
  # flake.nix
  {
    outputs = _: {
      myFile = import ./myfile.nix;
    };
  }
  ```
  ```bash
  $ ls -a
  .  ..  flake.nix  .git  myfile.nix
  $ git ls-files
  flake.nix
  $ nix eval .#myFile
  error: path '/nix/store/fvqazvkdwxdnr2hdhdyqp481lhk7ii8x-source/myfile.nix' does not exist
  $ nix eval path:.#myFile
  "hello from file"
  ```
],
[
  - When part of a Git repo, only tracked files are visible to flakes
  - `.gitignore` build artifacts and secrets
    $->$ not copied to store
  - Forget to track a new file$->$ invisible to flakes
  - Bypass Git awareness by using explicit `path:` type flakeref
])

= NixOS configuration with flakes

== `nixpkgs.lib.nixosSystem`
#slide[
  - The function that creates a NixOS system
  - Only available via the Nixpkgs flake
  - The Nixpkgs you call this from becomes your system Nixpkgs
  ```nix
  {
    outputs = { nixpkgs, ... }@inputs: {
      nixosConfigurations.<hostname> = nixpkgs.lib.nixosSystem {
        # passes `inputs` to all modules as arg
        specialArgs = { inherit inputs; };

        # Modules that make up your configuration
        # Can also be a single module that imports the rest
        modules = [ ./configuration.nix ];
      };
    };
  };
  ```
]


#focus-slide[
  #set text(60pt, weight: "bold")
  Demo: \
  Migrating a NixOS + HM config to use flakes
]
