# SABnzbd

SABnzbd Usenet downloader on FreeBSD.

| | |
|---|---|
| **Port** | 8080 |
| **Registry** | `ghcr.io/daemonless/sabnzbd` |
| **Source** | [https://github.com/sabnzbd/sabnzbd](https://github.com/sabnzbd/sabnzbd) |
| **Website** | [https://sabnzbd.org/](https://sabnzbd.org/) |

## Deployment

### Podman Compose

```yaml
services:
  sabnzbd:
    image: ghcr.io/daemonless/sabnzbd:latest
    container_name: sabnzbd
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=UTC
    volumes:
      - /path/to/containers/sabnzbd:/config
      - /path/to/downloads:/downloads
    ports:
      - 8080:8080
    restart: unless-stopped
```

### Podman CLI

```bash
podman run -d --name sabnzbd \
  -p 8080:8080 \
  -e PUID=@PUID@ \
  -e PGID=@PGID@ \
  -e TZ=@TZ@ \
  -v /path/to/containers/sabnzbd:/config \ 
  -v /path/to/downloads:/downloads \ 
  ghcr.io/daemonless/sabnzbd:latest
```
Access at: `http://localhost:8080`

### Ansible

```yaml
- name: Deploy sabnzbd
  containers.podman.podman_container:
    name: sabnzbd
    image: ghcr.io/daemonless/sabnzbd:latest
    state: started
    restart_policy: always
    env:
      PUID: "@PUID@"
      PGID: "@PGID@"
      TZ: "@TZ@"
    ports:
      - "8080:8080"
    volumes:
      - "/path/to/containers/sabnzbd:/config"
      - "/path/to/downloads:/downloads"
```

## Configuration
### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PUID` | `1000` | User ID for the application process |
| `PGID` | `1000` | Group ID for the application process |
| `TZ` | `UTC` | Timezone for the container |
### Volumes

| Path | Description |
|------|-------------|
| `/config` | Configuration directory |
| `/downloads` | Download directory |
### Ports

| Port | Protocol | Description |
|------|----------|-------------|
| `8080` | TCP | Web UI |

## Notes

- **User:** `bsd` (UID/GID set via PUID/PGID)
- **Base:** Built on `ghcr.io/daemonless/base` (FreeBSD)