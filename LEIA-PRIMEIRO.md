# Financial API — entrega unificada

Todos os arquivos das etapas 1 a 7 estão reunidos neste pacote: código, migrations, Swagger, testes, scripts e documentação. O código acumulado inclui as implementações das etapas anteriores.

Extraia diretamente em C:\Projetos\financial-api\, preservando seu .env e salvando cópia de alterações locais. Financial.slnx deve estar na raiz.

1. Leia README.md e edite .env a partir de .env.example.
2. Execute scripts/Start-Local.ps1 para banco, migrations, dados fictícios e API.
3. Abra http://localhost:5080/swagger e gere os JWTs locais conforme README.
4. Execute scripts/Test-All.ps1 para a suíte completa em banco de testes.
5. Registre carga conforme docs/performance.md.
6. Publique com scripts/Publish-GitHub.ps1 após revisar o conteúdo e os testes.

Os testes efetivamente executados estão em docs/validation.md. Execução de PostgreSQL/carga e publicação no GitHub não devem ser presumidas pela existência dos scripts. Repositório público desta entrega: https://github.com/ediorhodendev/financial-api. O resultado dos testes remotos deve ser confirmado no GitHub Actions.
