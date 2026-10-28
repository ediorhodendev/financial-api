# Arquitetura — movimentações

Aplicação única, quatro camadas com dependências para o núcleo. CQRS simples: RegisterMovementHandler é o comando; AccountQueries executa as leituras de saldo e extrato. Nenhum MediatR ou repositório genérico é necessário.

## Fronteira transacional
Application define IAccountTransactionFactory e IAccountTransaction. Infrastructure cria um DbContext exclusivo por operação e transação READ COMMITTED. A consulta parametrizada bloqueia somente a linha da conta com FOR UPDATE OF a e filtra sua titularidade antes de devolver o agregado.

Depois do lock, o handler consulta a chave idempotente. Reenvios com hash igual retornam a operação original; hash diferente produz conflito. Valores equivalentes como 10.0 e 10.00 têm hash igual, calculado em formato invariável. A moeda é fixa e a chave é única por conta. Rejeições não são armazenadas como operações concluídas.

A entidade valida saldo e limites. O timestamp é obtido com clock_timestamp() depois do bloqueio (now() marcaria o começo da transação, inclusive o tempo de espera). Saldo e lançamento são persistidos e o commit ocorre antes do retorno de sucesso. Um histórico temporal rigoroso de visibilidade de commits permanece fora do escopo.

O lock é mantido até commit/rollback. Contas distintas podem progredir em paralelo; uma conta muito concorrida vira um ponto de serialização. Espera pelo lock limitada a 5s, statements a 10s e command timeout de 15s. Não há chamadas externas na transação nem repetição cega de escrita. Esses limites são locais à operação/statement, não um orçamento total de requisição.

Uma falha antes do commit reverte tudo; resposta perdida depois de commit é recuperada com a mesma chave. Cancelamento/rede durante o commit pode deixar resultado desconhecido para o chamador. Não prometer entrega exatamente uma vez; garantir efeito idempotente com reenvio.

## Segurança e operação
JWT valida emissor, audience, assinatura e validade. O papel operator é obrigatório e o sub precisa corresponder ao dono da conta. Demo é explicitamente Development; não há bypass de autenticação. Production precisa de configuração do emissor e de credenciais mínimas de banco. Sem configuração JWT válida, acesso financeiro falha fechado.

O usuário PostgreSQL criado pelo Compose é exclusivamente local. Separação de usuário de migrations e usuário de execução, permissões imutáveis, gestão de chaves e auditoria ainda são evolução de produção.

## Evidência
Testes unitários verificam orquestração e invariantes. Somente testes contra PostgreSQL podem comprovar bloqueios, rollback e restrições; não usar um fake como prova de concorrência.

## Consultas — etapa 4

AccountQueries valida identidade, data e limite de paginação e depende de IAccountQueryStore. PostgresAccountQueryStore usa contextos próprios e consultas sem tracking. Saldo histórico e validação de titularidade são uma única instrução SQL, com soma condicional e zero para histórico vazio. Não carregar lançamentos em memória para somar.

TimeProvider permite testes determinísticos de datas futuras. O parâmetro at da API exige ISO 8601 com Z ou offset e é normalizado para UTC. O limite histórico é inclusivo. Instantes anteriores à conta são rejeitados depois de confirmar titularidade, evitando revelar sua existência.

Paginação keyset ordena por registered_at e id; busca limit+1 linhas para indicar continuação, aproveitando o índice composto. Cursor versionado inclui conta, instante e id, limitado a 1024 caracteres. Não contém segredo e não é autorização; a consulta sempre filtra por titularidade. A ordem de UUID precisa ser a mesma no ORDER BY e no predicado do PostgreSQL, validada em teste com horários iguais.

Entre páginas não existe snapshot mantido: a semântica é de extrato vivo. Exportação financeira com corte estável e consistência temporal de commits é uma evolução separada. Saldo atual é lido da projeção; saldo histórico é calculado do registro imutável de movimentações.

## Entrega de cadastros e proteção
ProvisioningHandler cria entidades usando TimeProvider; IProvisioningStore implementa gravações e consultas. Restrições únicas no banco resolvem corridas, sem depender de checagem prévia para evitar duplicidade. Admin cria/vincula identidade; titularidade continua verificada na gravação financeira e nas consultas. ApiExceptionHandler traduz erros sem SQL/stack trace no payload. Swagger descreve segurança, parâmetros e códigos.

ProtectLedger acrescenta trigger imutável. As migrations não são executadas no startup da API, para separar alterações de schema da identidade de execução. Start-Local faz isso explicitamente apenas no ambiente de desenvolvimento.
