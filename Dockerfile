#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/core/aspnet:3.1-buster-slim AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

# make sure we have node
RUN curl -sL https://deb.nodesource.com/setup_12.x |  bash -
RUN apt-get install -y nodejs

FROM mcr.microsoft.com/dotnet/core/sdk:3.1-buster AS build
WORKDIR /src
COPY ["react-enabled-aspdotnet-hi-world.csproj", ""]
RUN dotnet restore "./react-enabled-aspdotnet-hi-world.csproj"
COPY . .
WORKDIR "/src/."

# following lines pointed to by stackoverflow...appears nodejs needs specific inclusion???
RUN apt-get update -yq && apt-get upgrade -yq && apt-get install -yq curl git nano
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - && apt-get install -yq nodejs build-essential
RUN npm install -g npm
RUN npm install

RUN dotnet build "react-enabled-aspdotnet-hi-world.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "react-enabled-aspdotnet-hi-world.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "react-enabled-aspdotnet-hi-world.dll", "--host", "0.0.0.0"]
# I'm probably getting this a bit wrong, but the IPs the browser will lead to aren't the same as what docker is using within the container.
# the host and 0.0.0.0 "parameters" tell docker to map the IPs as needed.  https://pythonspeed.com/articles/docker-connection-refused/ clued me in.

#FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS build-env
#WORKDIR /app
#
## Copy csproj and restore as distinct layers
#COPY *.csproj ./
#RUN dotnet restore
#
## Copy everything else and build
#COPY . ./
#RUN dotnet publish -c Release -o out
#
## Build runtime image
#FROM mcr.microsoft.com/dotnet/core/aspnet:3.1
#WORKDIR /app
#COPY --from=build-env /app/out .
#ENTRYPOINT ["dotnet", "react-enabled-aspdotnet-hi-world.dll"]
#