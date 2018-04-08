if (-not ([System.Management.Automation.PSTypeName]'Polaris.AsyncHelper').Type)
{
    Add-Type -Path $PSScriptRoot\Polaris.AsyncHelper.cs
}