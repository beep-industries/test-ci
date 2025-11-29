# Stage 1: Build
FROM rust:alpine AS builder

# Install musl-dev for static linking
RUN apk add --no-cache musl-dev
# Ajouter une dépendance vulnérable pour tester Trivy
RUN apk add --no-cache zlib=1.2.12-r3  # Version vulnérable à CVE-2022-37434

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
