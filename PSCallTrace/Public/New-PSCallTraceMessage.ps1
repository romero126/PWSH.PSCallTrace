function New-PSCallTraceMessage {
    param(
        [Parameter(Mandatory)]
        [ValidateSet("Begin","Process","End","Error","Warning","Information")]
        [String]$MessageType,
        [Parameter()][AllowNull()]
        [object]$Message,
        [Parameter()]
        [int]$Level = 2
    )
    $CallStack = Get-PSCallStack
    $Result = [PSCustomObject]@{
        PSTypeName     = "PowerShell.PSCallTrace"
        Type           = "Command"
        StartTime      = [datetime]::Now
        EndTime        = $null
        ExecutionTime  = $null
        Name           = $CallStack[$Level].Command
        Script         = $CallStack[$Level+1].Command
        ModuleName     = $CallStack[$Level+1].InvocationInfo.MyCommand.ModuleName
        File           = $CallStack[$Level+1].Position.File
        Line           = $CallStack[$Level+1].Position.StartLineNumber
        OffsetInLine   = $null
        Message        = $null
        Parameters     = @(
                            ($CallStack[$Level].InvocationInfo.BoundParameters.GetEnumerator() | % { $_ }),
                            ($CallStack[$Level].InvocationInfo.UnboundArguments.GetEnumerator() | % { $_ })
                        )
        PipelineArgs   = ($Callstack[$Level+1].Position.Text -Replace $Callstack[$Level].InvocationInfo.InvocationName, "").TrimStart(" ")
        InvocationInfo = $CallStack[$Level].InvocationInfo
        CallStack      = $CallStack
    }
    switch ($MessageType) {
        "Begin" {
            $Result.Message = ($Callstack[$Level].InvocationInfo.BoundParameters.Values.GetEnumerator() | % { $_ }) -join " "
        }
        "Process" { }
        "End" {
            $Result = $Message
            $Result.EndTime = [datetime]::Now
            $Result.ExecutionTime = New-TimeSpan -Start $Result.StartTime -End $Result.EndTime
        }
        "Error" {
            $Result.Type = "Exception"
            $Result.Line = $Message.InvocationInfo.ScriptLineNumber
            $Result.OffsetInLine = $Message.InvocationInfo.OffsetInLine
            $Result.Parameters = @(
                ($Message.InvocationInfo.BoundParameters.GetEnumerator() | % { $_ }),
                ($Message.InvocationInfo.UnboundArguments.GetEnumerator() | % { $_ })
            )
            $Result.Message = $Message
        }
        Default {
            $Result.Message = $Message
        }
    }

    if ($MessageType -ne "End") {
        $Host.PSCallTrace.Add($Result) | out-null
    }
    if ($MessageType -eq "Begin") {
        return $Result
    }
}