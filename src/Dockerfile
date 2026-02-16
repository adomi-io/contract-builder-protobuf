# syntax=docker/dockerfile:1

FROM python:3.11-slim

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PROTOC_WKT_INCLUDE=/usr/include

RUN apt-get update && apt-get install -y --no-install-recommends \
    protobuf-compiler \
    libprotobuf-dev \
    curl \
    git \
    bash \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Python plugins
RUN pip install --no-cache-dir --pre "betterproto[compiler]"

# Install Go plugins
COPY --from=golang:1.21-bullseye /usr/local/go/ /usr/local/go/

ENV PATH="/usr/local/go/bin:${PATH}"

RUN go install google.golang.org/protobuf/cmd/protoc-gen-go@latest \
    && go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

ENV PATH="${PATH}:/root/go/bin"

# Install TS plugin (requires node)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g ts-proto

WORKDIR /local

COPY ./src/generate.sh /local/generate.sh
RUN chmod +x /local/generate.sh

RUN mkdir -p /local/out

ENTRYPOINT ["/local/generate.sh"]
