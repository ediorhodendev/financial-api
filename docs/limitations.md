# Limites e evolução

- Demonstração de arquitetura, não um core bancário homologado. Faltam ledger de partidas dobradas, reconciliação operacional, auditoria independente, procedimentos regulatórios e recuperação de desastre validados.
- BRL, uma conta por cliente, sem saldo negativo. Sem transferências, múltiplas moedas, lançamentos retroativos/agendados ou endpoint de estorno nesta entrega.
- registered_at é instante lógico obtido no banco após o lock, não horário exato de commit. Consultas históricas refletem registros confirmados visíveis no snapshot da consulta. Consistência bitemporal/visibilidade histórica precisa de outro desenho.
- Paginação keyset é de histórico vivo; não mantém snapshot entre requisições. Commits tardios com posição anterior podem ficar fora das próximas páginas. Para exportação contábil, implementar corte estável/sequenciamento apropriado.
- Cadastros exigem administrador e têm unicidade; não oferecem o contrato de replay dos lançamentos financeiros.
- Timeouts são por lock/statement/comando; não há orçamento total de requisição nem limitação de taxa global. Ajustar pools, backpressure e limites depois da carga.
- Proteção EF/trigger não resiste a superusuário. Em produção separar identidade de migrations e execução; não usar o superusuário criado pelo Compose.
- JWT em produção depende de emissor confiável, audience, HTTPS e rotação de chaves; local usa user-jwts. Não há endpoint próprio de login/refresh.
- Backup, restore, failover, observabilidade externa e CI no GitHub precisam de execução e verificação no destino. Não armazenar tokens nem segredos no repositório.
- Mensageria futura deve usar outbox transacional; cache não deve autorizar débitos baseado em saldo desatualizado.
