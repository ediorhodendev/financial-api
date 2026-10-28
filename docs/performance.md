# Verificação de desempenho

## Cenário reproduzível
1. Usar banco isolado, dados fictícios e versão Release. Registrar CPU, RAM, sistema, versões de SDK/PostgreSQL, localização API/banco e volume de dados.
2. Aquecer a aplicação antes da medição e repetir a mesma quantidade de requisições, sem misturar falhas de autenticação com consultas válidas.
3. Executar scripts/load-test.py inicialmente com 100 requisições/8 concorrentes; aumentar gradualmente até o limite que deseja estudar.
4. Medir saldo atual e, separadamente, créditos em uma mesma conta e em contas diferentes. O modo atual do script usa uma conta por execução; para múltiplas contas, executar instâncias distintas.
5. Registrar códigos HTTP, throughput e p50/p95/max. Se houver 409/503/timeouts, registrar como falha/limite, não como sucesso.
6. Conferir saldo e número de lançamentos antes/depois de escritas. Cada escrita bem-sucedida vale R$ 0,01. Um timeout pode ter commit confirmado, então use extrato/chave para reconciliação.
7. Para histórico grande, usar EXPLAIN (ANALYZE, BUFFERS) em banco de testes, conferir índice composto e avaliar snapshots.

## Critérios
Zero duplicidade e zero saldo perdido são invariantes de correção, não metas opcionais de latência. Não foi definido um SLO pelo desafio; metas de p95 e capacidade precisam de requisito de negócio e infraestrutura conhecida.

## Estado da medição
Medição executada em 28/10/2026 no GitHub Actions, com runner ubuntu-latest, API .NET 10 em Release, PostgreSQL 17 temporário, tráfego local e uma conta fictícia. Execução: https://github.com/ediorhodendev/financial-api/actions/runs/40785248930

| Cenário | Requisições | Concorrência | Respostas | Req/s | Mediana (ms) | p95 (ms) | Máximo (ms) |
|---|---:|---:|---|---:|---:|---:|---:|
| Saldo atual | 100 | 8 | 100 × HTTP 200 | 285,78 | 7,85 | 244,23 | 251,08 |
| Crédito de R$ 0,01 | 100 | 8 | 100 × HTTP 201 | 120,93 | 15,05 | 386,23 | 398,18 |

Saldo final confirmado automaticamente: R$ 1,00. Nenhuma falha HTTP nesses dois cenários. Houve verificação de readiness antes da carga, sem fase dedicada de aquecimento; inicialização e compilação das primeiras consultas afetam especialmente cauda e máximo. Base pequena, execução curta, sem teste até saturação e sem validação de plano em histórico grande. Esses resultados são evidência funcional e uma referência inicial, não promessa de desempenho em produção.

Reproduza a medição com scripts/benchmark-ci.sh (ambiente CI isolado) ou scripts/load-test.py (local). JSONs completos no artefato test-results do workflow. Não interpretar respostas de banco indisponível como benchmark financeiro.
