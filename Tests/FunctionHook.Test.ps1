Import-Module .\PSCallTrace\PSCallTrace.psd1  -Global | out-null

function Test-PSHook {
    Write-Host "I was called"
}
New-PSCallTraceHook -Name "Test-PSHook"
#New-PSCallTraceHook -Name "Test-PSHook"
Test-PSHook
Test-PSHook 
Get-PSCallTrace | ft -a