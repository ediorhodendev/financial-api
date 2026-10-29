# Executar a avaliação

Com Docker Desktop iniciado (Linux containers e Compose v2), abra o terminal na raiz
do repositório e execute um único comando:

```powershell
docker compose up --build -d
```

O ambiente inicia PostgreSQL, aplica migrations, cria a conta fictícia e inicia a API.
Não exige SDK .NET ou PostgreSQL instalado, nem criação de .env.

1. Aguarde a inicialização; acompanhe com `docker compose logs -f migrations api`.
2. Abra http://localhost:5080/swagger.
3. Execute POST /demo/access para obter accountId, operatorToken e adminToken.
4. Em Authorize, cole somente operatorToken para operar na conta fictícia.
5. Use Idempotency-Key diferente para cada nova operação financeira.

Para parar preservando os dados: `docker compose down`.
O ambiente é local, usa dados fictícios e credenciais públicas de demonstração.
O modo demo nunca deve ser exposto na internet. Consulte README.md para detalhes,
fluxo de teste, execução alternativa com SDK e configuração de produção.
