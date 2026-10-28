# Rastreabilidade do desafio

| Requisito | Implementação/evidência |
|---|---|
| C# | Quatro projetos de produção em src/ |
| Registrar créditos/débitos | RegisterMovementHandler e transação PostgreSQL |
| Consultar saldo em determinado momento | AccountQueries + soma SQL inclusiva |
| Consistência/concorrência/falhas | Lock por conta, transação, chave única/idempotência, rollback, timeouts |
| Proteção dos dados | JWT, papéis, titularidade, sem segredos versionados, imutabilidade |
| Testes automatizados | Domínio/aplicação, HTTP e integração; execução real em validation.md |
| Compilar sem erros/warnings | Build Release verificado, warnings como erros |
| README local | README.md e scripts/Start-Local.ps1 |
| Documentação no repositório | docs/, README e scripts |
| GitHub público | Script preparado; publicação ainda pendente |

A solução mantém uma conta por cliente, BRL, sem saldo negativo, sem frontend obrigatório. Alternativas, premissas e limites constam em decisions.md e limitations.md. Os requisitos de validação no PostgreSQL e publicação precisam ser fechados antes de considerar o desafio entregue ao avaliador.
