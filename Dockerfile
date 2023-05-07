#See https://aka.ms/customizecontainer to learn how to customize your debug container and how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["PredictionBot-Prediction/PredictionBot-Prediction.csproj", "PredictionBot-Prediction/"]
COPY ["PredictionBot-Prediction-Application/PredictionBot-Prediction-Application.csproj", "PredictionBot-Prediction-Application/"]
COPY ["PredictionBot-Prediction-Infrastructure/PredictionBot-Prediction-Infrastructure.csproj", "PredictionBot-Prediction-Infrastructure/"]
COPY ["PredictionBot-Prediction-Domain/PredictionBot-Prediction-Domain.csproj", "PredictionBot-Prediction-Domain/"]

RUN dotnet restore "PredictionBot-Prediction/PredictionBot-Prediction.csproj"
COPY . .
WORKDIR "/src/PredictionBot-Prediction"
RUN dotnet build "PredictionBot-Prediction.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "PredictionBot-Prediction.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "PredictionBot-Prediction.dll"]