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
  footer: link("https://github.com/OtaNix-ry/workshop/blob/" + sys.inputs.rev + "/2025-01-22/slides/nix.typ")[Presentation source code],
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

= Nix as a package manager

== Common package manager problems

- A and B both depend on C
  - A depends on C 1.3
  - B depends on C 2.0
  - 2.0 makes breaking changes
- C resides at `/usr/lib/C.so`
  - Only one version at a time
- Either A or B is broken

#focus-box[This is called dependency hell]

== How Nix solves this

- Namespace problem
- Add version to file path?
  - They could still be different
- *name + version + build instructions + dependencies*
- Collected into a structured format (NAR) and hashed
- `pwnbnq2wlxx31fn1s1388pbwgll5kk12-C-1.3`

== Nix store

- All packages reside in `/nix/store`
  - FHS violation
- Immutable for users
- Can be modified using commands
- A package stays in the store until it is *garbage collected*
  - Manually or automatically (cron, systemd timer)

== Nix commands

- Enter new shell with software available: `nix shell nixpkgs#foo`
  - To expose the package, nix uses symlinks and \$PATH modification
- Run `foo` directly: `nix run nixpkgs#foo -- --arg1 --arg2`
- Collect garbage: `nix-collect-garbage`

== nixpkgs

- The largest collection of Nix packages
  - Maintained by volunteers (like me)
  - Hosted on GitHub
  - Anyone can submit a package

= Nix language

- Every package manager has a way to describe packages
- Nix has its own language
  - Declarative
  - Functional
  - Lazy
  - Dynamically typed
  - Looks a bit like JSON

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
- Can you trust them? Malicious code injected?

=== Nix
- Specifies how to *build AND install* software
- You can build everything on your own computer, like on Gentoo
- Binaries can still be downloaded from public cache
  - Nix checks what hash the output _would_ have, and downloads it from the cache if available

== ~
#focus-box[Putting packages in the store is nice]

== ~
#focus-box[What if I put my whole operating system there?]

= NixOS

- All OS components are in the store
  - Programs
  - Config files
  - Kernel
  - Bootloader (partly)
- Everything in the system is specified using Nix expressions
  - Infrastructure as code
  - Modify system config and rebuild system to install software
    - `environment.systemPackages = [pkgs.hello];`
    - `sudo nixos-rebuild switch`

== Corollary benefits

- Creating a symlink is atomic in UNIX
  - Power outage #sym.arrow either symlink exists or not
  - There is no in-between state
  - Switching NixOS generations = creating one symlink
    - NixOS updates are atomic
    - No invalid states

- The Nix store contains previous generations
  - If the update breaks something, reboot and roll back
