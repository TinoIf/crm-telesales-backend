# CRM Telesales — Backend API

Backend REST API untuk sistem CRM Telemarketing, dibangun untuk menstandarisasi operasional telesales, mencegah double contact, dan menggantikan pelaporan manual spreadsheet.

## Tech Stack

| Technology | Purpose |
|-----------|---------|
| **Go 1.22+** | Backend language |
| **Gin** | HTTP framework & router |
| **PostgreSQL 15** | Database |
| **pgx** | PostgreSQL driver |
| **golang-jwt** | JWT authentication |
| **bcrypt** | Password hashing |
| **Docker** | Database container |

## Prerequisites

- [Go 1.22+](https://go.dev/dl/)
- [Docker & Docker Compose](https://www.docker.com/products/docker-desktop/)
- [Git](https://git-scm.com/)

## Quick Start

```bash
# 1. Clone repository
git clone https://github.com/USERNAME/crm-telesales-backend.git
cd crm-telesales-backend

# 2. Setup environment
cp .env.example .env

# 3. Start database
docker compose up -d

# 4. Run server
go run cmd/api/main.go

# 5. Verify
curl http://localhost:8080/api/v1/health
```

## Project Structure

```
crm-telesales-backend/
├── cmd/api/              # Entry point aplikasi
├── internal/
│   ├── config/           # Environment & configuration
│   ├── handler/          # HTTP request handlers
│   ├── service/          # Business logic
│   ├── repository/       # Database queries
│   ├── middleware/        # Auth & RBAC middleware
│   └── model/            # Data structures
├── database/             # SQL migrations
├── docker-compose.yml    # PostgreSQL container
├── .env.example          # Environment template
└── go.mod
```

## API Overview

Base URL: `http://localhost:8080/api/v1`

| Module | Endpoints |
|--------|:---------:|
| Auth | 2 |
| Users | 5 |
| Companies | 8 |
| Contacts | 9 |
| Reports | 3 |

> Dokumentasi lengkap: lihat API Specification di Jira.

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `DB_HOST` | Database host | `localhost` |
| `DB_PORT` | Database port | `5432` |
| `DB_NAME` | Database name | `crm_telemarketing` |
| `DB_USER` | Database user | `crm_admin` |
| `DB_PASSWORD` | Database password | — |
| `PORT` | Server port | `8080` |
| `JWT_SECRET` | JWT signing key | — |
| `JWT_EXPIRY_HOURS` | Token expiry | `24` |

## Related Repositories

- **Frontend:** [crm-telesales-frontend](https://github.com/USERNAME/crm-telesales-frontend)
