<#
.SYNOPSIS
Clears the internal instance of Polaris
.DESCRIPTION
Clears the internal Polaris .NET Standard object.  The instance will be reinstantiated in other module calls.
.EXAMPLE
Clear-Polaris
.NOTES
Should only be used for testing
#>
function Clear-Polaris {
    if ($Script:Polaris) {
        Remove-Variable -Name Polaris -Scope script
    }
}
