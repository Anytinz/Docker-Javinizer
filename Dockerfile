# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

# Docker image file that describes an Alpine3.8 image with PowerShell installed from .tar.gz file(s)

# Define arg(s) needed for the From statement
ARG fromTag=3.8
ARG imageRepo=alpine

FROM ${imageRepo}:${fromTag} AS installer-env

# Define Args for the needed to add the package
ARG PS_VERSION=6.2.0
ARG PS_PACKAGE=powershell-${PS_VERSION}-linux-alpine-x64.tar.gz
ARG PS_PACKAGE_URL=https://github.com/PowerShell/PowerShell/releases/download/v${PS_VERSION}/${PS_PACKAGE}
ARG PS_INSTALL_VERSION=6

# define the folder we will be installing PowerShell to
ENV PS_INSTALL_FOLDER=/opt/microsoft/powershell/$PS_INSTALL_VERSION

# Download the Linux tar.gz and save it
# Create the install folder
# Unzip the Linux tar.gz
RUN wget -O /tmp/linux.tar.gz ${PS_PACKAGE_URL} \
    && mkdir -p ${PS_INSTALL_FOLDER} \
    && tar zxf /tmp/linux.tar.gz -C ${PS_INSTALL_FOLDER} -v

# Start a new stage so we lose all the tar.gz layers from the final image
FROM ${imageRepo}:${fromTag}

# Copy only the files we need from the previous stage
COPY --from=installer-env ["/opt/microsoft/powershell", "/opt/microsoft/powershell"]

# Define Args and Env needed to create links
ARG PS_INSTALL_VERSION=6
ENV PS_INSTALL_FOLDER=/opt/microsoft/powershell/$PS_INSTALL_VERSION \
    \
    # Define ENVs for Localization/Globalization
    DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    # set a fixed location for the Module analysis cache
    PSModuleAnalysisCachePath=/var/cache/microsoft/powershell/PSModuleAnalysisCache/ModuleAnalysisCache

# Install dotnet dependencies and ca-certificates
RUN apk add --no-cache \
    ca-certificates \
    less \
    \
    # PSReadline/console dependencies
    ncurses-terminfo-base \
    \
    # .NET Core dependencies
    krb5-libs \
    libgcc \
    libintl \
    libssl1.0 \
    libstdc++ \
    tzdata \
    userspace-rcu \
    zlib \
    icu-libs \
    && apk -X https://dl-cdn.alpinelinux.org/alpine/edge/main add --no-cache \
    lttng-ust \
    \
    # Create the pwsh symbolic link that points to powershell
    && ln -s ${PS_INSTALL_FOLDER}/pwsh /usr/bin/pwsh \
    # Give all user execute permissions and remove write permissions for others
    && chmod a+x,o-w ${PS_INSTALL_FOLDER}/pwsh \
    # intialize powershell module cache
    && pwsh \
        -NoLogo \
        -NoProfile \
        -Command " \
          \$ErrorActionPreference = 'Stop' ; \
          \$ProgressPreference = 'SilentlyContinue' ; \
          while(!(Test-Path -Path \$env:PSModuleAnalysisCachePath)) {  \
            Write-Host "'Waiting for $env:PSModuleAnalysisCachePath'" ; \
            Start-Sleep -Seconds 6 ; \
          }"

# Define args needed only for the labels
ARG PS_VERSION=6.2.0
ARG IMAGE_NAME=mcr.microsoft.com/powershell:alpine-3.8
ARG VCS_REF="none"

# Add label last as it's just metadata and uses a lot of parameters
LABEL maintainer="PowerShell Team <powershellteam@hotmail.com>" \
    readme.md="https://github.com/PowerShell/PowerShell/blob/master/docker/README.md" \
    description="This Dockerfile will install the latest release of PowerShell." \
    org.label-schema.usage="https://github.com/PowerShell/PowerShell/tree/master/docker#run-the-docker-image-you-built" \
    org.label-schema.url="https://github.com/PowerShell/PowerShell/blob/master/docker/README.md" \
    org.label-schema.vcs-url="https://github.com/PowerShell/PowerShell-Docker" \
    org.label-schema.name="powershell" \
    org.label-schema.vendor="PowerShell" \
    org.label-schema.vcs-ref=${VCS_REF} \
    org.label-schema.version=${PS_VERSION} \
    org.label-schema.schema-version="1.0" \
    org.label-schema.docker.cmd="docker run ${IMAGE_NAME} pwsh -c '$psversiontable'" \
    org.label-schema.docker.cmd.devel="docker run ${IMAGE_NAME}" \
    org.label-schema.docker.cmd.test="docker run ${IMAGE_NAME} pwsh -c Invoke-Pester" \
    org.label-schema.docker.cmd.help="docker run ${IMAGE_NAME} pwsh -c Get-Help"

# Anytinz's Mod
ARG javinizer_version=1.1.11-Chinese
ARG javinizer_package_url=https://github.com/anytinz/Javinizer/releases/download/${javinizer_version}/Javinizer.zip

RUN apk update \
    && apk add --no-cache \
    python3-dev \
    jpeg-dev \
    zlib-dev \
    bash \
    # build-deps
    && apk add --no-cache --virtual build-deps \
    build-base \
    linux-headers \
    # Install Python module dependencies
    && pip3 install --no-cache-dir --upgrade pip \
    && pip3 install --no-cache-dir pillow cloudscraper googletrans \ 
    # Delete cache
    && apk del build-deps \
    # Download Javinizer
    && wget -P /tmp ${javinizer_package_url} \
    && unzip -d / /tmp/Javinizer.zip

COPY start.ps1 /Javinizer
ENTRYPOINT ["pwsh","/Javinizer/start.ps1"]