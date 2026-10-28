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
Nenhum resultado de carga financeira em PostgreSQL foi medido neste ambiente. O script está entregue e validado sintaticamente, mas números reais devem ser anexados após execução local/CI. Testes com banco indisponível não constituem benchmark da solução financeira.
