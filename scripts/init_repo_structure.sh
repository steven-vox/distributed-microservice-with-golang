#!/usr/bin/env bash
set -euo pipefail

# init_repo_structure.sh
# Creates the canonical monorepo directory layout for the ride-sharing project.
# Usage:
#   chmod +x scripts/init_repo_structure.sh
#   ./scripts/init_repo_structure.sh

ROOT_DIR="${1:-.}"

mkdir_p() {
  # create dir and a .gitkeep file so git will track empty dirs
  local dir="$1"
  if [ ! -d "$dir" ]; then
    mkdir -p "$dir"
    echo "# placeholder" > "${dir}/.gitkeep"
    printf "created: %s\n" "$dir"
  else
    # ensure .gitkeep exists
    if [ ! -f "${dir}/.gitkeep" ]; then
      echo "# placeholder" > "${dir}/.gitkeep"
      printf "updated: %s (.gitkeep added)\n" "$dir"
    else
      printf "exists:  %s\n" "$dir"
    fi
  fi
}

# Top-level
mkdir_p "${ROOT_DIR}/infra"
mkdir_p "${ROOT_DIR}/proto"
mkdir_p "${ROOT_DIR}/scripts"
mkdir_p "${ROOT_DIR}/tools"
mkdir_p "${ROOT_DIR}/shared"
mkdir_p "${ROOT_DIR}/tests"
mkdir_p "${ROOT_DIR}/.github/workflows"

# shared subdirs
mkdir_p "${ROOT_DIR}/shared/logging"
mkdir_p "${ROOT_DIR}/shared/config"
mkdir_p "${ROOT_DIR}/shared/health"

# services tree
mkdir_p "${ROOT_DIR}/services/gateway/cmd"
mkdir_p "${ROOT_DIR}/services/gateway/internal"
mkdir_p "${ROOT_DIR}/services/gateway/pkg"

mkdir_p "${ROOT_DIR}/services/trip-service/cmd"
mkdir_p "${ROOT_DIR}/services/trip-service/internal"
mkdir_p "${ROOT_DIR}/services/trip-service/pkg"

mkdir_p "${ROOT_DIR}/services/driver-service/cmd"
mkdir_p "${ROOT_DIR}/services/driver-service/internal"
mkdir_p "${ROOT_DIR}/services/driver-service/pkg"

mkdir_p "${ROOT_DIR}/services/auth-service/cmd"
mkdir_p "${ROOT_DIR}/services/auth-service/internal"
mkdir_p "${ROOT_DIR}/services/auth-service/pkg"

# infra subdirs (k8s, terraform, tilt)
mkdir_p "${ROOT_DIR}/infra/k8s"
mkdir_p "${ROOT_DIR}/infra/terraform"
mkdir_p "${ROOT_DIR}/infra/tilt"

# scripts placeholder files
if [ ! -f "${ROOT_DIR}/scripts/gen_proto.sh" ]; then
  cat > "${ROOT_DIR}/scripts/gen_proto.sh" <<'EOF'
#!/usr/bin/env bash
# gen_proto.sh - regenerate go protobuf stubs (example skeleton)
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "This is a placeholder script. Add protoc generation commands here."
# Example:
# protoc -I "${ROOT_DIR}/proto" \
#   --go_out="${ROOT_DIR}/shared" --go_opt=paths=source_relative \
#   --go-grpc_out="${ROOT_DIR}/shared" --go-grpc_opt=paths=source_relative \
#   "${ROOT_DIR}/proto/"*.proto

EOF
  chmod +x "${ROOT_DIR}/scripts/gen_proto.sh"
  printf "created: %s\n" "${ROOT_DIR}/scripts/gen_proto.sh"
else
  printf "exists:  %s\n" "${ROOT_DIR}/scripts/gen_proto.sh"
fi

# top-level sample files
if [ ! -f "${ROOT_DIR}/Makefile" ]; then
  cat > "${ROOT_DIR}/Makefile" <<'EOF'
.PHONY: lint test proto-gen

lint:
	golangci-lint run ./...

test:
	go test ./... -v

proto-gen:
	./scripts/gen_proto.sh
EOF
  printf "created: %s\n" "${ROOT_DIR}/Makefile"
fi

if [ ! -f "${ROOT_DIR}/.golangci.yml" ]; then
  cat > "${ROOT_DIR}/.golangci.yml" <<'EOF'
run:
  timeout: 5m

linters:
  enable:
    - govet
    - staticcheck
    - errcheck
    - gofmt
    - ineffassign

issues:
  exclude-use-default: false
EOF
  printf "created: %s\n" "${ROOT_DIR}/.golangci.yml"
fi

echo "Initialization complete."
