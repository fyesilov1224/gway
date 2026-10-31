# GWAY API (docs/DEPLOY.md). Build context: the repository's backend/ folder.
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY . .
RUN dotnet publish src/Gway.Api -c Release -o /app --nologo

FROM mcr.microsoft.com/dotnet/aspnet:10.0
# Npgsql looks for the Kerberos library at start-up; without it an error is logged on every start.
RUN apt-get update && apt-get install -y --no-install-recommends libgssapi-krb5-2 && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY --from=build /app .
ENV ASPNETCORE_URLS=http://+:8080 \
    ASPNETCORE_ENVIRONMENT=Production
EXPOSE 8080
USER $APP_UID
ENTRYPOINT ["dotnet", "Gway.Api.dll"]
