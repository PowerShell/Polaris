function CreateNewPolarisIfNeeded () {
    if ( -not $script:Polaris ) {
        $script:Polaris = New-Object -TypeName PolarisCore.Polaris -ArgumentList @(
            [Action[string]] { param($str) Write-Verbose "$str" } )
    }
}
