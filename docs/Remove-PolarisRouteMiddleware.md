---
external help file: Polaris-help.xml
Module Name: Polaris
online version:
schema: 2.0.0
---

# Remove-PolarisRouteMiddleware

## SYNOPSIS
Remove route middleware.

## SYNTAX

```
Remove-PolarisRouteMiddleware [[-Name] <String[]>] [[-Polaris] <Object>] [<CommonParameters>]
```

## DESCRIPTION
Remove route middleware matching the specified name(s).

## EXAMPLES

### EXAMPLE 1
```
Remove-PolarisRouteMiddleware -Name JsonBodyParser
```

### EXAMPLE 2
```
Remove-PolarisRouteMiddleware
```

Removes all route middleware.

### EXAMPLE 3
```
Remove-PolarisRouteMiddleware -Name ParamCheck*, ParamVerify*
```

Removes any route middleware with names starting with ParamCheck or ParamVerify.

### EXAMPLE 4
```
Get-PolarisRouteMiddleware | Remove-PolarisRouteMiddleware
```

Removes all route middleware.

## PARAMETERS

### -Name
Name of the middleware to remove.
Accepts multiple values and wildcards.
Accepts pipeline input.
Accepts pipeline input by property name.
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
