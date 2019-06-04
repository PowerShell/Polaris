---
external help file: Polaris-help.xml
layout: default
Module Name: Polaris
online version: https://powershell.github.io/Polaris/docs/api/New-PolarisStaticRoute.html
schema: 2.0.0
title: New-PolarisStaticRoute
type: api
---

# New-PolarisStaticRoute

## SYNOPSIS
Creates web routes to recursively serve folder contents

## SYNTAX

```
New-PolarisStaticRoute [[-RoutePath] <String>] [[-FolderPath] <String>] [[-EnableDirectoryBrowser] <Boolean>]
 [-Force] [[-StandardHTMLFiles] <String[]>] [[-ServeDefaultFile] <Boolean>] [[-Polaris] <Object>]
 [<CommonParameters>]
```

## DESCRIPTION
Creates web routes to recursively serve folder contents.
Perfect for static websites.
Also if a default file (for example index.html) is detected, A route pointing to the
value of the parameter "Routepath" will be created.

## EXAMPLES

### EXAMPLE 1
```
New-PolarisStaticRoute -RoutePath 'public' -Path D:\FolderShares\public
```

Creates web routes for GET method for each file recursively within D:\FolderShares\public
at relative path /public, for example, http://localhost:8080/public/File1.html

### EXAMPLE 2
```
Get-PolarisRoute -Path 'public/*' -Method GET | Remove-PolarisRoute
```

New-PolarisStaticRoute -RoutePath 'public' -Path D:\FolderShares\public
Updates website web routes.
(Deletes all existing web routes and creates new web routes
for all existing folder content.)

## PARAMETERS

### -RoutePath
Root route that the folder path will be served to.
Defaults to "/".

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: /
Accept pipeline input: False
Accept wildcard characters: False
```

### -FolderPath
Full path and name of the folder to serve.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: ./
Accept pipeline input: False
Accept wildcard characters: False
```

### -EnableDirectoryBrowser
Enables the directory browser when the user requests a folder

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: True
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force
Use -Force to overwrite existing web route(s) for the same paths.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -StandardHTMLFiles
List of file names that Polaris will look for when ServeDefaultFile is $True

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: @("index.html", "index.htm", "default.html", "default.htm")
Accept pipeline input: False
Accept wildcard characters: False
```

### -ServeDefaultFile
Polaris will look for a default file matching one of the file names specified in the
StandardHTMLFiles parameter and, if found, will serve that file when no specific file is requested

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: True
Accept pipeline input: False
Accept wildcard characters: False
```

### -Polaris
A Polaris object
Defaults to the script scoped Polaris

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: $Script:Polaris
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Folders are not browsable.
New files are not added dynamically.

## RELATED LINKS
