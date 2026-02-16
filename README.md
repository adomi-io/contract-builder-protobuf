> [!TIP]
> Looking for a way to manage your API contracts effortlessly?
> Check out our community-driven tools for Odoo and beyond.
>
> **[adomi-io](https://github.com/adomi-io)**.

<p align="center">
  <img src="docs/static/logo.png" width="240" />
</p>

# 📜 Contract Builder - Protobuf 🏗️

A tool to turn your Protocol Buffer definitions into working code. Drop your `.proto` files in, and the builder automatically generates clients and types for your favorite languages.

Under the hood, this repo uses `protoc` wrapped in Docker, including support for Betterproto, Go, and TypeScript, making it easy to keep your services in sync without manual boilerplate.

## Highlights

- 🌍 Support for **multiple** targets (Python, Betterproto, Go, TypeScript)
- 📂 **Multi-service support**: Automatically scans the `specs` folder for all your services
- 🐳 **Fully Dockerized**: No need to install `protoc` or plugins locally
- 🔄 **Consistent Output**: Ensures your whole team generates the exact same code
- 🚀 **Fast Iteration**: Quickly design your data models and see the code update instantly

## What you can do

- Keep a single source of truth for your service contracts
- Generate multiple clients (including Betterproto) in one go
- Ensure your frontend types always match your backend Protobuf definitions
- Quickly iterate on service designs and see the code update instantly

To generate clients, just drop your Protobuf files into the `specs` folder and run the builder.

# Getting started

> [!WARNING]
> This tool is designed to run via Docker.
> It keeps your environment clean and ensures everyone on your team gets the exact same code output.
>
>**[Download Docker Desktop](https://www.docker.com/products/docker-desktop/)**

# Docker Compose

The easiest way to use this is with `docker-compose`. It mounts your local folders so the generated code appears right on your machine.

See the [docker](./docker) folder for more information.

Copy the files in the [docker](./docker) folder to your project root, or run the commands from within that folder.

**Place your specs**

Put your `.proto` files in subfolders under `specs/` (e.g., `specs/petshop/pet.proto`). The subfolder name determines the output name.

**Run the generator**

```bash
docker compose up
```

**Find your code**

Check the `out/` directory for your generated clients.

# Adding new targets

The logic lives in `src/generate.sh`, which uses the `GENERATORS` environment variable to determine which clients to build.

When using the provided `docker-compose.yml`, it defaults to `python,betterproto,go,typescript`.

## Update docker-compose.yml

Edit the `environment` section in your `docker-compose.yml`:

```yaml
environment:
  - GENERATORS=python,betterproto,go,typescript
```

## Run with an environment variable

You can also pass it directly to Docker:

```bash
docker run --rm -e GENERATORS="python,go" -v $(pwd)/specs:/local/src -v $(pwd)/out:/local/out contract-builder-protobuf
```

### Additional Options

You can pass additional arguments to `protoc` for specific generators using environment variables. This follows the naming convention `GENERATOR_{LANGUAGE}_ARGS`.

By default, the script calls `protoc` with `--{language}_out=...`. Use the `GENERATORS` list to specify the plugin name (e.g., `python_betterproto`, `ts_proto`, or just `go`).

For example, to pass options to the `go` generator or use `betterproto`:

```yaml
environment:
  - GENERATORS=go,python_betterproto
  - GENERATOR_GO_ARGS=--go-grpc_out=/local/out/petshop/go --go_opt=paths=source_relative
  - GENERATOR_PYTHON_BETTERPROTO_ARGS=--python_betterproto_opt=unwrapped
```

The language name is converted to uppercase, and hyphens are replaced with underscores.

## Typical data flow

- Developer updates `specs`
- `docker compose up` is run
- The generator container starts, scans `specs/`, and runs `generate.sh`
- New code is written to `out/petshop/python`, `out/petshop/betterproto`, `out/petshop/go`, etc., depending on your `GENERATORS` setting.
- You can use the resulting code in your project.

# Running from source

Clone this repository and open a terminal in the root directory.

## Build the application

> [!TIP]
> You can also run `docker compose up --build`.

Run `docker compose build`

## Run the application

Run the application by running

`docker compose up`

## About Adomi

Contract Builder is an Adomi project. We build helpful tools for modern development workflows. If you have ideas or run into issues, feel free to open an issue or suggestion.
