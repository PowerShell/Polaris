
Import-Module ./Polaris/0.1.0/Polaris -Verbose
Import-Module ./PSHTML/PSHTML.psd1 -Verbose

New-PolarisStaticRoute -RoutePath "/assets" -FolderPath "./assets"
New-PolarisStaticRoute -RoutePath "/routes" -FolderPath "./routes"

./routes/home.ps1
./routes/kubernetes.ps1
./routes/powershell.ps1

Start-Polaris -Port 8080 -MinRunspaces 3 -MaxRunspaces 10

while ($true) {

    Start-sleep -seconds 10
}