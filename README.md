# Configuration guide for MY Fedora Sway setup

1. Git clone this repo in your $HOME
2. Run the `setup_scripts/install_sw.sh` script
3. Join de ZeroTier networks and set the interface name in `/var/lib/zerotier-one/devicemap`

```
network_id=interface_name
```

4. Setup syncthing
5. Setup git credentials
6. Setup `.ssh/config`
7. Create ssh keys
8. Configure ublock filter lists. Enable it all but cookie notices, social widgets, regions and experimental lists
9. Install rest of extensions:
	- XBrowserSync
	- LibRedirect
	- Sidebery
10. Enable access to all devices for LibreWolf in Flatseal
11. Enable access to all devices for Ungoogled Chromium in Flatseal
12. Import Sidebery settings
