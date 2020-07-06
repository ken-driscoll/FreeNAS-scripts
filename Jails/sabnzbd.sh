# Create the jail
iocage create -n "sabnzbd" -r 11.3-RELEASE ip4_addr="vnet0|192.168.1.151/24" defaultrouter=192.168.1.1 vnet="on" allow_raw_sockets="1" boot="on"

# Update to the latest repo
iocage exec sabnzbd "mkdir -p /usr/local/etc/pkg/repos"
iocage exec sabnzbd "echo -e 'FreeBSD: { url: \"pkg+http://pkg.FreeBSD.org/\${ABI}/latest\" }' > /usr/local/etc/pkg/repos/FreeBSD.conf"

# Install Sabnzbd and dependencies
iocage exec sabnzbd "pkg install -y sabnzbdplus ca_root_nss"

iocage exec sabnzbd "mkdir -p /config"
iocage exec sabnzbd "mkdir -p /downloads"
iocage fstab -a sabnzbd /mnt/system/app-configs/sabnzbd /config nullfs rw 0 0
iocage fstab -a sabnzbd /mnt/system/downloads /downloads nullfs rw 0 0
iocage fstab -a sabnzbd /mnt/tank/media /media nullfs rw 0 0

## Media Permissions
iocage exec sabnzbd "pw groupadd -n media -g 8675309"
iocage exec sabnzbd "pw user add media -c media -u 8675309 -d /nonexistent -s /usr/bin/nologin"
iocage exec sabnzbd "pw groupmod media -m _sabnzbd"
iocage exec sabnzbd "chown -R media:media /media /config /downloads /usr/local/share/sabnzbdplus"

# Enable service
iocage exec sabnzbd "sysrc sabnzbd_user=media"
iocage exec sabnzbd "sysrc sabnzbd_enable=YES"
iocage exec sabnzbd "sysrc sabnzbd_conf_dir=\"/config"\"
iocage exec sabnzbd "service sabnzbd start"


