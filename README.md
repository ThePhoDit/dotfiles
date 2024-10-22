# Fedora Setup Guide

- Run the setup script from the home directory.
```bash
curl -O https://raw.githubusercontent.com/ThePhoDit/dotfiles/fedora/setup/setup.sh
wget https://github.com/ThePhoDit/dotfiles/releases/latest/download/dotfiles-script
chmod u+x dotfiles-script
./dotfiles-script
bash setup.sh
rm dotfiles-script setup.sh
```

- Setup ZeroTier.
	- Set interfaces names under `/var/lib/zerotier-one/devicemap` with the `networkID=interfaceName` format.
	- Join the networks.
	- Authorize the device.
- Setup Synthing folders.
- Download Librewolf extensions.
  - [Dark Reader](https://addons.mozilla.org/en-US/firefox/addon/darkreader)
  - [XBrowserSync](https://addons.mozilla.org/en-US/firefox/addon/xbs/)
  - [SponsorBlock](https://addons.mozilla.org/en-US/firefox/addon/sponsorblock/)
  - [Decetralayes](https://addons.mozilla.org/en-US/firefox/addon/decentraleyes/)
  - [KeePass-Browser](https://addons.mozilla.org/en-US/firefox/addon/keepassxc-browser/?utm_source=addons.mozilla.org&utm_medium=referral&utm_content=search)
  - Enable all filters for UBlock Origin.

- Install Zed extensions.
	- HTML
	- Catppuccin Themes
	- Dockerfile
	- TOML
	- Git Firefly
	- SQL
	- Make
	- GraphQL
	- XML
	- Docker Compose
	- LaTeX
	- Basher
	- R
	- Haskell
	- AsciiDoc
	
	
# How to sync actual dotfiles without installation.

```bash
cd ~/dotfiles
stow .
```

This was inspired by 
- [Stow has forever changed the way I manage my dotfiles](https://www.youtube.com/watch?v=y6XCebnB9gs)
- [This Zsh config is perhaps my favorite one yet](https://www.youtube.com/watch?v=ud7YxC33Z3w)
- [Five of my favorite project ideas to learn Go](https://www.youtube.com/watch?v=gXmznGEW9vo)

Thanks Elliott!

## TODO

- Figure a way to maybe import sensitive files that cannot go on GitHub.
- MultiMC, Crypto wallets?, veracrypt
- StreamDeck pages export/sync
