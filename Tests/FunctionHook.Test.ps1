Import-Module .\PSCallTrace\PSCallTrace.psd1  -Global | out-null

function Test-PSHook {
    Write-Host "I was called", $args
}
New-PSCallTraceHook -Name "Test-PSHook"
#New-PSCallTraceHook -Name "Test-PSHook"

Test-PSHook
Test-PSHook "asdf"
Get-PSCallTrace | ft -a