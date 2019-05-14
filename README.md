# docker-samba
A daemonizable Samba container

This project is based off [stanback/alpine-samba](https://github.com/Stanback/alpine-samba). I improved it by:

* Streamlining the user account and share creation processes into the runtime initialization
* Providing a Raspberry Pi-friendy armhf build
* Providing a docker-compose file
* Daemonizing it for systemd

## Quick(est) Start

If you are using a Raspberry Pi or other arm7+ device, specify the `armhf` image in `docker-compose.yml`.
```
    image: 3ch01c/alpine-samba:armhf
```
Otherwise, use the `amd64` image for 64-bit Intel processors.

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
Verify the `volumes` specified in `docker-compose.yml` exist. You can also use symlinks to other directories.
```
    volumes:
      - ./smb.conf:/etc/samba/smb.conf
      - ./shares/mystuff:/shares/mystuff
```
You can rename these share directories however you like, but you must also reflect those changes in `smb.conf`
```
[mystuff]
  path = /shares/mystuff
  comment = My stuff
  browseable = yes
  writable = yes
  valid users = me
```
Finally, start it up.
```
docker-compose -f /path/to/docker-compose.yml up
```
If everything works, consider daemonizing the process with the supplied `samba.service` file.

## Daemonization

If you have shares on volumes that mount after the Samba daemon starts, the daemon will fail to start. To avoid this, configure the daemon to wait until they are mounted using the `After` directive. The provided `samba.service` has an example of waiting for an external disk to mount before starting the daemon.
```
After=media-mydisk.mount
```
Ensure the name matches to name of the volume you're waiting on to mount (e.g. `mydisk`).

The provided `samba.service` expects the project to be at `/srv/samba`. If you downloaded it somewhere else, modify the `ExecStart` and `ExecStop` to find the `docker-compose.yml` accordingly.
```
ExecStart=/usr/local/bin/docker-compose -f /srv/samba/docker-compose.yml up 
ExecStop=/usr/local/bin/docker-compose -f /srv/samba/docker-compose.yml stop
```
If you have any other questions, don't hesistate to ask me.