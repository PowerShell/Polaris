---
external help file: Polaris-help.xml
layout: default
Module Name: Polaris
online version: https://powershell.github.io/Polaris/docs/api/New-PolarisRoute.html
schema: 2.0.0
title: New-PolarisRoute
type: api
---

# New-PolarisRoute

## SYNOPSIS
Add web route.

## SYNTAX

### Scriptblock
```
New-PolarisRoute [-Path] <String> [-Method] <String> [-Scriptblock] <ScriptBlock> [-Force] [-Polaris <Object>]
 [<CommonParameters>]
```

### ScriptPath
```
New-PolarisRoute [-Path] <String> [-Method] <String> -ScriptPath <String> [-Force] [-Polaris <Object>]
 [<CommonParameters>]
```

## DESCRIPTION
Create web route for server to serve.

## EXAMPLES

### EXAMPLE 1
```
New-PolarisRoute -Path "helloworld" -Method "GET" -Scriptblock { $Response.Send( 'Hello World' ) }
```

To view results:
Start-Polaris
Start-Process http://localhost:8080/helloworld

### EXAMPLE 2
```
New-PolarisRoute -Path "helloworld" -Method "GET" -ScriptPath D:\Scripts\Example.ps1
```

To view results, assuming default port:
Start-Polaris
Start-Process http://localhost:8080/helloworld

## PARAMETERS

### -Path
Path (path/route/endpoint) of the web route to to be serviced.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Method
HTTP verb/method to be serviced.
Valid values are GET, HEAD, POST, PUT, DELETE, CONNECT, OPTIONS, TRACE

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Scriptblock
Scriptblock that will be triggered when web route is called.

```yaml
Type: ScriptBlock
Parameter Sets: Scriptblock
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ScriptPath
Full path and name of script that will be triggered when web route is called.

```yaml
Type: String
Parameter Sets: ScriptPath
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force
Use -Force to overwrite any existing web route for the same path and method.

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

### -Polaris
A Polaris object
Defaults to the script scoped Polaris

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
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
