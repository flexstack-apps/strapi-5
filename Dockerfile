ARG VERSION=20.17.0
ARG BUILDER=docker.io/library/node
FROM ${BUILDER}:${VERSION}-slim AS base
RUN apt-get update && apt-get install -y --no-install-recommends zlib1g-dev libpng-dev libvips-dev


FROM base AS deps
WORKDIR /app
COPY package.json package-lock.json*  ./
ARG NPM_MIRROR=
RUN if [ ! -z "${NPM_MIRROR}" ]; then npm config set registry ${NPM_MIRROR}; fi
RUN npm ci


FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules* ./node_modules
COPY . .
ENV NODE_ENV=production
RUN npm run build


FROM base AS runtime
WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends wget ca-certificates && apt-get clean && rm -f /var/lib/apt/lists/*_*
RUN update-ca-certificates 2>/dev/null || true
RUN addgroup --system nonroot && adduser --disabled-login --ingroup nonroot nonroot
RUN chown -R nonroot:nonroot /app
COPY --chown=nonroot:nonroot --from=builder /app .

USER nonroot:nonroot

ENV PORT=8080
EXPOSE ${PORT}
ENV NODE_ENV=production
ARG START_CMD="npm run start"
ENV START_CMD=${START_CMD}
RUN if [ -z "${START_CMD}" ]; then echo "Unable to detect a container start command" && exit 1; fi
CMD ${START_CMD}