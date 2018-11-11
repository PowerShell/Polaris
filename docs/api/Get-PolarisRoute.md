---
external help file: Polaris-help.xml
layout: default
Module Name: Polaris
online version: https://powershell.github.io/Polaris/docs/api/Get-PolarisRoute.html
schema: 2.0.0
title: Get-PolarisRoute
type: api
---

# Get-PolarisRoute

## SYNOPSIS
Get web routes.

## SYNTAX

```
Get-PolarisRoute [[-Path] <String[]>] [[-Method] <String[]>] [[-Polaris] <Object>] [<CommonParameters>]
```

## DESCRIPTION
Get web routes filtered by Path and Method, as specified.

## EXAMPLES

### EXAMPLE 1
```
Get-PolarisRoute
```

Gets all web routes.

### EXAMPLE 2
```
Get-PolarisRoute -Path 'helloworld' -Method 'GET'
```

Gets the web route for method GET for path helloworld.

### EXAMPLE 3
```
Get-PolarisRoute -Path 'sub1/sub2/*'
```

Gets all web routes for all methods for paths starting with sub1/sub2/.

### EXAMPLE 4
```
Get-PolarisRoute -Path 'sub1/sub2/*' -Method GET, POST
```

Gets all web routes for GET and POST methods for paths starting with sub1/sub2/.

### EXAMPLE 5
```
Get-PolarisRoute -Method Delete
```

Gets all web routes for DELETE methods for all paths.

## PARAMETERS

### -Path
Path of the route(s) to get.
Accepts pipeline input.
Accepts pipeline input by property name.
Accepts multiple values and wildcards.
Defaults to all paths (*).

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: *
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Method
Method(s) of the route(s) to get.
Accepts pipeline input by property name.
Accepts multiple values and wildcards.
Defaults to all methods (*).

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: *
Accept pipeline input: True (ByPropertyName)
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
Position: 3
Default value: $Script:Polaris
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
