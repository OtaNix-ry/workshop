#import "@preview/touying:0.5.5": *
#import "slidetheme.typ"
#import "@preview/note-me:0.2.1": *
#import "@preview/fontawesome:0.4.0": *
#import emoji: *

#let default-colors = (
    neutral-dark: rgb("#fafafa"),
    neutral-lightest: rgb("#232323"),
    primary-dark: rgb("#57a8ed"),
    primary-light: rgb("#27385d"),
    secondary-light: rgb("#ff8657"),
    secondary-lighter: rgb("#27385d"), // same as primary-light?
)

#let focus-box(body) = {
  set align(center + horizon)
  set text(size: 26pt, white)
  block(fill: default-colors.secondary-light, inset: 12pt, radius: 4pt)[#body]
}

#let s = slidetheme.register(
  // footer: link("https://github.com/OtaNix-ry/workshop/blob/" + sys.inputs.rev + "/2025-01-22/slides/nix.typ")[Presentation source code],
)
#let s = (s.methods.info)(
  self: s,
  title: [
    What is Nix?
  ],
  subtitle: [OtaNix ry #box(baseline: 0.15em, image("otanix.svg", height: 1em))],
  author: [Matias Zwinger],
  date: datetime(year: 2025, month: 1, day: 22),
  institution: [Aalto University],
)
#(s.enable-styled-warning = false)
#let (init, slides, touying-outline, alert, speaker-note) = utils.methods(s)
#show: init

#show strong: alert

// #let (slide, empty-slide, title-slide, new-section-slide, focus-slide, custom-slide) = utils.slides(s)
#show: slides

==
#align(center)[
  #image("nix-trinity.svg")
]

== Namespace problem

#align(center + horizon)[
  #image("dependency.svg", width: 30%)
]

#focus-box[This is called dependency hell]

== How Nix solves this

- Both versions of C share the same path
- Add version to file path?
  - Example: Conda
  - They could still be different
- *(name + version + source code + dependencies)* $#arrow.r$ hash
- `pwnbnq2wlxx31fn1s1388pbwgll5kk12-C-1.3`

== Nix store

- All packages reside in `/nix/store`
  - FHS violation (or augmentation)
- Immutable for users
- Can be modified using Nix commands
- A package stays in the store until it is *garbage collected*
  - Manually or automatically (cron, systemd timer)

== Nix commands

- Enter new shell with software available: `nix shell -f "<nixpkgs>" foo`
  - To expose the package, nix uses symlinks and \$PATH modification
- Run `foo` directly: `nix run -f "<nixpkgs>" foo -- --arg1 --arg2`
- Collect garbage: `nix-collect-garbage`

== nixpkgs

- The largest collection of Nix packages
  - Hosted on GitHub
  - "Wikipedia approach": anyone can submit a package
  - Maintained by volunteers (like me)

== Nix language

- Every package manager has a way to describe packages
- Nix has its own language
  - Declarative
  - Functional
  - Lazy
  - Dynamically typed
  - "JSON with functions"

== An example

GNU hello, stripped down version of the nixpkgs package

```nix
stdenv.mkDerivation (finalAttrs: {
  pname = "hello";
  version = "2.12.1";

  src = fetchurl {
    url = "mirror://gnu/hello/hello-${finalAttrs.version}.tar.gz";
    hash = "sha256-jZkUKv2SV28wsM18tCqNxoCZmLxdYH2Idh9RLibH2yA=";
  };
})
```

- `stdenv` can build packages that use the UNIX standard of `./configure; make; make install;`

== Two birds with one package manager

=== Normal package managers:
- Serve *already compiled* programs (binaries)
- Only tells you how to install them

=== Nix
- Also specifies how to *build* software
- You can build everything on your own computer, like on Gentoo
- Binaries can still be downloaded from public cache
  - Nix checks what hash the output _would_ have, and downloads it from the cache if available

== ~
#focus-box[Putting packages in the store is nice]

== ~
#focus-box[What if I put my whole operating system there?]

== NixOS

#grid(
  columns: (auto, auto),
  [- All OS components are in the store
      - Programs
      - Config files
      - Systemd services
      - Kernel
      - Bootloader (partly)
  ],
  [
    ```nix
        {
          programs.git = {
            enable = true;
            config.init.defaultBranch = "main";
          };
          services.openssh.enable = true;
          boot.kernelPackages = linuxPackages_5_62;
          boot.lanzaboote.enable = true;
        }
    ```
  ],
)

- Everything in the system is specified using Nix expressions
  - Infrastructure as code
  - Modify system config and rebuild system to install software
    - `sudo nixos-rebuild switch`

== Corollary benefits

- Creating a symlink is atomic in UNIX
  - Power outage #sym.arrow either symlink exists or not
  - There is no in-between state
  - Switching NixOS generations = creating one symlink to `/run/current-system`
    - NixOS updates are *atomic*
    - *No invalid states*

- The Nix store contains previous generations
  - If the update breaks something, reboot and roll back

= Any questions?
