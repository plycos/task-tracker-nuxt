FROM node:22.17-alpine3.22 AS base

FROM base AS pnpm
RUN npm install -g pnpm@10.12.4

FROM pnpm AS dependencies
WORKDIR /app
COPY package.json .
COPY pnpm-lock.yaml .
RUN pnpm install

FROM dependencies AS build
WORKDIR /app
COPY nuxt.config.ts .
COPY eslint.config.mjs .
COPY tsconfig.json .
COPY public ./public
COPY server ./server
COPY app ./app
RUN pnpm run build

FROM base AS runtime

RUN addgroup -S appuser && adduser -S appuser -G appuser

WORKDIR /app
COPY --from=build /app/.output/ ./

RUN chown -R appuser:appuser /app
USER appuser

ENV PORT=80
ENV HOST=0.0.0.0

EXPOSE 80
CMD ["node", "/app/server/index.mjs"]