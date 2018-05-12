---
external help file: Polaris-help.xml
Module Name: Polaris
online version:
schema: 2.0.0
---

# New-PolarisRouteMiddleware

## SYNOPSIS
Add new route middleware.

## SYNTAX

### Scriptblock
```
New-PolarisRouteMiddleware [-Name] <String> [-Scriptblock] <ScriptBlock> [-Force] [-Polaris <Object>]
 [<CommonParameters>]
```

### ScriptPath
```
New-PolarisRouteMiddleware [-Name] <String> -ScriptPath <String> [-Force] [-Polaris <Object>]
 [<CommonParameters>]
```

## DESCRIPTION
Creates new route middleware.
Route middleware scripts are used to
manipulate request and response objects and run before web route scripts.

## EXAMPLES

### EXAMPLE 1
```
$JsonBodyParserMiddleware =
{
    if ($Request.BodyString -ne $null) {
        $Request.Body = $Request.BodyString | ConvertFrom-Json
    }
}
New-PolarisRouteMiddleware -Name JsonBodyParser -Scriptblock $JsonBodyParserMiddleware
```

## PARAMETERS

### -Name
Name of the middleware.

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

### -Scriptblock
Scriptblock to run when middleware is triggered.

```yaml
Type: ScriptBlock
Parameter Sets: Scriptblock
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ScriptPath
Full path and name to script to run when middleware is triggered.

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
Use -Force to overwrite any existing middleware with the same name.

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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
