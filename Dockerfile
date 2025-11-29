# Stage 1: Build avec une version d'Alpine plus ancienne
FROM alpine:3.15 AS builder
# Installer les dépendances nécessaires
RUN apk add --no-cache musl-dev rust cargo
# Ajouter une dépendance vulnérable pour tester Trivy
RUN apk add --no-cache openssl=1.1.1l-r0  # Version vulnérable à CVE-2021-3711

WORKDIR /app

# Copy manifests
COPY Cargo.toml Cargo.lock ./

# Copy source code
COPY src ./src

# Build the application with static linking
RUN cargo build --release --target x86_64-unknown-linux-musl

# Stage 2: Runtime (scratch)
FROM scratch

# Copy the binary from builder
COPY --from=builder /app/target/x86_64-unknown-linux-musl/release/test-ci /test-ci

# Set the entrypoint
ENTRYPOINT ["/test-ci"]
