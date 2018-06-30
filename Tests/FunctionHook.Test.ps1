Import-Module .\PSCallTrace\PSCallTrace.psd1  -Global | out-null


function Test-PSHook {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        $vee
    )
    begin {
        write-host "begin Test-PSHook"
    }
    process {
        Write-Host "process Test-PSHook"
        Write-Information "Write-Information Test"
        Write-Warning "Write-Warning Test"
        Write-Verbose "Write-Verbose Test"
        new-object PSCustomObject @{ This = "CustomObject" }
        #[System.Management.Automation.WarningRecord]::new("WarningMessage") # This gets fed to the Pipeline.
        Write-Error "Write-Error Test" -ErrorAction Continue
        throw "Throw Test"
    }
    end {
        return "end Test-PSHook"
    }
}

New-PSCallTraceHook -Name "Test-PSHook"
try {
    #Test Double Hooks
    New-PSCallTraceHook -Name "Test-PSHook"
}
catch {

}

#Test-PSHook
Test-PSHook

Get-PSCallTrace | ft -a

#write-host ($v -eq $null)
