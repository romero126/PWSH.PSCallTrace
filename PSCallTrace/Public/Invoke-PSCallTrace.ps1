function Invoke-PSCallTrace {
    <#
        .Synopsis
        Invoke-PSCallTrace generates debug information, and loads it into the PSCallTrace objects.
        .Description
        Invoke-PSCallTrace generates debug information, and loads it into the PSCallTrace objects.

        Note: This is an advanced feature, that allows you to specifically grab CallTrace data
        directly in your code without the use of a TraceHook.

        See Examples for additional information.

        .Example
        . {

            function MyFunction {
                begin { 
                    $PSStackData = Invoke-PSCallTrace -Begin
                }
                process {
                    Invoke-PSCallTrace -Object $PSStackData -Process
                }
                end {
                    Invoke-PSCallTrace -Object $PSStackData -End
                }
            }
        }
    #>
    [CmdletBinding()]
    param(
        [ValidateRange(1,10)]
        [int]$Level = 1,
        [PSCustomObject]$Object,
        [switch]$Begin,
        [switch]$Process,
        [switch]$End
    )
    if ($Begin) {
        $CallStack = Get-PSCallStack
        $result = [PSCustomObject]@{
            PSTypeName     = "PowerShell.PSCallTrace"
            Timestamp      = [datetime]::Now
            EndTime        = $null
            Measure        = $null
            Ticks          = $null
            Name           = $CallStack[$Level].Command
            Script         = $CallStack[$Level+1].Command
            ModuleName     = $CallStack[$Level+1].InvocationInfo.MyCommand.ModuleName
            File           = $CallStack[$Level+1].Position.File
            Line           = $CallStack[$Level+1].Position.StartLineNumber
            Message        = ($Callstack[$Level].InvocationInfo.BoundParameters.Values.GetEnumerator() | % { $_ }) -join " "
            Parameters     = $(
                                ($CallStack[$Level].InvocationInfo.BoundParameters.GetEnumerator() | % { $_ }),
                                ($CallStack[$Level].InvocationInfo.UnboundArguments.GetEnumerator() | % { $_ })
                            )
            PipelineArgs   = ($Callstack[$Level+1].Position.Text -Replace $Callstack[$Level].InvocationInfo.InvocationName, "").TrimStart(" ")
            InvocationInfo = $CallStack[$Level].InvocationInfo
            CallStack      = $CallStack
        }
        <#
        $DisplayProperties = @('TimeStamp', 'Ticks', 'FunctionName', 'Message', 'Line', 'Script', 'ModuleName', 'File')
        $DefaultDisplay = New-Object System.Management.Automation.PSPropertySet("DefaultDisplayPropertySet", [string[]]$DisplayProperties)
        $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($DefaultDisplay)
        $Result | Add-Member MemberSet PSStandardMembers $PSStandardMembers
        #>
        $Host.PSCallTrace.Add($result) | out-null
        return $result
    }
    if ($Process) { return }
    if ($End) {
        if ($Object) {
            $Object.EndTime = [datetime]::Now
            $Object.Measure = New-TimeSpan -Start $Object.Timestamp -End $Object.EndTime
            $Object.Ticks   = $Object.Measure.Ticks
        }
        return
    }
}