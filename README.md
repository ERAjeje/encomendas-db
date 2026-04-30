# Banco de Dados (PostgreSQL)

Container dedicado ao Postgres 16 que servirá como store central da plataforma de portaria. Este diretório contém apenas o bootstrap inicial – sem schema definitivo – para manter paridade de processo com os serviços `backend/` e `ocr/`.

## Objetivos

- Disponibilizar Postgres 16 com configuração mínima e scripts de inicialização versionados.
- Garantir que os serviços REST/gRPC (ex.: `backend`) possam alcançar o banco via rede interna Docker.
- Manter documentação operacional (`AGENTS.md`, `PROGRESS.md`) alinhada aos demais microsserviços.

## Pré-requisitos

- Docker 24+
- Make 4+

## Variáveis de Ambiente

Defina-as em `.env` (baseado em `.env.example`).

| Variável | Descrição | Default |
| --- | --- | --- |
| `POSTGRES_DB` | Nome do banco principal | `portaria` |
| `POSTGRES_USER` | Usuário administrador | `portaria_admin` |
| `POSTGRES_PASSWORD` | Senha do usuário | `changeme` |
| `POSTGRES_PORT` | Porta exposta local | `5432` |
| `POSTGRES_INIT_APP_DB` | Banco adicional para apps gRPC | `portaria_app` |
| `POSTGRES_GRPC_TARGET` | Endpoint gRPC do serviço que consumirá o DB | `backend:8080` |
| `BACKEND_DB_USER` | Usuário de aplicação para o backend | `backend_portaria_db_user` |
| `BACKEND_DB_PASSWORD` | Senha do usuário de aplicação | (definida em runtime) |

## Comandos

| Comando | Descrição |
| --- | --- |
| `make docker-build` | Build da imagem Postgres customizada |
| `make docker-run` | Sobe o container. Seleciona `.env.<ENVIRONMENT>`, `.env.local` ou `.env` automaticamente |
| `make docker-stop` | Interrompe o container se estiver rodando |
| `make logs` | Stream de logs do Postgres |
| `make psql` | Entra no container e abre `psql` para `POSTGRES_DB` |
| `make clean` | Remove container parado e diretório `data/` (se criado) |

Fluxo sugerido (análogas ao backend): `make docker-build` → `make docker-run` → (testes/migrations) → `make docker-stop`.

### Seleção de Ambiente
O Makefile escolhe automaticamente o arquivo `.env` com base na variável `ENVIRONMENT` (padrão: `development`):
- `development` → `.env.development` (fallback: `.env.local` → `.env`)
- `production` → `.env.production`
- Override: `make docker-run ENVIRONMENT=production`

## Estrutura

```
db/
├── AGENTS.md
├── Dockerfile
├── Makefile
├── PROGRESS.md
├── README.md
├── migrations/
│   └── 000_init.sql
└── .env.example
```

## Comunicação entre serviços

- O container deve compartilhar rede Docker com `backend`/`ocr`.
- As operações de dados serão expostas a partir de um serviço gRPC (a ser definido) que falará SQL com este Postgres e gRPC com os demais microsserviços.
- Documente novos contratos `.proto` e scripts de migração antes de qualquer alteração.

## Próximos passos

1. Definir ferramenta de migração (dbmate, Prisma, etc.).
2. Especificar contrato gRPC para operações de persistência.
3. Automatizar smoke-test (psql) dentro do pipeline (`make test`).

## Segurança

- **Credenciais:** nunca commitar `.env` real. Use `.env.example` como template.
- **Usuário de aplicação:** o backend deve usar `backend_portaria_db_user` com permissões limitadas (CRUD). Nunca use `portaria_admin` ou `postgres` superuser.
- **Rede:** em produção, o container não expõe a porta 5432 ao host; comunicação ocorre apenas via rede interna Docker.
- **Auditoria:** `postgresql.conf` habilita logging de conexões, desconexões e DDL.
- **Healthcheck:** Docker monitora automaticamente a saúde do Postgres via `pg_isready`.
- **Rotação de senhas:** em produção, atualize a senha em `.env.production` e rode `ALTER USER` via `psql` antes de reiniciar containers.
