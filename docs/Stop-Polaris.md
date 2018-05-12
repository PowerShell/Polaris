---
external help file: Polaris-help.xml
Module Name: Polaris
online version:
schema: 2.0.0
---

# Stop-Polaris

## SYNOPSIS
Stop Polaris web server.

## SYNTAX

```
Stop-Polaris [[-ServerContext] <Object>] [<CommonParameters>]
```

## DESCRIPTION
Stop Polaris web server.

## EXAMPLES

### EXAMPLE 1
```
Stop-Polaris
```

### EXAMPLE 2
```
Stop-Polaris -ServerContext $app
```

## PARAMETERS

### -ServerContext
Polaris instance to stop.
Defaults to the global instance.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
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
