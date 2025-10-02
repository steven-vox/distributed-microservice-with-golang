#!/usr/bin/env bash
set -euo pipefail

# scripts/init_go_modules_and_deps.sh
# Usage:
#   MODULE_BASE=github.com/yourusername/ride-sharing ./scripts/init_go_modules_and_deps.sh
# or
#   ./scripts/init_go_modules_and_deps.sh
#
# The script will:
#  - create go.mod for shared and services modules (if missing)
#  - add a core set of dependencies and run `go mod tidy`
#  - install protoc plugin binaries and golangci-lint into $(go env GOPATH)/bin
#
# Edit DEP_VERSIONS below if you want to pin specific versions.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# You can override MODULE_BASE by environment variable or pass as first arg
MODULE_BASE="${MODULE_BASE:-${1:-}}"
if [ -z "$MODULE_BASE" ]; then
  echo "No MODULE_BASE provided. Using default placeholder: /Users/stevenvo/Desktop/personal/distributed-microservice-with-golang"
  MODULE_BASE="github.com/steven-vox/distributed-microservice-with-golang"
  echo "If you'd like a different module path, re-run with:"
  echo "  MODULE_BASE=github.com/yourorg/ride-sharing $0"
  echo
fi

echo "Using MODULE_BASE = $MODULE_BASE"
echo "Working at repo root: $ROOT_DIR"
echo

# list of module folders to init
MODULE_PATHS=(
  "shared"
  "services/gateway"
  "services/trip-service"
  "services/driver-service"
  "services/auth-service"
)

# dependencies to add (module@version). You may change versions here.
# Use minimal set: logging, config, grpc/protobuf, gateway, testing
DEPS=(
  "github.com/rs/zerolog@latest"
  "github.com/spf13/viper@latest"
  "google.golang.org/grpc@latest"
  "google.golang.org/protobuf@latest"
  "github.com/grpc-ecosystem/grpc-gateway/v2@latest"
  "github.com/stretchr/testify@latest"
)

# protoc tools to install (binaries)
PROTO_TOOLS=(
  "google.golang.org/protobuf/cmd/protoc-gen-go@latest"
  "google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest"
  "github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway@latest"
)

# linters/tools
TOOLS=(
  "github.com/golangci/golangci-lint/cmd/golangci-lint@latest"
)

# helper: run in module dir
run_in_mod() {
  local dir="$1"
  shift
  (
    cd "$dir"
    echo "+ $* (in $(pwd))"
    eval "$@"
  )
}

# init modules
for m in "${MODULE_PATHS[@]}"; do
  moddir="$ROOT_DIR/$m"
  if [ ! -d "$moddir" ]; then
    echo "mkdir -p $moddir"
    mkdir -p "$moddir"
    # ensure .gitkeep if needed
    if [ ! -f "$moddir/.gitkeep" ]; then
      echo "# placeholder" > "$moddir/.gitkeep"
    fi
  fi

  # module name (module_base + path)
  # for shared -> ${MODULE_BASE}/shared
  # for services/gateway -> ${MODULE_BASE}/services/gateway
  module_name="${MODULE_BASE}/${m}"
  if [ ! -f "${moddir}/go.mod" ]; then
    echo "Initializing go module in $moddir as $module_name"
    run_in_mod "$moddir" "go mod init ${module_name}"
  else
    # If module exists, ensure module name is correct (simple check)
    existing_mod=$(sed -n '1s/module //p' "$moddir/go.mod" || true)
    if [ "$existing_mod" != "$module_name" ]; then
      echo "Warning: existing go.mod module name in $moddir is '$existing_mod' (expected $module_name)."
      echo "If you want to change it, edit $moddir/go.mod manually."
    else
      echo "go.mod exists and module is correct in $moddir"
    fi
  fi

  # add dependencies (for services; shared may only need a few)
  echo "Adding dependencies to $moddir (this may download modules)..."
  # use go get to add each dep
  for dep in "${DEPS[@]}"; do
    # in shared module we don't need grpc-gateway maybe; but adding is harmless
    run_in_mod "$moddir" "go get -d ${dep}"
  done

  # run tidy to clean up
  run_in_mod "$moddir" "go mod tidy"
done

# Install protoc plugin binaries and tools into GOPATH/bin
GOBIN="$(go env GOPATH 2>/dev/null)/bin"
if [ -z "$GOBIN" ] || [ "$GOBIN" = "" ]; then
  GOBIN="$(go env GOBIN 2>/dev/null || true)"
fi
if [ -z "$GOBIN" ]; then
  # fallback to GOPATH/bin
  GOBIN="$(go env GOPATH)/bin"
fi

echo
echo "Installing protoc tools to: $GOBIN"
mkdir -p "$GOBIN"

for t in "${PROTO_TOOLS[@]}"; do
  echo "go install ${t}"
  # shellcheck disable=SC2086
  GO111MODULE=on go install ${t}
done

for t in "${TOOLS[@]}"; do
  echo "go install ${t}"
  GO111MODULE=on go install ${t}
done

echo
echo "All done."
echo "Binaries installed to: $GOBIN"
echo
echo "Next steps (examples):"
echo "  - Add import/use of shared modules in services to wire things up."
echo "  - Generate proto stubs using scripts/gen_proto.sh (edit it to call protoc)."
echo "  - Run golangci-lint: ${GOBIN}/golangci-lint run ./..."
echo
echo "If you want me to also create example minimal main.go in one service (trip-service) and wire logger+config, say 'yes' and I'll generate it."
