---
external help file: Polaris-help.xml
Module Name: Polaris
online version:
schema: 2.0.0
---

# Get-PolarisRouteMiddleware

## SYNOPSIS
Get route middleware.

## SYNTAX

```
Get-PolarisRouteMiddleware [[-Name] <String[]>] [[-Polaris] <Object>] [<CommonParameters>]
```

## DESCRIPTION
Get route middleware matching the specified name(s).

## EXAMPLES

### EXAMPLE 1
```
Get-PolarisRouteMiddleware
```

### EXAMPLE 2
```
Get-PolarisRouteMiddleware -Name JsonBodyParser
```

### EXAMPLE 3
```
Get-PolarisRouteMiddleware -Name ParamCheck*, ParamVerify*
```

## PARAMETERS

### -Name
Name of the middleware to get.
Accepts pipeline input.
Accepts pipeline input by property name.
Accepts multiple values and wildcards.
Defaults to all names (*).

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

### -Polaris
A Polaris object
Defaults to the script scoped Polaris

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: $Script:Polaris
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
