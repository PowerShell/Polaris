---
external help file: Polaris-help.xml
Module Name: Polaris
online version:
schema: 2.0.0
---

# Start-Polaris

## SYNOPSIS
Start Polaris web server.

## SYNTAX

```
Start-Polaris [[-Port] <Int32>] [[-MinRunspaces] <Int32>] [[-MaxRunspaces] <Int32>]
 [-UseJsonBodyParserMiddleware] [[-Polaris] <Object>] [<CommonParameters>]
```

## DESCRIPTION
Start Polaris web server.

## EXAMPLES

### EXAMPLE 1
```
Start-Polaris
```

### EXAMPLE 2
```
Start-Polaris -Port 8081 -MinRunspaces 2 -MaxRunspaces 10 -UseJsonBodyParserMiddleware
```

## PARAMETERS

### -Port
Port number to listen on.
Defaults to 8080.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: 8080
Accept pipeline input: False
Accept wildcard characters: False
```

### -MinRunspaces
Minimum number of PowerShell runspaces for web server to use.
Defaults to 1.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: 1
Accept pipeline input: False
Accept wildcard characters: False
```

### -MaxRunspaces
Maximum number of PowerShell runspaces for web server to use.
Defaults to 1.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: 1
Accept pipeline input: False
Accept wildcard characters: False
```

### -UseJsonBodyParserMiddleware
When present, JSONBodyParser middleware will be created, if needed.

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
Position: 4
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
