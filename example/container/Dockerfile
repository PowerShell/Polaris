
#final stage
FROM mcr.azurecr.io/powershell:6.1.0-ubuntu-18.04

COPY  /website /app
COPY /Polaris /app/Polaris
COPY /PSHTML /app/PSHTML
WORKDIR /app
LABEL Name=eleu2018-k8s-web Version=0.0.1
EXPOSE 8080

ENTRYPOINT ["pwsh", "./Start-Website.ps1" ]
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 CMD [ "pwsh", "-command", "if($(Invoke-WebRequest 'http://localhost:8080').statusCode -ne 200) {exit 1}" ]