adduser -s /sbin/nologin -h /home/samba -H -D "$SAMBA_USER"
echo -e "$SAMBA_PASSWORD\n$SAMBA_PASSWORD" | smbpasswd -a "$SAMBA_USER"
smbd --foreground --log-stdout --no-process-group
