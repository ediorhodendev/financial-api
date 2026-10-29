# Atualização Docker — 29/10/2026

Execução aprovada: https://github.com/ediorhodendev/financial-api/actions/runs/40934977012
Commit de código/workflow validado: 6d937fc (atualizações documentais posteriores não alteram o código).

- Build Release: zero erros e zero warnings.
- 58 testes aprovados: 31 domínio/aplicação, 12 integração PostgreSQL e 15 HTTP/segurança.
- Carga limitada: saldo após 100 créditos de R$ 0,01 confirmado em R$ 1,00.
- Docker Compose em projeto/volume isolado: banco saudável, migrations aplicadas, conta fictícia criada e API disponível.
- Teste usando JWT emitido pela própria API de demonstração: crédito 100 (201), replay com o mesmo ID (200), débito 30 (201) e saldo final 70.
- Remoção do volume exclusivo de CI após o teste. Volumes locais do avaliador não são removidos.
- Localmente: 45 testes sem banco aprovados. Não há Docker neste ambiente local; os containers foram efetivamente executados no GitHub Actions.

Permanecem sem homologação: Docker Desktop no Windows, recuperação de backup, failover e carga prolongada/até saturação. A evidência inicial abaixo é mantida como histórico.

# Validação da entrega — 28/10/2026

## GitHub Actions com PostgreSQL real
Execução aprovada: https://github.com/ediorhodendev/financial-api/actions/runs/40785248930
Commit de código/workflow validado: ae88503dc0c0c112856fae32be89bf10a4660ff3.

| Verificação | Resultado |
|---|---|
| Build Release dos sete projetos | Zero erros e zero warnings |
| Domínio/aplicação | 31 testes aprovados |
| Integração direta PostgreSQL | 12 testes aprovados |
| HTTP, incluindo fluxo completo em PostgreSQL | 13 testes aprovados |
| Total | 56 aprovados, zero falhas e zero ignorados |
| Carga pequena de saldo | 100 respostas HTTP 200 |
| Carga pequena de créditos | 100 respostas HTTP 201 |
| Saldo após créditos | R$ 1,00, confirmado automaticamente |

Os testes reais cobrem idempotência concorrente, disputa de saldo, créditos sem atualizações perdidas, rollback, titularidade, histórico inclusivo, paginação com empates, cadastro/abertura concorrente e trigger de imutabilidade. As migrations foram aplicadas no PostgreSQL temporário do CI.

Os relatórios TRX e os JSONs performance-read/performance-write estão no artefato test-results dessa execução. Credenciais/JWTs de desenvolvimento usados pela carga são temporários e não são publicados nos relatórios.

## Verificações locais
Build Release sem erros/warnings; 43 testes sem banco aprovados; SQL das duas migrations gerado; ausência de alterações de modelo sem migration; publicação local Release gerada. Uma cópia limpa repetiu build e testes HTTP. O repositório público foi clonado e seus 63 arquivos iniciais comparados com os fontes locais: conteúdo equivalente, com apenas uma quebra de linha final acrescentada a um JSON. Depois foi incluído o script de medição e atualizada a documentação com os resultados reais.

## Publicação
Repositório público: https://github.com/ediorhodendev/financial-api
As verificações de publicação e CI foram concluídas. Atualizações posteriores exclusivamente documentais não alteram o código validado acima.

## Limites da evidência
A carga de 100 requisições por cenário é uma verificação pequena, não teste de capacidade máxima ou homologação bancária. Na validação inicial, Dockerfile, scripts PowerShell no Windows e backup/restore/failover ainda não tinham sido testados. A atualização Docker acima registra a execução posterior dos containers no CI. Consulte performance.md e limitations.md para os limites da demonstração.
