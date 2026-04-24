# Docker Review Criteria

## Dockerfile
- Running as root — missing `USER` directive for non-root execution
- `latest` tag used for base images — non-reproducible builds
- Missing `.dockerignore` — `node_modules`, `.git`, secrets copied into image
- `COPY . .` before dependency install — busts cache on every code change (install deps first, then copy source)
- Multi-stage build not used — dev dependencies and build tools in production image
- `apt-get install` without `--no-install-recommends` — bloated image
- `apt-get update` and `apt-get install` in separate `RUN` layers — stale package list cached
- Secrets passed as build args — visible in image history
- `ENTRYPOINT` vs `CMD` confusion — signals not forwarded properly with shell form
- Health check missing — orchestrators can't determine container health

## docker-compose.yml
- Ports exposed to host that should only be on internal network
- Missing `restart` policy — containers don't recover from crashes
- Volume mounts that expose host filesystem unnecessarily
- Environment variables with secrets — should use `secrets` or external vault
- Missing `depends_on` with health check conditions — services start before dependencies are ready
- Network configuration too permissive — all services on same network when they shouldn't be

## Security
- Base image with known vulnerabilities — check with `docker scout` or `trivy`
- Sensitive files (`.env`, keys, certs) not excluded from image
- Capabilities not dropped — `--cap-drop ALL` with only needed caps added back
- Read-only filesystem not enabled where possible (`--read-only`)
- Container running with `--privileged` without justification

## Performance
- Image size unnecessarily large — use Alpine or distroless base images
- Too many layers — combine related `RUN` commands
- Build cache not optimised — frequently changing layers should be last
- Missing `WORKDIR` — operating in root directory
