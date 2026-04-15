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
    title: [The Flake ecosystem],
    subtitle: [],
    author: [Matias Zwinger],
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
  [
    #set text(20pt)
    - Flake infrastructure
    - Meta-tools
      - flake-utils
      - flake-parts
      - flake-compat
    - Flake-based tools
      - disko
      - deploy-rs
  ],
)

== Flake infrastructure

- Official flake search: https://search.nixos.org/flakes
- 3rd party flake registries
  - FlakeHub https://flakehub.com/
  - Flakestry https://flakestry.dev/
- Good old GitHub search https://github.com/topics/flakes

= Meta-tools

Flakes for developing flakes

== flake-utils

https://github.com/numtide/flake-utils

- Collection of pure Nix functions for flakes
- Main use: `eachDefaultSystem` eliminates per-system boilerplate

#show raw.where(block: true): set text(size: 11pt)
#grid(
  columns: (1fr, 1fr),
  column-gutter: 1em,
  row-gutter: 0.5em,
  [*Without flake-utils*], [*With flake-utils*],
  [
    ```nix
    {
      outputs = { self, nixpkgs }: {
        packages.x86_64-linux.default =
          nixpkgs.legacyPackages
            .x86_64-linux.hello;
        packages.aarch64-linux.default =
          nixpkgs.legacyPackages
            .aarch64-linux.hello;
        packages.x86_64-darwin.default =
          nixpkgs.legacyPackages
            .x86_64-darwin.hello;
        # repeat for every output type...
      };
    }
    ```
  ],
  [
    ```nix
    {
      inputs.flake-utils.url =
        "github:numtide/flake-utils";

      outputs = { self, nixpkgs, flake-utils }:
        flake-utils.lib.eachDefaultSystem (system:
          let
            pkgs = nixpkgs.legacyPackages.${system};
          in {
            packages.default = pkgs.hello;
            devShells.default = pkgs.mkShell {
              buildInputs = [ pkgs.hello ];
            };
          }
        );
    }
    ```
  ],
)

== flake-parts

https://flake.parts/

- Allows splitting the flake into modules (similar to Nix modules)

#show raw.where(block: true): set text(size: 11pt)
#grid(
  columns: (1fr, 1fr),
  column-gutter: 1em,
  row-gutter: 0.5em,
  [*Without flake-parts*], [*With flake-parts*],
  [
    ```nix
    # everything in one flake.nix
    {
      outputs = { self, nixpkgs, flake-utils }:
        flake-utils.lib.eachDefaultSystem (system:
          let
            pkgs = nixpkgs.legacyPackages.${system};
          in {
            packages.default = pkgs.hello;
            devShells.default = pkgs.mkShell {
              buildInputs = [ pkgs.hello ];
            };
          }
        ) // {
          nixosConfigurations.myHost =
            nixpkgs.lib.nixosSystem { ... };
          # grows unbounded...
        };
    }
    ```
  ],
  [
    ```nix
    # flake.nix stays small
    {
      inputs.flake-parts.url =
        "github:hercules-ci/flake-parts";

      outputs = inputs@{ flake-parts, ... }:
        flake-parts.lib.mkFlake { inherit inputs; } {
          imports = [
            ./packages.nix
            ./devshells.nix
            ./nixos.nix
          ];
          systems = [
            "x86_64-linux"
            "aarch64-linux"
          ];
        };
    }
    ```
  ],
)

== flake-compat

https://github.com/NixOS/flake-compat

- Allows usage of flakes in systems with no flake support
- Bridges `nix-build` / `nix-shell` to `flake.nix` outputs

#show raw.where(block: true): set text(size: 11pt)
#grid(
  columns: (1fr, 1fr),
  column-gutter: 1em,
  row-gutter: 0.5em,
  [`default.nix`], [`shell.nix`],
  [
    ```nix
    (import
      (fetchTarball
        "https://github.com/NixOS/flake-compat/archive/main.tar.gz"
      )
      { src = ./.; }
    ).defaultNix
    ```
  ],
  [
    ```nix
    (import
      (fetchTarball
        "https://github.com/NixOS/flake-compat/archive/main.tar.gz"
      )
      { src = ./.; }
    ).shellNix
    ```
  ],
)

= Flake-based tools

Nix{,OS} tools distributed as flakes

== disko

https://github.com/nix-community/disko

- Enables declarative disk partitioning
- Replaces manual `fdisk`/`mkfs` steps during installation

#show raw.where(block: true): set text(size: 6pt)
#grid(
  columns: (1fr, 1fr),
  column-gutter: 1em,
  row-gutter: 0.5em,
  [`disk-config.nix`], [`flake.nix`],
  [
    ```nix
    {
      disko.devices = {
        disk.main = {
          type = "disk";
          device = "/dev/nvme0n1p1";
          content = {
            type = "gpt";
            partitions = {
              ESP = {
                size = "500M";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                };
              };
              root = {
                size = "100%";
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/";
                };
              };
            };
          };
        };
      };
    }
    ```
  ],
  [
    ```nix
    {
      inputs.disko.url =
        "github:nix-community/disko";

      outputs = { nixpkgs, disko, ... }: {
        nixosConfigurations.myHost =
          nixpkgs.lib.nixosSystem {
            modules = [
              disko.nixosModules.disko
              ./disk-config.nix
              ./configuration.nix
            ];
          };
      };
    }
    ```

    ```bash
    # Partition, format, and install
    sudo nix run \
      'github:nix-community/disko#disko-install' \
      -- --flake '.#myHost' \
      --disk main /dev/sda
    ```
  ],
)

== deploy-rs

https://github.com/serokell/deploy-rs

- Deploy NixOS configurations over SSH
- Rollback support

#show raw.where(block: true): set text(size: 7pt)
#grid(
  columns: (1fr, 1fr),
  column-gutter: 1em,
  row-gutter: 0.5em,
  [`flake.nix`], [Deploy],
  [
    ```nix
    {
      inputs.deploy-rs.url =
        "github:serokell/deploy-rs";

      outputs = { nixpkgs, deploy-rs, ... }: {
        nixosConfigurations.myHost =
          nixpkgs.lib.nixosSystem { ... };

        deploy.nodes.myHost = {
          hostname = "192.168.1.67";
          profiles.system = {
            user = "root";
            path = deploy-rs.lib.x86_64-linux
              .activate.nixos
              self.nixosConfigurations.myHost;
          };
        };

        checks = builtins.mapAttrs
          (system: deployLib:
            deployLib.deployChecks
              self.deploy)
          deploy-rs.lib;
      };
    }
    ```
  ],
  [
    ```bash
    # Deploy to a node
    nix run \
      'github:serokell/deploy-rs' \
      -- '.#myHost'

    # Deploy a specific profile
    nix run \
      'github:serokell/deploy-rs' \
      -- '.#myHost.system'

    # Dry run (no activation)
    deploy --dry-activate '.#myHost'
    ```
  ],
)

#focus-slide[
  #set text(60pt, weight: "bold")
  Questions?
]
