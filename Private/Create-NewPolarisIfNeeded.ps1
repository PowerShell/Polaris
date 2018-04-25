function CreateNewPolarisIfNeeded () {
    if ( -not $Script:Polaris ) {
        $Script:Polaris = [Polaris]::New(
            [Action[string]] { param($str) Write-Verbose "$str" } )
    }
}
