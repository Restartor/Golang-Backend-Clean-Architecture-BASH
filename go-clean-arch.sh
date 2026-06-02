#!/bin/bash

# ─────────────────────────────────────────────
#  go-clean-arch — scaffold a Go clean arch project
#  Usage: go-clean-arch <project-name> [module-path]
#  Example: go-clean-arch web-streaming github.com/youruser/web-streaming
# ─────────────────────────────────────────────

set -e  # exit immediately if any command fails

# ── 1. Args & validation ──────────────────────
PROJECT_NAME=${1:-"backend"}
MODULE_PATH=${2:-"github.com/youruser/$PROJECT_NAME"}

if [ -d "$PROJECT_NAME" ]; then
  echo "❌  Directory '$PROJECT_NAME' already exists. Aborting."
  exit 1
fi

echo "🚀  Scaffolding: $PROJECT_NAME"
echo "📦  Module: $MODULE_PATH"
echo ""

# ── 2. Create all directories ─────────────────
mkdir -p "$PROJECT_NAME"/{cmd/api,migrations,queries}
mkdir -p "$PROJECT_NAME"/internal/{config,database,handler,service,repository,middleware,dto,entity,router,auth,logger,response}

# ── 3. main.go ───────────────────────────────
cat > "$PROJECT_NAME/cmd/api/main.go" <<EOF
package main

import (
	"fmt"
	"log"
	"net/http"
)

func main() {
	mux := http.NewServeMux()
	mux.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		fmt.Fprintln(w, \`{"status":"ok"}\`)
	})

	log.Println("Server running on :8080")
	if err := http.ListenAndServe(":8080", mux); err != nil {
		log.Fatal(err)
	}
}
EOF

# ── 4. go.mod ────────────────────────────────
cat > "$PROJECT_NAME/go.mod" <<EOF
module $MODULE_PATH

go 1.22
EOF

# ── 5. sqlc.yaml ─────────────────────────────
cat > "$PROJECT_NAME/sqlc.yaml" <<EOF
version: "2"
sql:
  - engine: "postgresql"
    queries: "./queries"
    schema: "./migrations"
    gen:
      go:
        package: "db"
        out: "./internal/database"
        emit_json_tags: true
        emit_interface: true
EOF

# ── 6. .env.example ──────────────────────────
cat > "$PROJECT_NAME/.env.example" <<EOF
APP_PORT=8080
APP_ENV=development

DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=secret
DB_NAME=$PROJECT_NAME

JWT_SECRET=change-this-secret
JWT_ACCESS_EXPIRY=15m
JWT_REFRESH_EXPIRY=7d

REDIS_ADDR=localhost:6379
EOF

# ── 7. .gitignore ─────────────────────────────
cat > "$PROJECT_NAME/.gitignore" <<EOF
.env
*.log
/bin/
/tmp/
EOF

# ── 8. README.md ─────────────────────────────
cat > "$PROJECT_NAME/README.md" <<EOF
# $PROJECT_NAME

## Stack
- Go + Gin
- PostgreSQL (sqlc)
- JWT auth (access + refresh)
- Redis (token blacklist / rate limit)

## Structure
\`\`\`
cmd/api/         → entrypoint
internal/
  config/        → env loading
  database/      → sqlc generated + db conn
  entity/        → domain structs
  dto/           → request/response shapes
  repository/    → data access layer
  service/       → business logic
  handler/       → HTTP handlers
  router/        → route registration
  middleware/    → JWT, rate limit, logger
  auth/          → token generation/validation
  logger/        → structured logger setup
  response/      → unified response helpers
migrations/      → .sql migration files
queries/         → .sql query files for sqlc
\`\`\`

## Run
\`\`\`bash
cp .env.example .env
go run ./cmd/api
\`\`\`
EOF

# ── 9. Done ───────────────────────────────────
echo "✅  Done! Project created at ./$PROJECT_NAME"
echo ""
echo "Next steps:"
echo "  cd $PROJECT_NAME"
echo "  cp .env.example .env"
echo "  go mod tidy"
echo "  go run ./cmd/api"
