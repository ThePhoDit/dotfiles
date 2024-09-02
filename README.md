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


## TODO

[] Install streamdeck and enable it to auto start.
[] Figure a way to maybe import sensitive files that cannot go on GitHub.
[] Zed settings sync
[] MultiMC, Crypto wallets?, veracrypt
