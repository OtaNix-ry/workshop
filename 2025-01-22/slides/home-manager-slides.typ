// Instructions:
// 0. enter the top level nix shell
// 1. run `typst-watch home-manager-slides.typ`

#import "@preview/touying:0.5.5": *
#import "slidetheme.typ"
#import "@preview/note-me:0.2.1": *
#import "@preview/fontawesome:0.4.0": *
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

#let bullets = (snowflake,)
// MEGATUNKKAUS
#set list(marker: n => {
  let bullet = text(size: 0.65em, bullets.at(calc.rem-euclid(n, bullets.len())))
  style(styles => place(dx: -measure(bullet, styles).width - 0em, bullet))
}, indent: 0.65em, tight: true)
#show list: it => pad(left: 0.65em, {
  set block(above: 0.65em)
  // set list(indent: 0em) // override indent from first level lists
  it
})

#set footnote.entry(separator: line(length: 30%, stroke: 1pt + slidetheme.default-colors.primary-light))
#let github = fa-icon("github")

// #show raw: it => box(
//   fill: rgb("#eff1f5"),
//   inset: 8pt,
//   radius: 12pt,
//   text(fill: rgb("#4c4f69"), it)
// )

#show link: set text(slidetheme.default-colors.primary-dark)

#let s = slidetheme.register(
  // footer: link("https://gitlab.com/niklashh/nix-notes/-/blob/" + sys.inputs.rev + "/slides/introduction-2024-08-28.typ")[Presentation source code]
)
#let s = (s.methods.info)(
  self: s,
  title: [
    User Program and Configuration Management with `home-manager`
  ],
  subtitle: [OtaNix #box(baseline: 0.15em, image("otanix.svg", height: 1em)) Workshop],
  author: [Niklas Halonen, Joonas von Lerber],
  date: datetime(year: 2025, month: 1, day: 22),
  institution: [Aalto University],
)
#let (init, slides, touying-outline, alert, speaker-note) = utils.methods(s)
#show: init

#show strong: alert

// #let (slide, empty-slide, title-slide, new-section-slide, focus-slide, custom-slide) = utils.slides(s)
#show: slides


// Presentation starts

// == User Program and Configuration Management with `home-manager`

== Agenda

+ Introduction and basics
+ Hands-on installation to a VM
  - Follow along!

==
  
#image("society-meme.png")

== What is home-manager (H-M)?

+ A Nix module for managing user applications and services, and their configuration, a.k.a _dotfiles_.
+ A CLI for interacting and invoking the H-M module.
  
Home-manager's (mostly a reiteration of Nix's) philosophy:
  - Reproducibility: building a configuration leads to a _unique_ outcome.
  - Separation of concerns: enables splitting code into modules and files.
  - Declarative unified#footnote[Some H-M modules just provide a `configFile` option, whereas some have more complex `settings` as well as a `configFile`.] configuration.
  - Cross reference/link configuration options and variables.
    - Even integrate to the NixOS configuration.
  - As always, everything is just a *symbolic link* to the Nix store.

== A word of warning

- Many modules/services are available on both NixOS and H-M which may conflict with each other if enabled and may have incompatible configuration options or varying feature support.

== Installation (standalone)

+ Installing nix and git (if not already installed)
+ Starting a shell with `home-manager` CLI
+ Creating a standalone H-M config repository
+ H-M basics and solving the common OpenGL problem
  - User programs
  - User services
  - Window manager
+ Setting up more complicated H-M integration with FireFox, VSCode

== Installing Nix

#align(center)[
https://docs.determinate.systems/getting-started/
]

\

```sh
curl -fsSL https://install.determinate.systems/nix | \
    sh -s -- install --determinate
```

== Creating a standalone H-M config repository

```bash
git init ~/dotfiles
nix run home-manager/release-24.11 -- init ~/dotfiles
# Note: home-manager/master is the latest unstable version of H-M
cd ~/dotfiles
git add . # Required because flakes ignore files outside of git
nix run home-manager/release-24.11 -- switch --flake ~/dotfiles
```

==

Expected outcomes:
- (The news are shown)
- You have the `home-manager` program available
- `dotfiles` repository contains the following files
  - ```bash
    dotfiles
    ├─ .git/
    ├─ flake.nix
    ├─ flake.lock
    └─ home.nix
    ```

== Decrypting the Default Configuration

The default `flake.nix` is as follows and is all set to start using H-M so you *don't need to understand* any of it right now:

#block[
#set text(size: 14pt)

#grid(columns: (1fr,)*2, gutter: 1em)[
```nix
{
  description = "H-M configuration of otanix";

  inputs = {
    # Specify the source of H-M and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
```
][
```nix
  outputs = { nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      homeConfigurations."otanix" =
        home-manager.lib
          .homeManagerConfiguration {
        inherit pkgs;

        # Specify your home configuration
        # modules here, for example,
        # the path to your home.nix.
        modules = [ ./home.nix ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
      };
    };
}
```
]
]

== Decrypting `home.nix`

This is more relevant for day-to-day configuration of H-M.

#block[
#set text(size: 18pt)

#grid(columns: (1fr,)*2, gutter: 1em)[
```nix
{pkgs, ...}:

let
  # Personal Info
  name = "Matti Meikäläinen";
  email = "matti.meikalainen@iki.fi";
  username = "leet-matti";
  githubUsername = "MattimusUltimatus";

  homeDir = "/home/${username}"
in {

```
][
```nix
  programs = {
    home-manager.enable = true;
    git = {
      enable = true;
      userName = "${name}";
      userEmail = "${email}";
    }
    fish = {
      enable = true;
      shellAbbrs = {
        "l" = "ls -arthl";
      }
    }
  }
}
  
```
] 
]
== How to Install Programs
Under the `programs` attribute set, you can add programs and configure them. I want to have Firefox so let's add it.

```nix
programs = {
  firefox = {
    enable = true;
  }
}
```

== Rebuilding the Configuration

+ Make changes to the configuration
+ Git add them
+ Run
  ```bash
  home-manager switch --flake ~/dotfiles
  ```
+ If there's an error
  - Then: decrypt the error message
  - Else: test out the changes
+ Go back to step 1.

== H-M Commands

Some of the useful commands provided by `home-manager --help`:

```bash
Commands
  option OPTION.NAME      Inspect configuration option named OPTION.NAME.

  build                   Build configuration into result directory

  switch                  Build and activate configuration

  generations             List all home environment generations

  packages                List all packages installed in home-manager-path

  uninstall               Remove Home Manager
```


== Resources

Here are some useful resources for finding H-M 
- https://nix-community.github.io/home-manager/index.xhtml#sec-flakes-standalone

- https://home-manager-options.extranix.com/

// == Notes

// - How to use wireshark or other privileged programs through Nix on Debian