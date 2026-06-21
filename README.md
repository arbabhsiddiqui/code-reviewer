# Development Environment Setup

This project uses Docker and VS Code Dev Containers for a consistent development experience across macOS and WSL/Linux.

## Prerequisites

- **Docker Desktop** (macOS/Windows) or **Docker Engine** (Linux)
- **Docker Compose** v2.0+
- **VS Code** with [Remote - Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extension

## Quick Start

### 1. Start Services
```bash
docker-compose up -d
```

This starts:
- **PostgreSQL 16** on `localhost:5432`
- **Mailhog** UI on `localhost:8025` (SMTP on port 1025)
- **Development container** (app service)

### 2. Open in VS Code Dev Container

1. Open the project root in VS Code
2. Click the Remote Indicator (bottom-left corner) → **"Reopen in Container"**
3. VS Code will rebuild the dev container and automatically run `npm install`

Alternatively, use the command palette:
```
Ctrl+Shift+P (or Cmd+Shift+P) → "Dev Containers: Reopen in Container"
```

### 3. Run Development Server

Once inside the container terminal:

```bash
npm run dev
```

VS Code will automatically forward port 3000. Open the forwarded URL in your browser.

## Database Access

### Connect via psql
```bash
psql postgresql://postgres:postgres@localhost:5432/app_dev
```

### Connection String
```
DATABASE_URL=postgresql://postgres:postgres@postgres:5432/app_dev
```

The connection string inside the container uses the service name `postgres` instead of `localhost`.

## Email Testing (Mailhog)

- **SMTP Host**: `mailhog` (inside container) or `localhost` (from host)
- **SMTP Port**: `1025`
- **Web UI**: http://localhost:8025

Configure your app to use these credentials for development.

## ⚠️ Important WSL 2 Notes

If you're on **Windows with WSL 2**:

### 1. Use Native WSL File System
**DO NOT** store your project in `/mnt/c/...` (Windows mount). This causes severe performance degradation and hot-reload failures.

Instead, clone/store your project **inside** WSL:
```bash
cd ~
mkdir -p projects
cd projects
git clone <your-repo>
```

Access it via `\\wsl$\Ubuntu\home\<user>\projects\...` in Windows Explorer if needed.

### 2. Bind Servers to 0.0.0.0
When running development servers (Next.js, etc.), ensure they bind to **all interfaces**:

```bash
npm run dev -- --host 0.0.0.0
```

**DO NOT** use `127.0.0.1` or `localhost` only. Port forwarding requires binding to `0.0.0.0` to work properly on WSL.

## Common Commands

```bash
# View logs
docker-compose logs -f app

# Access app container shell
docker-compose exec app sh

# Stop all services
docker-compose down

# Rebuild containers
docker-compose down && docker-compose up -d

# View database
docker-compose exec postgres psql -U postgres -d app_dev
```

## Troubleshooting

### Port Already in Use
If ports 3000, 5432, or 8025 are already in use:
```bash
docker-compose down
# Or map to different host ports in docker-compose.yml
```

### Hot-reload Not Working
- Ensure you're in native WSL filesystem (not `/mnt/c/...`)
- Verify the server is binding to `0.0.0.0`
- Check that volumes in `docker-compose.yml` are mounted correctly

### Permission Issues on Linux/WSL
The dev container runs as the `node` user. If you experience permission issues:
```bash
docker-compose down
docker-compose up -d
# Permissions are auto-mapped via updateRemoteUserUID
```

## Environment Configuration

The dev container automatically loads:
```
NODE_ENV=development
DATABASE_URL=postgresql://postgres:postgres@postgres:5432/app_dev
SMTP_HOST=mailhog
SMTP_PORT=1025
```

Add additional variables to `docker-compose.yml` under the `app` service's `environment` section.
