#Todo Fix Begin Process and End Error when Piping into a hooked function.

function New-PSCallTraceHook {
    <#
        .Synopsis
        New-PSCallTraceHook hooks an existing PowerShell function in this session in order to properly generate callback data.
        .Description
        New-PSCallTraceHook -FunctionName Write-Host -Module Microsoft.PowerShell.Utility
        .Example
        . {
            New-PSCallTraceHook -FunctionName Write-Host -Module Microsoft.PowerShell.Utility
            Write-Host "My String"
            Get-PSCallTrace | ft
        }
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory)]
        [String]$FunctionName,
        [Parameter(Mandatory)]
        [String]$Module
    )
    $NewFunction = {
        [CmdletBinding()]
        param()
        dynamicparam {
            Get-BaseParameters "!Module\!FunctionName"
        }
        begin {
            $PSStackData = Invoke-PSCallTrace -Begin
            $wrappedCmd = (get-command !Module\!FunctionName)
            $scriptCmd = {& $wrappedCmd @PSBoundParameters }
            $steppablePipeline = $scriptCmd.GetSteppablePipeline()
            $steppablePipeline.Begin($PSCmdlet)
        }
        process {
            Invoke-PSCallTrace -Object $PSStackData -Process
            $steppablePipeline.Process($_)
        }
        end {
            Invoke-PSCallTrace -Object $PSStackData -End
            $steppablePipeline.End()
        }
    }
    $NewFunction = [ScriptBlock]::Create(
        ($NewFunction.ToString() -Replace "!Module", $Module -Replace "!FunctionName", $FunctionName)
    )
    if (Test-Path Function:$FunctionName) {
        Set-Item -Path Function:Global:$FunctionName -Value $NewFunction | out-null
    } else {
        New-Item -Path Function: -Name "Global:$FunctionName" -Value $NewFunction | out-null
    }
}