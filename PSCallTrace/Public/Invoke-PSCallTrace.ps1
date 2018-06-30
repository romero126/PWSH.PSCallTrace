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
        [switch]$End,
        [object]$Hook,
        [AllowNull()]
        [object[]]$Arguments
    )
    $Command = $null
    $Result = $null
    if ($Hook) {
        $Command = "`$Hook.Invoke(`$Arguments)"
        if ($Arguments -eq $null) {
            $Command = "`$Hook.Invoke()"
        }
    }
    
    if ($Command -ne $null) {
        
        try {
            $Result = Invoke-Expression -Command $Command `
                -InformationVariable +ReportInformation `
                -WarningVariable +ReportWarning `
                -ErrorVariable +ReportError `
                -Debug                
        } catch {
            #New-PSCallTraceMessage -MessageType Error -Message $_.Exception.InnerException.ErrorRecord
        }
        if ($ReportWarning) {
            write-host "Warning"
            New-PSCallTraceMessage -MessageType Warning -Message $ReportWarning
        }
        if ($ReportInformation) {
            New-PSCallTraceMessage -MessageType Information -Message $ReportInformation
        }
        if ($ReportError) {
            New-PSCallTraceMessage -MessageType Error -Message $ReportError.Exception.InnerException.ErrorRecord
        }
    }

    if ($Begin) {
        $Result = new-object PSCustomObject @{
            Message = New-PSCallTraceMessage -MessageType Begin -Message ""
            Result = $Result
        }

    }
    if ($Process) {
        #New-PSCallTraceMessage -MessageType Process -Message $CallStack -Level ($Level)
    }
    if ($End) {
        New-PSCallTraceMessage -MessageType End -Message $Object
    }
    $Result
}