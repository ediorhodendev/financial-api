# Validação da entrega unificada — 28/10/2026

## Executado no ambiente de autoria
- SDK .NET 10.0.403; build Release dos sete projetos com zero erros e zero warnings.
- 31 testes de domínio/aplicação aprovados, zero falhas e ignorados.
- 12 testes HTTP automatizados com WebApplicationFactory, JWT assinado em memória e validação real de autenticação/autorização, aprovados; contrato Swagger verifica enums em string e campos obrigatórios.
- Total executado: 43 testes aprovados. Os testes HTTP não substituem o PostgreSQL real.
- SQL das duas migrations gerado em scripts/schema.sql; EF confirmou ausência de mudanças de modelo sem migration.
- Publicação local Release gerada com dotnet publish (não é deploy externo).
- Cópia limpa, sem bin/obj ou segredos: novo build sem erros/warnings e repetição dos 43 testes aprovados.
- Script Python de carga: compilação sintática e ajuda CLI verificadas; nenhum benchmark financeiro foi inventado.
- Arquivos JSON/XML/YAML, referências entre projetos e integridade do ZIP verificados.

## Preparado, mas NÃO executado aqui
- 12 testes de integração diretos no PostgreSQL e 1 fluxo HTTP completo com PostgreSQL (13 casos dependentes do banco).
- Aplicação real das migrations e validação do trigger/locks/SQL em PostgreSQL.
- Docker Compose, Dockerfile e scripts PowerShell no Windows.
- Carga financeira e análise de planos/índices.
- Publicação em GitHub público, execução do GitHub Actions e clone do repositório remoto.

O ambiente não oferece Docker/PostgreSQL nem acesso conectado à conta GitHub. A validação restante é reproduzível com scripts/Test-All.ps1, scripts/load-test.py e scripts/Publish-GitHub.ps1, mas a presença desses arquivos não equivale à execução bem-sucedida.

## Fechamento da entrega
1. Executar Test-All.ps1 em PostgreSQL dedicado e corrigir qualquer falha encontrada.
2. Registrar ambiente e resultados de carga em performance.md.
3. Publicar o repositório público sem segredos e confirmar CI.
4. Repetir o README a partir de um clone limpo remoto.
