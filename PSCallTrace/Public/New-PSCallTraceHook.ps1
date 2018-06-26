#Todo Fix Begin Process and End Error when Piping into a hooked function.

function New-PSCallTraceHook {
    <#
        .Synopsis
        New-PSCallTraceHook hooks an existing PowerShell function in this session in order to properly generate callback data.
        .Description
        New-PSCallTraceHook -Name Write-Host -Module Microsoft.PowerShell.Utility
        .Example
        . {
            New-PSCallTraceHook -Name Write-Host -Module Microsoft.PowerShell.Utility
            Write-Host "My String"
            Get-PSCallTrace | ft
        }
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory)]
        [String]$Name,
        [Parameter()]
        [String]$Module = "PSCallTraceHook",
        [Parameter()]
        [Switch]$DisableParamMirroring
    )
    if ($Module -eq "PSCallTraceHook") {
        if (Test-Path ("Function:{0}\{1}" -f $Module, $Name)) {
            Throw "Cannot Hook Function, It looks like it is already hooked"
        }
        Rename-Item -Path "Function:Global:$Name" -NewName ("Global:{0}\{1}" -f $Module, $Name)
    }
    $MetaData = New-Object System.Management.Automation.CommandMetaData (Get-Command "$Module\$Name")
    $HookedFunction = [System.Management.Automation.ProxyCommand]::Create($MetaData)
    $HookedFunction = $HookedFunction -Replace "steppablePipeline.Begin", "PSStackData = Invoke-PSCallTrace -Begin; `$steppablePipeline.Begin"
    $HookedFunction = $HookedFunction -Replace "steppablePipeline.Process", "PSStackData = Invoke-PSCallTrace -Process; `$steppablePipeline.Process"
    $HookedFunction = $HookedFunction -Replace "steppablePipeline.End", "PSStackData = Invoke-PSCallTrace -End; `$steppablePipeline.End"

    if (Test-Path Function:$Name) {
        Set-Item -Path Function:Global:$Name -Value $HookedFunction | out-null
    } else {
        New-Item -Path Function: -Name "Global:$Name" -Value $HookedFunction | out-null
    }
}