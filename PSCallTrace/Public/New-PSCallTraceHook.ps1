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
    $HookFunction = {
        [CmdletBinding()]
        param()
        !DynamicParam
        begin {
            $PSStackData = Invoke-PSCallTrace -Begin
            $wrappedCmd = (get-command !Module\!Name)
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
    if ($Module -eq "PSCallTraceHook") {
        if (Test-Path ("Function:{0}\{1}" -f $Module, $Name)) {
            Throw "Cannot Hook Function, It looks like it is already hooked"
        }
        Rename-Item -Path "Function:Global:$Name" -NewName ("Global:{0}\{1}" -f $Module, $Name)
    }
    
    $DynamicParam = ""
    if (!$DisableParamMirroring) {
        $DynamicParam = {
            dynamicparam {
                Get-BaseParameter "!Module\!Name"
            }
        }.ToString()
    }
    $HookFunction = $HookFunction.ToString()
    $HookFunction = $HookFunction -Replace "!DynamicParam", $DynamicParam
    $HookFunction = $HookFunction -Replace "!Module", $Module -Replace "!Name", $Name
    $HookFunction = [ScriptBlock]::Create(
        $HookFunction
    )
    if (Test-Path Function:$Name) {
        Set-Item -Path Function:Global:$Name -Value $HookFunction | out-null
    } else {
        New-Item -Path Function: -Name "Global:$Name" -Value $HookFunction | out-null
    }
}