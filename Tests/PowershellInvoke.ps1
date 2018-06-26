
$Params = (get-command Invoke-WebRequest).ParameterSets.Parameters

foreach ($Param in $Params) {
    #$Param

    
    #$Param | gm -force | ft -a
    #$Param.psadapted | gm -force | ft -a
    $P = $Param | select *
    $P.PSObject.Properties.Name
    $Param | % {
        "Mandatory=`${0}" -f $_.IsMandatory;
        "IsDynamic=`${0}" -f $_.IsDynamic;
        "Position={}"
        "ValueFromPipeline"
        "ValueFromPipelineByPropertyName"
        "ValueFromRemainingArguments"
        "HelpMessage"
        "Aliases"
    }

    
    ("-" * 30)
    <#
    $P.PSObject.Properties | % {
        ($_.Name + "=" + $_.Value)
    }
    "]"
    #>
    #"[Parameter(Mandatory=`${0},IsDynamic=`${1},Position={2},ValueFromPipeline=`${1}, ValueFromPipelineByPropertyName, ValueFromRemainingArguments, HelpMessage,Aliases)]" -f $Param.IsMandatory, IsDynamic, Position, ValueFromPipeline,ValueFromPipelineByPropertyName, ValueFromRemainingArguments
    "[{0}]" -f ($Param.ParameterType.Name -Replace "Parameter", "")
    "`${0}," -f $Param.Name
    break
}













return
Import-Module .\PSCallTrace\PSCallTrace.psd1  -Global | out-null

write-host "Loading"

$ScriptBlock = {
    write-host "Herro World"
    "TestBlock"
}

$POSH = [PowerShell]::Create()
$POSH.Runspace = ([runspacefactory]::CreateRunspace())
$POSH.Runspace.Open()
$POSH.AddScript($ScriptBlock) | out-null
$POSH.Streams.Error.add_DataAdded({write-host "Error", $args })
$POSH.Streams.Progress.add_DataAdded({write-host "Progress", $args })
$POSH.Streams.Verbose.add_DataAdded({write-host "Verbose", $args })
$POSH.Streams.Debug.add_DataAdded({write-host "Debug", $args })
$POSH.Streams.Warning.add_DataAdded({write-host "Warning", $args })
$POSH.Streams.Information.add_DataAdded({

    $result = [PSCustomObject]@{
        PSTypeName     = "PowerShell.PSCallTrace"
        #Timestamp      = $args[0].TimeGenerated
        Name           = $args[0].Source

        <#
        
        EndTime        = $null
        Measure        = $null
        Ticks          = $null
        
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
        #>
    }
    <#
    $DisplayProperties = @('TimeStamp', 'Ticks', 'FunctionName', 'Message', 'Line', 'Script', 'ModuleName', 'File')
    $DefaultDisplay = New-Object System.Management.Automation.PSPropertySet("DefaultDisplayPropertySet", [string[]]$DisplayProperties)
    $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($DefaultDisplay)
    $Result | Add-Member MemberSet PSStandardMembers $PSStandardMembers
    #>
    $result = Get-PSCallStack
    $Host.PSCallTrace.Add($result) | out-null
return
    write-host (
        #$result | out-string
        #$args[0] | gm | out-string
        
        $args[0].Tags | out-string

    )
    write-host ($args[0].ReadAll() -join " ")


})
#write-host "Invoke:"
$r = $POSH.Invoke()
$Host.PSCallTrace[0][0].Position.StartLineNumber | fl
$POSH.Dispose()

#$r