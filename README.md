# My Traccar Server

Self-hosted Traccar GPS tracking server for vehicle fleet management.

## Server

| Setting | Value |
|---|---|
| AWS Instance | af-server-2gb |
| Operating System | Ubuntu 24.04 LTS |
| RAM | 2 GB + 2 GB swap |
| Storage | 60 GB SSD |
| Region | AWS us-east-1 |
| Public IP | 3.82.184.210 |
| Domain | traccar.greg-smith.com |

## Software

- Traccar 6.17 — Docker
- MySQL 8.0 — native systemd service
- Caddy — HTTPS reverse proxy
- Docker Engine — Ubuntu package

## Directory Layout

**Git repository:** `/home/ubuntu/git/my_traccar`

**Production files:**

| Path | Purpose |
|---|---|
| `/opt/traccar/traccar.xml` | Live Traccar configuration (contains credentials) |
| `/opt/traccar/logs` | Application logs |
| `/opt/traccar/data` | Application data |
| `/etc/caddy/Caddyfile` | HTTPS reverse proxy |
| `/var/lib/mysql` | MySQL database |
| `/usr/local/sbin/backup_traccar.sh` | Installed database backup script |
| `/var/backups/traccar` | Compressed SQL backups |
| `/etc/systemd/system/backup_traccar.service` | Backup service |
| `/etc/systemd/system/backup_traccar.timer` | Backup schedule |

## Networking

- TCP 22 — SSH
- TCP 80 — HTTP (HTTPS redirects and certificate validation)
- TCP 443 — HTTPS
- TCP 8082 — Traccar web interface, localhost only
- TCP 3306 — MySQL, localhost and Docker bridge only

GPS device ports will be documented when configured.

## Database

Database: `traccar`

MySQL runs directly on Ubuntu under systemd.

Traccar connects to MySQL using Docker's host gateway at `172.17.0.1`.

Database credentials are stored outside Git.

## Backups

- Daily MySQL backups at 3 AM America/New_York
- Approximately 14 days of local retention
- Compressed SQL dumps in `/var/backups/traccar`
- Managed by a systemd service and timer
- Lightsail automatic instance snapshots also enabled

### Run backup manually

```bash
sudo systemctl start backup_traccar.service
```

### Check backup logs

```bash
sudo journalctl -u backup_traccar.service -n 50 --no-pager
```

### Check backup schedule

```bash
systemctl list-timers backup_traccar.timer
```

## Traccar Administration

### Container status

```bash
sudo docker ps
```

### Application logs

```bash
sudo docker logs --tail 100 traccar
```

### Restart Traccar

```bash
sudo docker restart traccar
```

### Restart MySQL

```bash
sudo systemctl restart mysql
```

### Restart Caddy

```bash
sudo systemctl restart caddy
```

## Deployment

The source-controlled deployment script is:

`scripts/deploy_traccar.sh`

It requires an existing live configuration at `/opt/traccar/traccar.xml`.

The deployment script refuses to replace an existing container. The database is not stored inside Docker.

## Disaster Recovery

Recovery requires:

1. An Ubuntu server with Docker, MySQL, and Caddy installed.
2. A copy of this repository.
3. A database backup.
4. The Traccar database credentials and configuration.
5. The necessary DNS and firewall configuration.

A complete database restoration procedure and off-server backups still need to be implemented and tested.

## Pending Work

- Configure GPS device protocol ports
- Configure off-server database backups
- Test database restoration
- Review security and monitoring
- Add a reproducible installation procedure
