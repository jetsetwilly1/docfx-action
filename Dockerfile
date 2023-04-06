FROM ubuntu:22.04 as unzipper 

ARG DOCFX_VERSION=v2.59.4

RUN apt-get update -y \
    && apt-get install -yqq wget unzip\
    && wget -O /tmp/docfx.zip https://github.com/dotnet/docfx/releases/download/v2.64.0/docfx-win-x64-v2.64.0.zip \
    && unzip -o /tmp/docfx.zip -d /docfx

FROM mono:latest

ARG DOTNET_SDK=dotnet-sdk-7.0

RUN apt update -yqq \
    && apt install -yqq gpg apt-transport-https \
    && curl -o - https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/microsoft.asc.gpg \
    && curl -o /etc/apt/sources.list.d/microsoft-prod.list https://packages.microsoft.com/config/debian/10/prod.list \
    && chown root:root /etc/apt/trusted.gpg.d/microsoft.asc.gpg \
                       /etc/apt/sources.list.d/microsoft-prod.list \
    && apt update -yqq \
    && apt install -yqq \
        git \
        ${DOTNET_SDK} \
        wkhtmltopdf \
    && rm -rf /var/lib/apt/lists/*

COPY --from=unzipper /docfx /opt/docfx
ADD ./entrypoint.sh /usr/local/bin/docfx

ENTRYPOINT [ "docfx" ]
