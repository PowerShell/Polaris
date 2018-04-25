$Script:Polaris = $null

# Handles the removal of the module
$ExecutionContext.SessionState.Module.OnRemove =
{
    Stop-Polaris -ErrorAction SilentlyContinue
    Clear-Polaris
}.GetNewClosure()

# Classes used in Polaris.Class.Ps1 need to be loaded before it
$Classes = @( Get-ChildItem -Path $PSScriptRoot\lib\*.ps1 -ErrorAction SilentlyContinue | where {$_.Name -ne "Polaris.Class.ps1"})
$Classes += @( Get-ChildItem -Path $PSScriptRoot\lib\Polaris.Class.ps1 -ErrorAction SilentlyContinue )

# Get public and private function definition files.
$Public = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )

# Dot source the files
Foreach ($import in @($Public + $Private + $Classes)) {
    Try {
        . $import.fullname
    }
    Catch {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

# Here I might...
# Read in or create an initial config file and variable
# Export Public functions ($Public.BaseName) for WIP modules
# Set variables visible to the module and its functions only

Export-ModuleMember -Function $Public.Basename
