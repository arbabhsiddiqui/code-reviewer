# Stage 1: Base
FROM node:24-bookworm AS base

# Install basic tools
RUN apt-get update && apt-get install -y \
    git \
    curl \
    bash \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Setup pnpm environment
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable && corepack prepare pnpm@latest --activate

WORKDIR /app

# Stage 2: Development (used for compose dev env)
FROM base AS development
ENV NODE_ENV=development
# Keep container running so you can shell in and run init commands
CMD ["tail", "-f", "/dev/null"]

# Stage 3: Builder (used for building production build)
FROM base AS builder
COPY package.json pnpm-lock.yaml* ./
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile
COPY . .
RUN pnpm build

# Stage 4: Production (final light-weight runtime)
FROM node:24-bookworm-slim AS production
ENV NODE_ENV=production
WORKDIR /app

# Install pnpm in production runner
RUN npm install -g pnpm

COPY package.json pnpm-lock.yaml* ./
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --prod --frozen-lockfile

COPY --from=builder /app/dist ./dist

CMD ["node", "dist/index.js"]
