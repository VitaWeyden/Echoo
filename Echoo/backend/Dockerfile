# ---- Build stage ----
FROM node:22-alpine AS builder

RUN apk add --no-cache python3 make g++

WORKDIR /app
COPY package*.json ./
RUN npm ci

COPY . .
RUN node ace build

# ---- Production stage ----
FROM node:22-alpine

RUN apk add --no-cache python3 make g++

WORKDIR /app
COPY --from=builder /app/build .
RUN npm ci --omit=dev

COPY entrypoint.sh ./
RUN chmod +x entrypoint.sh

EXPOSE 3333
ENTRYPOINT ["./entrypoint.sh"]
