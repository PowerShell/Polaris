function CreateNewPolarisIfNeeded () {
    if ( -not $script:Polaris ) {
        $script:Polaris = [Polaris]::New(
            [Action[string]] { param($str) Write-Verbose "$str" } )
    }
}
