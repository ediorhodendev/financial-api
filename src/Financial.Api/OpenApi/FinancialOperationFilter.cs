using Microsoft.AspNetCore.Authorization;
using Microsoft.OpenApi.Any;
using Microsoft.OpenApi.Models;
using Swashbuckle.AspNetCore.SwaggerGen;
namespace Financial.Api.OpenApi;
public sealed class FinancialOperationFilter : IOperationFilter
{
    public void Apply(OpenApiOperation operation, OperationFilterContext context)
    {
        if (context.ApiDescription.ActionDescriptor.EndpointMetadata.OfType<IAuthorizeData>().Any())
        {
            operation.Security = [new OpenApiSecurityRequirement
            {
                [new OpenApiSecurityScheme { Reference = new OpenApiReference { Type = ReferenceType.SecurityScheme, Id = "Bearer" } }] = []
            }];
            operation.Responses.TryAdd("401", new OpenApiResponse { Description = "Missing or invalid token." });
            operation.Responses.TryAdd("403", new OpenApiResponse { Description = "Required role is absent." });
        }
        var path = context.ApiDescription.RelativePath ?? "";
        operation.Parameters ??= [];
        if (path.EndsWith("/movements", StringComparison.Ordinal) && context.ApiDescription.HttpMethod == "POST")
            operation.Parameters.Add(new OpenApiParameter
            {
                Name = "Idempotency-Key", In = ParameterLocation.Header, Required = true,
                Description = "Reuse this key with the same payload after retries. New operation: new key. Replay 200; original 201; conflicting payload 409.",
                Schema = new OpenApiSchema { Type = "string", MinLength = 1, MaxLength = 100 }, Example = new OpenApiString("credit-demo-001")
            });
        if (path.EndsWith("/balance", StringComparison.Ordinal))
            operation.Parameters.Add(new OpenApiParameter
            {
                Name = "at", In = ParameterLocation.Query, Required = false,
                Description = "Inclusive historical instant, ISO 8601 with Z or offset. Omit for current balance. Future and pre-opening instants are invalid.",
                Schema = new OpenApiSchema { Type = "string", Format = "date-time" }
            });
        if (path.EndsWith("/movements", StringComparison.Ordinal) && context.ApiDescription.HttpMethod == "GET")
        {
            operation.Parameters.Add(new OpenApiParameter { Name = "limit", In = ParameterLocation.Query, Schema = new OpenApiSchema { Type = "integer", Minimum = 1, Maximum = 100, Default = new OpenApiInteger(50) } });
            operation.Parameters.Add(new OpenApiParameter { Name = "cursor", In = ParameterLocation.Query, Schema = new OpenApiSchema { Type = "string", MaxLength = 1024 }, Description = "Use nextCursor from the previous page; live keyset pagination." });
        }
    }
}
