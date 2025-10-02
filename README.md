# Ride Sharing (Monorepo) - with Golang

Project overview

Ride Sharing is a microservices sample project implemented in Go. This monorepo contains multiple services, shared libraries, proto definitions and infrastructure manifests for local development and deployment to Kubernetes. The repository aims to be a clean, production-minded starting point for learning and building microservice systems.

Goals

Clear, consistent repository layout for microservices

Contract-first APIs using Protocol Buffers

Per-service Go modules for dependency isolation

Shared utilities (logging, config, healthchecks) in a single place

CI pipeline for linting, testing and builds

Simple developer experience for local dev and integration testing

Proposed repository structure
```
/ (root)
├─ README.md
├─ infra/                      # k8s / terraform / manifests / tilt
├─ proto/                      # .proto files + generation rules
├─ scripts/                    # helper scripts (db migrations, generate.sh)
├─ tools/                      # Dockerfile base, helper images
├─ shared/                     # shared go packages (logging, config, health)
│   ├─ logging/
│   ├─ config/
│   └─ health/
├─ services/
│   ├─ gateway/
│   │   └─ go.mod
│   ├─ trip-service/
│   │   ├─ cmd/
│   │   ├─ internal/
│   │   └─ go.mod
│   ├─ driver-service/
│   └─ auth-service/
├─ tests/                      # integration / e2e tests (kind/k3d or docker-compose)
├─ .golangci.yml
├─ Makefile
└─ .github/workflows/ci.yml
```

Quickstart (developer)

Clone the repository:
```
git clone <repo-url>
cd ride-sharing
```

Create the directory layout (or run the helper script provided in scripts/):
```
./scripts/init_repo_structure.sh
```

Install dev tools you plan to use:

- Go (1.20+ recommended)
- golangci-lint
- protoc + protoc-gen-go + protoc-gen-go-grpc
- Docker / kind / k3d (optional)

Generate protobuf stubs (example):
```
./scripts/gen_proto.sh
```

Run lint & tests:
```
make lint
make test
```

Build & Docker

Each service is intended to be buildable independently as a Go module. Example (service located at services/trip-service):

```
cd services/trip-service
go build ./...
# or build docker image using the Dockerfile in that service
docker build -t myrepo/trip-service:local .
```

Proto / Contract rules

Keep all .proto files under proto/.

The proto/ directory is the single source of truth for service contracts.

Use scripts/gen_proto.sh to regenerate Go code into the services or a shared generated module.

Use semantic versioning for changes that break compatibility.

CI / GitHub Actions

A recommended CI should:

Run gofmt and golangci-lint
```
Run go test ./... -cover
```

Build service binaries (or build-and-scan images on release)

Optionally run integration tests for critical flows

A sample GitHub Actions workflow is included in .github/workflows/ci.yml (or will be added as part of the repo standardization PR).

Conventions & best practices (short)

Use Context (context.Context) for request-scoped info and cancellation.

Separate layers: transport (http/grpc) → service (business) → repo (persistence).

Do not keep business logic in main.

Structured JSON logging (e.g., zerolog/logrus) and health/metrics endpoints.

Prefer generated code from proto/ over duplicated DTOs.

Testing

Unit tests are required for business logic (mock repository interfaces).

Integration tests live under tests/ and use a containerized infra stack (Postgres, Redis).

Contract tests to ensure proto compatibility across versions.

Migration plan (high-level)

Add root linting & Makefile.

Create shared/ module and move common util code.

Consolidate .proto files into proto/ and add generation script.

Add GitHub Actions CI for lint & test.

Incrementally add tests & observability.

Contributing

Fork and create feature branches for changes.

Ensure gofmt, go vet and golangci-lint pass locally.

Add tests for new logic and update docs when changing behavior.

Open PRs against main with clear description and rationale.

License

Add your project license here (e.g., MIT, Apache-2.0). Update LICENSE file at repo root.

If you want, I can:

Add a .golangci.yml, Makefile and a GitHub Actions CI workflow and prepare a sample PR.

Migrate the first service (trip-service) to the proposed structure and show a diff.
Tell me which to do next and I’ll prepare the files.