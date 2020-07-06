# Create the jail
iocage create -n "plex" -r 11.3-RELEASE ip4_addr="vnet0|192.168.1.149/24" defaultrouter="192.168.1.1" vnet="on" allow_raw_sockets="1" boot="on" -b devfs_ruleset=10

# Update to the latest repo
iocage exec plex "mkdir -p /usr/local/etc/pkg/repos"
iocage exec plex "echo -e 'FreeBSD: { url: \"pkg+http://pkg.FreeBSD.org/\${ABI}/latest\" }' > /usr/local/etc/pkg/repos/FreeBSD.conf"

# Install Plex and dependencies
iocage exec plex "pkg install -y multimedia/libva-intel-driver multimedia/libva-intel-media-driver plexmediaserver-plexpass ca_root_nss"

# Mount storage
iocage exec plex "mkdir -p /config"
iocage fstab -a plex /mnt/system/app-configs/plex /config nullfs rw 0 0
iocage fstab -a plex /mnt/tank/media /media nullfs rw 0 0

# Set permissions
iocage exec plex "pw groupmod -n video -m plex"
iocage exec plex "chown -R plex:plex /config"

# Enable service
iocage exec plex "sysrc \"plexmediaserver_plexpass_enable=YES\""
iocage exec plex "sysrc plexmediaserver_plexpass_support_path=\"/config\""
iocage exec plex "service plexmediaserver_plexpass start"

# MANUAL STEP: Stop the jail and update devfs_ruleset to 10 (to enable hardware acceleration)