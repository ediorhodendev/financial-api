# Financial API

Repositório público: https://github.com/ediorhodendev/financial-api

Workflow: https://github.com/ediorhodendev/financial-api/actions

**Validação anterior:** 56 testes aprovados com PostgreSQL real e exercício de 100 consultas + 100 créditos sem falhas. A atualização Docker adiciona dois testes e uma etapa de smoke test no CI; confira o status da execução mais recente. Evidência e limites em docs/validation.md e docs/performance.md.

API em C#/.NET 10 para registrar créditos e débitos e consultar saldo atual e histórico de clientes. PostgreSQL é a fonte de verdade. Clean Architecture com CQRS simples, transações ACID, idempotência, autorização JWT e testes automatizados.

## O que está implementado
- Cadastro administrativo de clientes com vínculo à identidade autenticada (`sub`) e abertura de conta única em BRL, com saldo zero.
- Créditos/débitos atômicos, bloqueio por conta e rejeição de saldo negativo; chaves idempotentes por conta.
- Saldo atual, saldo histórico inclusivo e extrato crescente com cursor.
- JWT: papel `admin` para cadastros; `operator` para escritas financeiras; titularidade obrigatória para movimentações e leituras financeiras. Admin pode ler metadados da conta, mas não movimentar conta alheia.
- Histórico protegido contra UPDATE/DELETE no EF Core e por trigger no PostgreSQL.
- Swagger com Bearer, parâmetros de idempotência e consultas; health checks; Problem Details; logs sem corpos/tokens, com correlação.
- Migrations, Docker Compose, Dockerfile, CI e scripts de execução, testes, carga e publicação.

## Avaliação: tudo em Docker com um comando

Pré-requisito: Docker Desktop iniciado, com Linux containers e Docker Compose v2.
Após clonar o repositório, abra o terminal na pasta que contém `compose.yaml` e execute:

```powershell
docker compose up --build -d
```

Não é necessário instalar .NET, PostgreSQL ou criar `.env`. O Compose sobe PostgreSQL,
aguarda o health check, aplica migrations, cria uma conta fictícia sem duplicar dados e
inicia a API. Aguarde `docker compose logs -f migrations api` mostrar a API iniciada.
Swagger: http://localhost:5080/swagger. Readiness: http://localhost:5080/health/ready.
Se as migrations falharem, a API não inicia; consulte `docker compose logs migrations`.

No Swagger, execute **POST /demo/access** (sem corpo). A resposta contém `accountId`,
`operatorToken` e `adminToken`, válidos por uma hora. Clique **Authorize** e cole apenas
`operatorToken` para movimentar e consultar a conta fictícia. Use `adminToken` para
os endpoints administrativos. Não é necessário executar comandos .NET para obter tokens.
A chave JWT é aleatória por processo: após reiniciar a API, obtenha novos tokens.

Exemplo completo em PowerShell, após a inicialização:

```powershell
$demo = Invoke-RestMethod -Method Post http://localhost:5080/demo/access
$headers = @{ Authorization = "Bearer $($demo.operatorToken)"; 'Idempotency-Key' = 'avaliacao-credito-001' }
Invoke-RestMethod -Method Post "http://localhost:5080/api/accounts/$($demo.accountId)/movements" -Headers $headers -ContentType 'application/json' -Body '{"type":"Credit","amount":100}'
Invoke-RestMethod "http://localhost:5080/api/accounts/$($demo.accountId)/balance" -Headers $headers
```

A mesma chave e conteúdo não duplicam o crédito ao repetir o exemplo. Os dados persistem
no volume `financial_data`. Para parar preservando-os: `docker compose down`.
Para consultar o estado: `docker compose ps -a`.

**Este Compose é exclusivo de avaliação local.** Expõe portas somente em loopback e usa
senha pública de demonstração. O endpoint `/demo/access` emite acesso administrativo
local sem login, só existe com `Demo__Enabled=true` e recusa ambientes diferentes de
Development. Não publique este ambiente na internet nem use dados reais. Para produção,
desabilite Demo, configure um emissor JWT confiável e segredos, HTTPS e privilégios mínimos.
O `.env` é opcional para mudar `POSTGRES_PASSWORD` e `API_PORT`; mudar a senha não altera
um volume PostgreSQL já inicializado. As credenciais não são incluídas na imagem.

## Execução com SDK local (alternativa)

## Pré-requisitos
Windows/PowerShell, SDK .NET 10, Docker Desktop com Compose v2 e acesso ao NuGet. Python 3 é necessário apenas para o script de carga. PostgreSQL local usa porta 5432; testes usam 5433. Os containers são PostgreSQL 17; o banco é apenas acessível em loopback.

## Instalação em C:\Projetos\financial-api
Extraia este pacote diretamente nessa pasta, sem criar uma pasta adicional. Preserve seu `.env`; faça backup se houver alterações locais. Arquivo de entrada: `Financial.slnx`.

```powershell
Set-Location C:\Projetos\financial-api
if (-not (Test-Path .env)) { Copy-Item .env.example .env }
# Edite .env e troque POSTGRES_PASSWORD antes de continuar.
.\scripts\Start-Local.ps1
```

Nesta alternativa com SDK, mantenha a API do Compose parada para liberar a porta 5080. O script sobe o banco, restaura/builda, aplica as migrations, cria a conta fictícia e inicia a API. A primeira execução sem .env cria o exemplo e pede sua edição. A senha é usada só no ambiente/processo local. Para execução manual:

```powershell
$env:ASPNETCORE_ENVIRONMENT = 'Development'
$env:ConnectionStrings__Financial = 'Host=localhost;Port=5432;Database=financial;Username=financial_local;Password=SUA_SENHA_LOCAL'
docker compose up -d --wait postgres
dotnet restore Financial.slnx
dotnet build Financial.slnx -c Release
dotnet tool restore
dotnet ef database update --project src/Financial.Infrastructure --startup-project src/Financial.Api
dotnet run --project src/Financial.Api -- --seed-demo
dotnet run --project src/Financial.Api --urls http://localhost:5080
```

`--seed-demo` é explícito, exclusivo de Development e retorna `DEMO_ACCOUNT_ID`. Não há credencial real no repositório. Alterar a senha no .env não altera um volume PostgreSQL já inicializado; não apague volume com dados que deseja preservar.

## Swagger e tokens locais
Abra http://localhost:5080/swagger. O Swagger só é exposto em Development. Em outro terminal:

```powershell
Set-Location C:\Projetos\financial-api
$token = dotnet user-jwts create --project src/Financial.Api --name demo-operator --role operator --audience http://localhost:5080 --output token
$adminToken = dotnet user-jwts create --project src/Financial.Api --name demo-admin --role admin --audience http://localhost:5080 --output token
```

No Swagger, clique em **Authorize** e cole somente o JWT do papel apropriado. As chaves ficam no armazenamento local de segredos, fora do projeto. Tokens `user-jwts` são apenas de desenvolvimento, não de produção. A chave idempotente é um campo do endpoint de movimentações.

Documentação oficial de tokens locais: https://learn.microsoft.com/aspnet/core/security/authentication/jwt-authn?view=aspnetcore-10.0

## Fluxo completo por API
Os comandos abaixo pressupõem API iniciada e os tokens acima. Use dados fictícios. Só um administrador confiável pode associar identidades do emissor; o usuário comum não escolhe o sub do próprio cadastro.

```powershell
$base = 'http://localhost:5080'
$adminHeaders = @{ Authorization = "Bearer $adminToken" }
$body = @{ name = 'Cliente de demonstração'; subjectId = 'cliente-demo-01' } | ConvertTo-Json
$customer = Invoke-RestMethod -Method Post -Uri "$base/api/customers" -Headers $adminHeaders -ContentType 'application/json' -Body $body
$account = Invoke-RestMethod -Method Post -Uri "$base/api/customers/$($customer.id)/accounts" -Headers $adminHeaders
$accountId = $account.id
$ownerToken = dotnet user-jwts create --project src/Financial.Api --name cliente-demo-01 --role operator --audience http://localhost:5080 --output token
$headers = @{ Authorization = "Bearer $ownerToken"; 'Idempotency-Key' = 'credito-001' }
$body = @{ type = 'Credit'; amount = 100.00 } | ConvertTo-Json
$credit = Invoke-RestMethod -Method Post -Uri "$base/api/accounts/$accountId/movements" -Headers $headers -ContentType 'application/json' -Body $body
# Repetir com a mesma chave/payload retorna o mesmo lançamento, sem duplicar o crédito.
Invoke-RestMethod -Method Post -Uri "$base/api/accounts/$accountId/movements" -Headers $headers -ContentType 'application/json' -Body $body
$headers['Idempotency-Key'] = 'debito-001'
$body = @{ type = 'Debit'; amount = 30.00 } | ConvertTo-Json
Invoke-RestMethod -Method Post -Uri "$base/api/accounts/$accountId/movements" -Headers $headers -ContentType 'application/json' -Body $body
$readHeaders = @{ Authorization = "Bearer $ownerToken" }
Invoke-RestMethod -Uri "$base/api/accounts/$accountId/balance" -Headers $readHeaders
$at = [uri]::EscapeDataString($credit.registeredAt)
Invoke-RestMethod -Uri "$base/api/accounts/$accountId/balance?at=$at" -Headers $readHeaders
$page = Invoke-RestMethod -Uri "$base/api/accounts/$accountId/movements?limit=1" -Headers $readHeaders
if ($page.nextCursor) {
    $cursor = [uri]::EscapeDataString($page.nextCursor)
    Invoke-RestMethod -Uri "$base/api/accounts/$accountId/movements?limit=1&cursor=$cursor" -Headers $readHeaders
}
```

Valores esperados: saldo atual 70; saldo no instante do crédito 100; replay com o mesmo id e `replayed=true`. Para repetir todo o cadastro use outro subjectId, pois identidades e contas são únicas; duplicidade de cadastro retorna 409.

## Endpoints
| Método | Rota | Acesso |
|---|---|---|
| POST | /api/customers | admin |
| GET | /api/customers/{customerId} | admin |
| POST | /api/customers/{customerId}/accounts | admin |
| GET | /api/accounts/{accountId} | titular ou admin; metadados |
| POST | /api/accounts/{accountId}/movements | titular com operator; Idempotency-Key |
| GET | /api/accounts/{accountId}/balance | titular |
| GET | /api/accounts/{accountId}/balance?at=... | titular |
| GET | /api/accounts/{accountId}/movements?limit=50&cursor=... | titular |
| GET | /health/live | processo vivo |
| GET | /health/ready | conectividade e acesso ao schema |

Erros: 400 inválido; 401 token inválido/ausente; 403 papel ausente; 404 inexistente ou inacessível; 409 regra de saldo/duplicidade; 503 banco indisponível/timeout; 500 inesperado sem detalhes internos. Retentativas de movimentação SEMPRE reutilizam a mesma chave. Se o commit ocorreu e a resposta se perdeu, o replay recupera o resultado.

## Testes
Sem banco (domínio/aplicação e HTTP de contrato/autorização):

```powershell
dotnet build Financial.slnx -c Release
dotnet test tests/Financial.Domain.Tests -c Release --no-build
dotnet test tests/Financial.Api.Tests -c Release --no-build --filter 'Category!=Postgres'
```

Suíte completa em PostgreSQL dedicado:

```powershell
.\scripts\Test-All.ps1
```

Ou manualmente:

```powershell
docker compose --profile tests up -d --wait postgres-test
$env:FINANCIAL_TEST_CONNECTION = 'Host=localhost;Port=5433;Database=financial_test;Username=financial_test;Password=SUA_SENHA_LOCAL'
dotnet test Financial.slnx -c Release --logger trx --results-directory TestResults
```

Use EXCLUSIVAMENTE banco de testes; migrations e registros fictícios são criados. Não há exclusão automática de dados. A suíte testa débitos concorrentes, créditos duplicados/únicos, rollback, idempotência, histórico, paginação com empate, cadastros concorrentes, imutabilidade e fluxo HTTP completo.

A documentação `docs/validation.md` diferencia testes efetivamente executados de testes apenas preparados. CI provisiona PostgreSQL e roda todos os projetos; os resultados só existem após executar o workflow.

## Carga

```powershell
$env:FINANCIAL_LOAD_TOKEN = $ownerToken
python scripts/load-test.py --account-id $accountId --requests 100 --concurrency 8
# Opcional, somente em conta fictícia: cada requisição credita R$ 0,01.
python scripts/load-test.py --account-id $accountId --requests 100 --concurrency 8 --write-demo
```

O script retorna throughput, latência p50/p95/max e códigos HTTP. Não há benchmark financeiro inventado; registre os resultados reais conforme docs/performance.md.

## Arquitetura e execução em container
Domain não depende de frameworks. Application define casos de uso e portas. Infrastructure implementa PostgreSQL e transações. Api compõe autenticação, autorização, documentação e transporte. Veja docs/architecture.md, docs/decisions.md e docs/limitations.md.

Dockerfile compila/publica a API e executa como usuário `app`. Ele não aplica migrations nem embute segredos. Configure ConnectionStrings__Financial, Jwt__Authority e Jwt__Audience ao executá-lo em produção; adote HTTPS no proxy/ingress e um emissor real. O Compose inicia banco, migrations/seed e API para avaliação local. O script .NET é uma alternativa para debugging.

## GitHub público e entrega
O repositório desta entrega é ediorhodendev/financial-api. Para publicar uma cópia na sua conta, depois de validar testes e revisar o conteúdo:

```powershell
gh auth login
.\scripts\Publish-GitHub.ps1 -Repository 'SEU_USUARIO/financial-api'
```

O script mostra o status e pede confirmação explícita antes de criar o repositório PÚBLICO. Não imprime tokens e bloqueia arquivos de chave/segredos por nome; revise também o conteúdo. Configure sua identidade Git se necessário. Não publique dados pessoais ou connection strings reais.

Depois da publicação, confirme o workflow e valide um clone limpo com os mesmos passos do README. O pacote local não comprova publicação, aprovação do CI ou uso em ambiente bancário real.
