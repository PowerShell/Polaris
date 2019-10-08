#
# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.
#

class PolarisRoute {
    
    [string]
    $Method

    [scriptblock]
    $Scriptblock

    [string]
    hidden $_Path
    
    [RegEx]
    hidden $_Regex

    PolarisRoute([string]$Method, $Path, [scriptblock]$Scriptblock) {
        $this.Scriptblock = $Scriptblock
        $this.Method = $Method
        $this._Path = [PolarisRoute]::SanitizePath($Path)
        $this._Regex = [PolarisRoute]::ConvertPathToRegex($Path)

        $Path_Get = {
            # Getter
            return $this._Path
        }

        $Path_Set = {
            # Setter
            param($value)
            $this._Path = [PolarisRoute]::SanitizePath($value)
            $this._Regex = [PolarisRoute]::ConvertPathToRegex($value)
        }

        $PathProperty = @{
            Name        = "Path"
            Value       = $Path_Get
            SecondValue = $Path_Set
            MemberType  = "ScriptProperty"
        }

        $this | Add-Member @PathProperty

        $Regex_Get = {
            # Getter
            return $this._Regex
        }

        $Regex_Set = {
            # Setter
            param($value)
            Write-Warning "Regex is a read-only property. Update the Path property instead."
        }

        $RegexProperty = @{
            Name        = "Regex"
            Value       = $Regex_Get
            SecondValue = $Regex_Set
            MemberType  = "ScriptProperty"
        }

        $this | Add-Member @RegexProperty


    }

    hidden static [RegEx] ConvertPathToRegex([string]$Path) {
        Write-Debug "Path: $path"
        # Replacing all periods with an escaped period to prevent RegEx wildcard
        $path = $path -replace '\.', '\.'
        # Replacing all - with \- to escape the dash
        $path = $path -replace '-', '\-'
        # Replacing the wildcard character * with a RegEx aggressive match .*
        $path = $path -replace '\*', '.*'
        # Creating a strictly matching regular expression that must match beginning (^) to end ($)
        $path = "^$path$"
        # Creating a route based parameter
        #   Match any and all word based characters after the : for the name of the parameter
        #   Use the name in a named capture group that will show up in the $matches variable
        #   References:
        #       - https://docs.microsoft.com/en-us/dotnet/standard/base-types/grouping-constructs-in-regular-expressions#named_matched_subexpression
        #       - https://technet.microsoft.com/en-us/library/2007.11.powershell.aspx
        #       - https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_automatic_variables?view=powershell-6#matches
        $path = $path -replace ":(\w+)(\?{0,1})", '(?<$1>.+)$2'

        Write-Debug "Parsed Regex: $path"
        return [RegEx]::New($path)
    }

    hidden static [RegEx] ConvertPathToRegex([RegEx]$Path) {
        Write-Debug "Path is a RegEx"
        return $Path
    }

    hidden static [string] SanitizePath([string]$Path) {
        $SanitizedPath = $Path.TrimEnd('/')

        if ([string]::IsNullOrEmpty($SanitizedPath)) { $SanitizedPath = "/" }

        return $SanitizedPath
    }

    hidden static [string] SanitizePath([RegEx]$Path) {
        return $Path
    }
}
