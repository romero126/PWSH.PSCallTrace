using namespace System.Management.Automation
using namespace System.Management.Automation.Internal


function Get-BaseParameter {
    <#
        .Synopsis
        Get-BaseParameters is used in 'Magic'
        .Description
        Used for build up into New-PSCallTraceHook.ps1
        .Example
        . {
            function MyFunction 
                dynamicparam {
                    Get-BaseParameter "Microsoft.PowerShell.Utility\Write-Host"
                }
            }
        }
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $BaseFunction
    )
    $BaseCommand = Get-Command $BaseFunction
    $CommonParameters = [CommonParameters].GetProperties().Name
    if ($BaseCommand) {
        $Dictionary = [RuntimeDefinedParameterDictionary]::new()
        foreach ($Parameter in $BaseCommand.Parameters.GetEnumerator()) {
            $Value = $Parameter.Value
            $Key = $Parameter.Key
            if ($Key -notin $CommonParameters) {
                $Parameter = [RuntimeDefinedParameter]::new(
                    $Key, $Value.ParameterType, $Value.Attributes)
                $Dictionary.Add($Key, $Parameter)
            }
        }
        return $Dictionary
    }
}