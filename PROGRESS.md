# Progresso do Projeto BD

## Estrutura Atual

```
db/
├── AGENTS.md                  # Instruções específicas para agentes
├── Dockerfile                 # Imagem Postgres multi-stage (builder + runtime)
├── Makefile                   # Orquestra docker build/run/logs
├── PROGRESS.md                # Este arquivo
├── README.md                  # Como operar o container
├── migrations/000_init.sql    # Placeholder de schema
└── .env.example               # Variáveis suportadas
```

## Testes

Nenhum teste automatizado ainda. Próxima etapa: adicionar smoke-test que usa `psql` para validar conexão/migration (`make test`).

## Decisões de Arquitetura

- **Postgres 16-alpine:** imagem base para builder e runtime, garantindo compatibilidade com futuros operadores (streams lógicos, scram).
- **Migrations declarativas:** todos os arquivos ficam em `migrations/` e são copiados para `/docker-entrypoint-initdb.d` no build.
- **Variáveis `.env`:** `.env.example` documenta credenciais e destinos gRPC para manter containers sincronizados.
- **Rede compartilhada:** container deve viver na mesma network Docker dos serviços `backend`/`ocr`, permitindo comunicação indireta via gRPC.
- **Roles centralizados:** `migrations/001_create_roles.sql` cria o enum `role_name` (`admin|concierge|resident`) e tabela `roles` com `created_at`, permitindo reexecução manual sem falhar.
- **Usuários e status:** `migrations/002_create_users.sql` adiciona tabela `users` com FK para `roles`, enum `user_status` (`pending_approval|active`), índice em `role_id`, e comentários de documentação.
- **Unidades e relacionamento:** `migrations/003_create_units.sql` cria tabela `units` com constraint de unicidade `(tower, block, apartment)`; `004_create_users_units.sql` implementa o N:N com `ON DELETE CASCADE` e chave composta.
- **Sessões de entrega:** `migrations/005_create_delivery_sessions.sql` adiciona tabela `delivery_sessions` com enum `delivery_session_status`, regex constraint no `pickup_code`, e campos de rastreamento (`picked_up_by_user_id`, `completed_at`).
- **Verificação de entrega:** `migrations/006_alter_delivery_sessions_add_verification_fields.sql` inclui enum `delivery_verification_method` e colunas `document_type`, `document_number`, `override_reason` para auditoria de retirada manual.
- **Pacotes:** `migrations/007_create_packages.sql` cria tabela `packages` com enum `package_status`, FKs para `delivery_sessions`, `units` e `users`, e campos de auditoria (`received_at`, `picked_up_at`).
- **Sessões de recebimento:** `migrations/008_create_receipt_sessions.sql` adiciona tabela `receipt_sessions` com enum `receipt_session_status` e auditoria (`started_at`, `finalized_at`).
- **Pacotes vinculados a sessões:** `migrations/009_alter_packages_add_receipt_session_id.sql` inclui FK `receipt_session_id` na tabela `packages`.
- **Seleção de ambiente dinâmica:** Makefile agora escolhe automaticamente `.env.<ENVIRONMENT>`, `.env.local` ou `.env` ao rodar `make docker-run`.
- **Usuário do backend:** `migrations/010_create_backend_user.sql` cria role `backend_portaria_db_user` com permissões limitadas (CRUD + sequences) para acesso seguro pelo serviço backend.

## Próximos Passos

1. Escolher ferramenta de migração e adicionar scripts (ex.: `dbmate`, `sqitch`, `atlas`).
2. Criar `make test` que sobe o container em background e roda `psql -c 'SELECT 1'`.
3. Definir pipelines CI para lint (sqlfluff?) e migrações.
4. Documentar contrato gRPC que orquestrará operações com o banco.
