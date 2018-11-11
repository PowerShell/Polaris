---
external help file: Polaris-help.xml
layout: default
Module Name: Polaris
online version: https://powershell.github.io/Polaris/docs/api/New-ScriptblockCallback.html
schema: 2.0.0
title: New-ScriptblockCallback
type: api
---

# New-ScriptblockCallback

## SYNOPSIS
Allows running Scriptblocks via .NET async callbacks.

## SYNTAX

```
New-ScriptblockCallback [-Callback] <ScriptBlock> [<CommonParameters>]
```

## DESCRIPTION
Allows running Scriptblocks via .NET async callbacks.
Internally this is
managed by converting .NET async callbacks into .NET events.
This enables
PowerShell 2.0 to run Scriptblocks indirectly through Register-ObjectEvent.

## EXAMPLES

### EXAMPLE 1
```
You wish to run a scriptblock in reponse to a callback. Here is the .NET
```

method signature:

void Bar(AsyncCallback handler, int blah)

ps\> \[foo\]::bar((New-ScriptblockCallback { ...
}), 42)

## PARAMETERS

### -Callback
Specify a Scriptblock to be executed in response to the callback.
Because the Scriptblock is executed by the eventing subsystem, it only has
access to global scope.
Any additional arguments to this function will be
passed as event MessageData.

```yaml
Type: ScriptBlock
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### A System.AsyncCallback delegate.
## NOTES

## RELATED LINKS
