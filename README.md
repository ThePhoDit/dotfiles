# Fedora Setup Guide

- Run the setup script from the home directory.
```bash
curl -O https://raw.githubusercontent.com/ThePhoDit/dotfiles/fedora/setup/setup.sh
chmod u+x setup.sh
bash setup.sh
```

- Setup Synthing folders.
- Setup ZeroTier.
	- Set interfaces names under `/var/lib/zerotier-one/devicemap` with the `networkID=interfaceName` format.
	- Join the networks.
	- Authorize the device.
- Download Librewolf extensions.
  - [Dark Reader](https://addons.mozilla.org/en-US/firefox/addon/darkreader)
  - [XBrowserSync](https://addons.mozilla.org/en-US/firefox/addon/xbs/)
  - [SponsorBlock](https://addons.mozilla.org/en-US/firefox/addon/sponsorblock/)
  - Enable all filters for UBlock Origin.
