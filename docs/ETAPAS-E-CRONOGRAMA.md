# Etapas e estado de entrega

| Etapa | Entrega | Estado |
|---|---|---|
| 1 | Regras financeiras, modelo e arquitetura | Documentada |
| 2 | Solução, EF/PostgreSQL, migrations, Docker/CI | Implementada |
| 3 | Movimentações atômicas, idempotência e concorrência | Implementada e validada em PostgreSQL no CI |
| 4 | Saldo atual/histórico e extrato | Implementada e validada em PostgreSQL no CI |
| 5 | Cadastro de clientes/contas, autorização e Swagger | Implementada |
| 6 | Testes ampliados, falhas, imutabilidade e scripts de carga | Implementados; testes PostgreSQL e carga pequena aprovados no CI |
| 7 | README, decisões, instruções, CI e script de publicação | GitHub público e CI aprovados; clone e fontes conferidos |

Não confundir código implementado com teste executado ou publicação concluída. Consulte validation.md. A estimativa inicial de esforço foi 28h (3h regras, 3h estrutura, 5h movimentações, 4h consultas, 4h segurança, 5h integração/carga, 4h entrega); não é apontamento de horas gastas.

Fechamento realizado: publicação pública, build sem warnings, 56 testes com PostgreSQL aprovados, carga pequena registrada e clone remoto conferido. Para reproduzir no Windows, siga README e Test-All.ps1. Nenhuma chave ou dado pessoal deve ser publicado.
