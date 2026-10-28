using Financial.Api.Endpoints;
using Financial.Domain.Accounts;
using Financial.Domain.Movements;
using Microsoft.OpenApi.Any;
using Microsoft.OpenApi.Models;
using Swashbuckle.AspNetCore.SwaggerGen;
namespace Financial.Api.OpenApi;

public sealed class FinancialSchemaFilter : ISchemaFilter
{
    public void Apply(OpenApiSchema schema, SchemaFilterContext context)
    {
        if (context.Type == typeof(MovementType))
        {
            schema.Type = "string";
            schema.Format = null;
            schema.Enum = [new OpenApiString("Credit"), new OpenApiString("Debit")];
        }
        if (context.Type == typeof(MovementRequest))
        {
            schema.Required.Add("type");
            schema.Required.Add("amount");
            schema.Properties["amount"].Minimum = 0.01m;
            schema.Properties["amount"].Maximum = Account.MaximumBalance;
            schema.Properties["amount"].MultipleOf = 0.01m;
            schema.Example = new OpenApiObject { ["type"] = new OpenApiString("Credit"), ["amount"] = new OpenApiDouble(100) };
        }
        if (context.Type == typeof(CreateCustomerRequest))
        {
            schema.Required.Add("name");
            schema.Required.Add("subjectId");
            schema.Example = new OpenApiObject { ["name"] = new OpenApiString("Cliente fictício"), ["subjectId"] = new OpenApiString("cliente-demo-01") };
        }
    }
}
