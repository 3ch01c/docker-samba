# docker-samba
A daemonizable Samba container

This project is based off [stanback/alpine-samba](https://github.com/Stanback/alpine-samba). I improved it by:

* Streamlining the user account and share creation processes into the runtime initialization
* Providing a Raspberry Pi-friendy armhf build
* Providing a docker-compose file
* Daemonizing it for systemd

<a name="quickstart"></a>
## Quick(est) Start

If you are using a Raspberry Pi or other arm device, specify the `armhf` image in `docker-compose.yml`.
```
    image: 3ch01c/alpine-samba:armhf
```
Otherwise, use the `amd64` image for 64-bit processors.
```
    image: 3ch01c/alpine-samba:amd64
```

Specify a Samba user and password in `me.env`. Note this is currenty only designed for a single set of user credentials.
```
SMB_USER=me
SMB_PASSWORD=mypassword
```
You can rename this file however you like, but you must also reflect those changes under `env_file` in `docker-compose.yml`.
```
    env_file:
      - me.env
```
Verify the `volumes` specified in `docker-compose.yml` are correct.
```
    volumes:
      - ./smb.conf:/etc/samba/smb.conf
      - ./shares/mystuff:/shares/mystuff
```
You can rename these share directories however you like, but you must also reflect those changes in `smb.conf`. Note the configuration must match the paths specified in the container (e.g. `/shares/mystuff`), not the host `./shares/mystuff`.
```
[mystuff]
  path = /shares/mystuff
  comment = My stuff
  browseable = yes
  writable = yes
  valid users = me
```
You can also use symlinks to share data from outside the project directory.
```
ln -s shares/myusbdrive /media/pi/myusbddrive
```
Finally, start it up.
```
docker-compose -f /path/to/docker-compose.yml up
```
If everything works, consider <a href="#daemonization">daemonizing the process</a> with the supplied `samba.service` file. If everything doesn't work, head over to the <a href="#troubleshooting">troubleshooting</a> section.

<a name="daemonization"></a>
## Daemonization (systemd)
Copy `samba.service` to `/etc/systemd/system` and enable it to start now and on boot.
```
sudo systemctl start samba
sudo systemctl enable samba
```
If you have shares on volumes that mount after the Samba daemon starts, the daemon will fail to start. To avoid this, configure the daemon to wait until they are mounted using the `After` directive. The provided `samba.service` has an example of waiting for the USB drive `myusbdrive` to mount before starting the daemon.
```
After=media-myusbdrive.mount
```
Ensure the target name matches the name of the volume you're waiting on to mount.

The provided `samba.service` expects the project to be at `/srv/samba`. If you downloaded it somewhere else, correct the path to `docker-compose.yml` in the `ExecStart` and `ExecStop` directives.
```
ExecStart=/usr/local/bin/docker-compose -f /srv/samba/docker-compose.yml up
ExecStop=/usr/local/bin/docker-compose -f /srv/samba/docker-compose.yml stop
```

<a name="troubleshooting"></a>
## Troubleshooting
I have nothing to put here right now, but if you have trouble to shoot, feel free to <a href="https://github.com/3ch01c/docker-samba/issues">create a ticket</a>.
