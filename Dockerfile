FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app

#DOTNET_RUNNING_IN_CONTAINER=true
EXPOSE 7150
EXPOSE 443


# Creates a non-root user with an explicit UID and adds permission to access the /app folder
# For more info, please refer to https://aka.ms/vscode-docker-dotnet-configure-containers

#RUN adduser -u 5678 --disabled-password --gecos "" appuser && chown -R appuser /app
RUN useradd -m appuser && chown -R appuser /app
USER appuser

FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:6.0 AS build
ARG configuration=Release
WORKDIR /src
COPY ["jkspce.csproj", "./"]
RUN dotnet restore "jkspce.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "jkspce.csproj" -c $configuration -o /app/build

# 將應用程序發佈到/app/publish目錄
FROM build AS publish
ARG configuration=Release
RUN dotnet publish "jkspce.csproj" -c $configuration -o /app/publish /p:UseAppHost=false

# COPY 編譯階段已產生的發佈檔至 /app 下
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .

ENV ASPNETCORE_URLS=http://+:7150
ENTRYPOINT ["dotnet", "jkspce.dll"]

