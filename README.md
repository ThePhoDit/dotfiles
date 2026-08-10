# Configuration guide for MY Fedora Sway setup

> [!IMPORTANT]
> Install Nvidia drivers if needed: https://github.com/fady-saied/Nvidia-Fedora-Guide

1. Git clone this repo in your $HOME
2. Run the `setup_scripts/setup.sh` script
3. Join de ZeroTier networks and set the interface name in `/var/lib/zerotier-one/devicemap`

```
network_id=interface_name
```

4. Setup external disks as needed in fstab
5. Setup syncthing
6. Setup git credentials
7. Setup `.ssh/config` (backed up in syncthing)
8. Create ssh keys
9. Configure ublock filter lists. Enable it all but cookie notices, social widgets, regions and experimental lists
10. Install rest of extensions:
	- XBrowserSync
	- LibRedirect
	- Sidebery
11. Enable access to all devices for LibreWolf in Flatseal
12. Enable access to all devices for Ungoogled Chromium in Flatseal
13. Import Sidebery settings (`other_files/sidebery.json`)
14. Disable LibreWolf's navbar:
	1. Enable `toolkit.legacyUserProfileCustomizations.stylesheets` in about:config.
	2. In 'Profile Directory' (`Firefox Menu > Help > Troubleshooting Information > Profile Directory`) create folder chrome with file `other_files/userChrome.css`. Note that the profile folder might not be directly opened, but the directory with all profiles. Choose correctly.
15. If needed, configure restic backups (files not in repo, but syncthing)
