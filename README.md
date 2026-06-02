# go-clean-arch

A one-command scaffolder for Go backend projects following clean architecture conventions.
Runs as a global shell command — no Go install, no dependencies, just bash.

```bash
go-clean-arch web-streaming github.com/rafi/web-streaming
```

Generates a ready-to-run project with proper layering, sqlc config, env template, and a working `/health` endpoint.

---

## Why

Stop re-creating the same folder structure every new project. Stop forgetting `.gitignore`, `.env.example`, or `sqlc.yaml`. Start from a clean, opinionated baseline that matches production Go backend conventions.

Opinionated for:
- **Clean architecture** — `handler → service → repository → entity`
- **PostgreSQL + sqlc** — typed queries, no ORM magic
- **JWT auth ready** — access + refresh expiry already in env template
- **Redis-ready** — for token blacklist and rate limiting

---

## Install

```bash
git clone https://github.com/Restartor/go-clean-arch.git
cd go-clean-arch
bash install.sh
source ~/.bashrc   # or ~/.zshrc
```

The installer copies the script to `~/.local/bin/go-clean-arch` and adds it to your `PATH`. No sudo, no system-wide changes.

---

## Usage

```bash
go-clean-arch <project-name> [module-path]
```

**Examples:**

```bash
# minimal — module path defaults to github.com/youruser/<project-name>
go-clean-arch my-api

# with explicit module path
go-clean-arch web-streaming github.com/rafi/web-streaming
```

After scaffolding:

```bash
cd web-streaming
cp .env.example .env
go mod tidy
go run ./cmd/api
# → Server running on :8080
# → curl localhost:8080/health → {"status":"ok"}
```

---

## What gets generated

```
<project-name>/
├── cmd/
│   └── api/
│       └── main.go              # entrypoint with /health endpoint
├── internal/
│   ├── config/                  # env loading
│   ├── database/                # sqlc generated code + db connection
│   ├── handler/                 # HTTP handlers
│   ├── service/                 # business logic
│   ├── repository/              # data access
│   ├── middleware/              # JWT, rate limit, logger
│   ├── dto/                     # request/response shapes
│   ├── entity/                  # domain structs
│   ├── router/                  # route registration
│   ├── auth/                    # token generation/validation
│   ├── logger/                  # structured logger
│   └── response/                # unified response helpers
├── migrations/                  # .sql migration files
├── queries/                     # .sql query files for sqlc
├── sqlc.yaml                    # sqlc configuration
├── go.mod
├── .env.example                 # env template
├── .gitignore
└── README.md
```

---

## Layer responsibilities

| Layer | Responsibility | Depends on |
|---|---|---|
| `handler` | Parse HTTP, call service, return response | `service`, `dto`, `response` |
| `service` | Business logic, validation, orchestration | `repository`, `entity` |
| `repository` | Data access only — no logic | `database`, `entity` |
| `entity` | Pure domain structs | nothing |
| `dto` | API request/response shapes | nothing |

Dependencies always point **inward**. Inner layers never know about outer layers.

---

## Requirements

- bash or zsh
- Go 1.22+ (for the generated project, not the scaffolder)

---

## Customization

The script is a single bash file (`go-clean-arch.sh`). Fork it, edit the heredoc sections to match your own conventions — different Go version, different default port, extra layers, your own README template, etc.

---

## Uninstall

```bash
rm ~/.local/bin/go-clean-arch
```

Then remove the PATH line from your `~/.bashrc` or `~/.zshrc` if you no longer need it.

---

## License

MIT
