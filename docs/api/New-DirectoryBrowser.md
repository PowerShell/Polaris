---
external help file: Polaris-help.xml
layout: default
Module Name: Polaris
online version: https://powershell.github.io/Polaris/docs/api/New-DirectoryBrowser.html
schema: 2.0.0
title: New-DirectoryBrowser
type: api
---

# New-DirectoryBrowser

## SYNOPSIS
Renders a directory browser in HTML

## SYNTAX

```
New-DirectoryBrowser [-RequestedItem] <DirectoryInfo> [[-HeaderName] <String>]
 [[-DirectoryBrowserPath] <String>] [<CommonParameters>]
```

## DESCRIPTION
Creates HTML that can be used as a directory browser

## EXAMPLES

### EXAMPLE 1
```
New-DirectoryBrowser -RequestedItem $directoryInfo
```

### EXAMPLE 2
```
New-DirectoryBrowser -RequestedItem $directoryInfo -DirectoryBrowserPath ./MyContent
```

## PARAMETERS

### -RequestedItem
The directory you would like to generate HTML for

```yaml
Type: DirectoryInfo
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -HeaderName
The name you would like displayed at the top of the directory browser

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: Polaris Directory Browser
Accept pipeline input: False
Accept wildcard characters: False
```

### -DirectoryBrowserPath
The current path in the directory browser relative to the root of the directory
browser (not the root of the site).

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
