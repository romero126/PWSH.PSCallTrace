function Get-PSCallTrace {
    <#
        .Synopsis
        Get-PSCallTrace Displays the output of all of the TraceData that has been accumulated.
        .Description
        Get-PSCallTrace -Filter { $_.FunctionName -eq "Write-Host" } | ft
        See Examples for Additional Usage
        .Example
        . {
            New-PSCallTraceHook -FunctionName Write-Host -Module Microsoft.PowerShell.Utility
            Write-Host "My String"
            Get-PSCallTrace | ft
        }
        .Example
        Get-PSCallTrace -Filter { $_.FunctionName -eq "Write-Host" } | ft
    #>
    [CmdletBinding()]
    param(
        [ScriptBlock]$Filter = { $true }
    )
    $Result = $Host.PSCallTrace
    if ($Filter) {
        $Result = $Result | Where-Object -FilterScript $Filter
    }
    return $Result
}