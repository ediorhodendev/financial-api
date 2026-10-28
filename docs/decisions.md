# Decisões arquiteturais

## ADR 001 — aplicação única e Clean Architecture
Uma aplicação com quatro camadas mantém a entrega reproduzível e as regras isoladas. Alternativa: microsserviços. Distribuir o saldo e o registro exigiria coordenação, observabilidade e consistência mais complexas sem benefício comprovado neste recorte. Separar serviços quando requisitos de escala/equipe justificarem fronteiras autônomas.

## ADR 002 — PostgreSQL e consistência forte por conta
Saldo e movimentação são escritos na mesma transação READ COMMITTED; bloqueio FOR UPDATE só na conta. Evita gasto duplicado e atualizações perdidas. Contas distintas progridem em paralelo; conta muito ativa serializa. Alternativa: concorrência otimista com versão e retries; exige controlar conflitos e revalidar saldo. Escolha atual prioriza previsibilidade. Unique(account_id, idempotency_key) protege duplicidade adicionalmente.

## ADR 003 — idempotência e falhas
Hash SHA-256 sobre tipo e valor normalizados, versão do formato explícita. Igual chave/conteúdo retorna lançamento original; conflito retorna 409. Não armazenar rejeições como movimentações. Resultado desconhecido depois de falha de rede/commit é resolvido pelo reenvio da MESMA chave. Não prometer entrega exatamente uma vez e não repetir escritas cegamente.

## ADR 004 — histórico, projeção e paginação
Saldo atual é projeção transacional em accounts; histórico soma créditos menos débitos indexados por conta/data/id. Sem Event Sourcing completo nem snapshots iniciais. Snapshots ou projeções de leitura serão considerados com medição. Datas são UTC e o corte é inclusivo. Keyset evita custo de OFFSET e usa critério de desempate UUID. Extrato vivo não é snapshot contábil entre páginas.

## ADR 005 — identidade e documentação
Administrador confiável vincula subjectId do emissor; operador só movimenta sua própria conta. JWTs locais pelo user-jwts, sem endpoint que emite tokens de produção. Swagger apenas Development. Nenhum frontend é exigido. Cadastros duplicados geram 409, e não replay idempotente financeiro.

## ADR 006 — ledger imutável
Métodos não expõem setters públicos; EF bloqueia UPDATE/DELETE e trigger rejeita esses comandos no PostgreSQL. Usuário de execução em produção precisa de permissões mínimas e sem TRUNCATE, DDL ou poder de desabilitar triggers. Administrador/superusuário do banco ainda pode alterar a infraestrutura: a trigger não é auditoria inviolável. Estornos devem ser novos lançamentos compensatórios vinculados ao original, evolução ainda não exposta como endpoint.
