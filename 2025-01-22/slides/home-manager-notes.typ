= User Program and Configuration Management with `home-manager`


```
sudo apt install curl git

curl -fsSL https://install.determinate.systems/nix | \
    sh -s -- install --determinate

git init ~/dotfiles

cd dotfiles

ls

nix run home-manager/release-24.11 -- init ~/dotfiles

sudo sysctl -w kernel.unprivileged_userns_clone=1

nix run nixpkgs#vscodium -- --no-sandbox .
```