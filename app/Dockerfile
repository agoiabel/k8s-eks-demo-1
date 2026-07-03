# node:20-alpine — alpine is a minimal Linux base (~5MB vs ~100MB
# for the full Debian-based image). Smaller images pull faster,
# deploy faster, and expose less attack surface.
FROM node:20-alpine

# Create a non-root user to run the app.
# Running as root inside a container is a security risk:
# if an attacker escapes the app, they have root inside the container.
# This is a production requirement, not optional.
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copy package files BEFORE the source code.
# Docker builds images in layers and caches each one.
# node_modules changes only when package.json changes.
# Source code changes on every commit.
# By copying package files first and running npm ci before copying
# source, we get a cached npm ci layer that only rebuilds when
# dependencies actually change — not on every code change.
COPY package*.json ./
RUN npm ci --omit=dev

# Now copy the source code. This layer will rebuild on every
# code change, but npm ci above is already cached.
COPY --chown=appuser:appgroup . .

# Switch to the non-root user before the app starts.
USER appuser

EXPOSE 3000

# Array form prevents shell interpretation.
# Signal handling (graceful shutdown) works correctly
# when Node is PID 1 directly, not wrapped in a shell.
CMD ["node", "server.js"]