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

