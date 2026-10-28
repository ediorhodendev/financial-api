# Etapas e estado de entrega

| Etapa | Entrega | Estado |
|---|---|---|
| 1 | Regras financeiras, modelo e arquitetura | Documentada |
| 2 | Solução, EF/PostgreSQL, migrations, Docker/CI | Implementada |
| 3 | Movimentações atômicas, idempotência e concorrência | Implementada; validação PostgreSQL ver validation.md |
| 4 | Saldo atual/histórico e extrato | Implementada; validação PostgreSQL ver validation.md |
| 5 | Cadastro de clientes/contas, autorização e Swagger | Implementada |
| 6 | Testes ampliados, falhas, imutabilidade e scripts de carga | Implementados; execução PostgreSQL/carga no destino pendente |
| 7 | README, decisões, instruções, CI e script de publicação | GitHub público criado em ediorhodendev/financial-api; CI remoto em validação |

Não confundir código implementado com teste executado ou publicação concluída. Consulte validation.md. A estimativa inicial de esforço foi 28h (3h regras, 3h estrutura, 5h movimentações, 4h consultas, 4h segurança, 5h integração/carga, 4h entrega); não é apontamento de horas gastas.

Fechamento: executar Test-All.ps1 com PostgreSQL, registrar carga, publicar repositório público, acompanhar CI e repetir o README em clone limpo. Nenhuma chave ou dado pessoal deve ser publicado.
