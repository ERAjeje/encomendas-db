# Banco de Dados – Agent Notes

Postgres 16 container responsável por armazenar dados consumidos via gRPC pelos demais serviços. Use este guia para evitar passos implícitos.

## Regras Essenciais
- **TDD adaptado:** toda mudança de schema deve vir acompanhada de testes automatizados (smoke `psql`, migrações dry-run ou testes do serviço que consome o DB). Comece escrevendo o verificador antes da migration.
- **Migrações versionadas:** nunca altere SQL existente; crie novos arquivos em `migrations/` numerados (`001_*.sql`). Documente no `PROGRESS.md`.
- **Env único de efeitos:** scripts shell ou `psql` com efeitos colaterais devem residir sob `scripts/` e ser acionados via Makefile. Não execute comandos diretos no README.
- **Configuração declarativa:** qualquer ajuste em `postgresql.conf` ou `pg_hba.conf` deve ser versionado e copiado no Dockerfile (builder + runtime). Sem ajustes manuais dentro do container.
- **Rede gRPC:** exponha o serviço apenas na rede interna Docker; clientes externos falarão com o backend gRPC ao invés de conectar direto no Postgres.
- **Fluxo de comandos:** `make docker-build` → `make docker-run` → testes → `make docker-stop`. Execute `make clean` somente quando seguro perder dados locais.

## Convenções
- **Docker multi-stage:** mantenha o estágio `builder` apenas para validar/copiar migrations; runtime roda `postgres:16-alpine` puro.
- **Arquivos sensíveis:** não commitar `.env` real ou dumps. Utilize `data/` apenas como volume local e ignore-o no git.
- **Documentação viva:** atualizar `README.md`/`PROGRESS.md` sempre que novas portas, variáveis ou comandos forem introduzidos.
- **Commits:** seguir Conventional Commits (`chore: setup postgres image`, `db: add packages table migration`).

## Testes
- Adote scripts de verificação em `tests/` (ex.: `deno test` ou `bash` com `psql`).
- Para smoke-tests manuais, use `make psql` ou `docker exec` e registre o resultado em `PROGRESS.md`.

## Integração futura
- Contratos gRPC ficam no diretório raiz do monorepo (mesma fonte usada pelo backend). Atualize o `.proto` antes de alterar tabelas que impactem o payload.
- Reserve `POSTGRES_GRPC_TARGET` para indicar qual serviço (ex.: `backend`) consome o DB; mantenha o valor sincronizado no `.env` dos demais projetos.
