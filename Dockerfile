FROM microsoft/powershell
ARG PORT=8080
ENV LATEST_PS_VERSION "6.0.0-beta.8"

WORKDIR /opt/microsoft/powershell/${LATEST_PS_VERSION}/Modules/
RUN mkdir -p Polaris/PolarisCore/bin/Debug/netstandard2.0/
ADD PolarisCore/bin/Debug/netstandard2.0/* Polaris/PolarisCore/bin/Debug/netstandard2.0/
ADD Polaris.psm1 Polaris/
ADD Polaris.psd1 Polaris/

EXPOSE ${PORT}

WORKDIR /
CMD powershell