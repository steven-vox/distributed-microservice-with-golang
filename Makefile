.PHONY: lint test proto-gen

lint:
	golangci-lint run ./...

test:
	go test ./... -v

proto-gen:
	./scripts/gen_proto.sh
