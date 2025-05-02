# Build stage
FROM golang:1.24-alpine AS builder
WORKDIR /app
COPY . .
RUN go mod init go-service || true
RUN CGO_ENABLED=0 GOOS=linux go build -o go-service ./cmd/main.go

# Test target
FROM golang:1.24.2-alpine AS test
WORKDIR /app
COPY . .
RUN go mod init go-service || true
CMD ["go", "test", "./tests/..."]


# Dev image (with air)
FROM golang:1.24.2-alpine  AS dev
WORKDIR /app

# Install air
RUN go install github.com/air-verse/air@latest
COPY go.mod go.sum ./
RUN go mod download
RUN go mod tidy
RUN go mod vendor

COPY . .

# Add air config (optional but recommended)
COPY .air.toml .

ENV ENV=dev
ENV PATH="$GOPATH/bin:$PATH"

CMD ["air", "-c", ".air.toml"]

# Staging target
FROM alpine:3.21 AS staging
WORKDIR /app
COPY --from=builder /app/go-service .
RUN apk add --no-cache ca-certificates
ENV ENV=staging
EXPOSE 8081
USER 1000
CMD ["./go-service"]

# Prod target
FROM alpine:3.21 AS prod
WORKDIR /app
COPY --from=builder /app/go-service .
RUN apk add --no-cache ca-certificates
ENV ENV=prod
EXPOSE 8081
USER 1000
CMD ["./go-service"]