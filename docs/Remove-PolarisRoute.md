---
external help file: Polaris-help.xml
Module Name: Polaris
online version:
schema: 2.0.0
---

# Remove-PolarisRoute

## SYNOPSIS
Removes the web route.

## SYNTAX

```
Remove-PolarisRoute [[-Path] <String[]>] [[-Method] <String[]>] [[-Polaris] <Object>] [<CommonParameters>]
```

## DESCRIPTION
Removes the web route(s) matching the specified path(s) and method(s).

## EXAMPLES

### EXAMPLE 1
```
Remove-PolarisRoute
```

Removes all existing web routes.

### EXAMPLE 2
```
Remove-PolarisRoute -Path 'helloworld' -Method GET
```

Removes the web route for method GET for path helloworld.

### EXAMPLE 3
```
Remove-PolarisRoute -Path 'sub1/sub2/*'
```

Removes all web routes for all methods for paths starting with sub1/sub2/.

### EXAMPLE 4
```
Remove-PolarisRoute -Path 'sub1/sub2/*' -Method GET, POST
```

Removes all web routes for GET and POST methods for paths starting with sub1/sub2/.

### EXAMPLE 5
```
Get-PolarisRoute -Method Delete | Remove-Method
```

Removes all web routes for DELETE methods for all paths.

## PARAMETERS

### -Path
Path(s) of the route(s) to remove.
Accepts multiple values and wildcards.
Accepts pipeline input.
Accepts pipeline input by property name.
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
Method(s) of the route(s) to remove.
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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
