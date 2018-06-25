
Import-Module .\PSCallTrace\PSCallTrace.psd1  -Global | out-null

New-PSCallTraceHook -FunctionName Write-Debug -Module Microsoft.PowerShell.Utility
New-PSCallTraceHook -FunctionName Write-Error -Module Microsoft.PowerShell.Utility
New-PSCallTraceHook -FunctionName Write-Host -Module Microsoft.PowerShell.Utility
New-PSCallTraceHook -FunctionName Write-Information -Module Microsoft.PowerShell.Utility
New-PSCallTraceHook -FunctionName Write-Output -Module Microsoft.PowerShell.Utility
New-PSCallTraceHook -FunctionName Write-Progress -Module Microsoft.PowerShell.Utility
New-PSCallTraceHook -FunctionName Write-Verbose -Module Microsoft.PowerShell.Utility
New-PSCallTraceHook -FunctionName Write-Warning -Module Microsoft.PowerShell.Utility

Write-Debug "Debug Message"
try {
    Write-Error "Error Message" #This breaks my script so Try Catch is better.
} catch {}
Write-Host "Test 1"
Write-Host "Test 2", "abc", "def"
Write-Information "Information Message"
Write-Output "Output Message"
#Write-Progress 
Write-Verbose "Verbose Message"
Write-Warning "Warning Message"

Get-PSCallTrace | select -first 1 | fl










#Get-PSCallTrace -Filter { $_.FunctionName -eq "Write-Host" } | ft

#(1..500) | % { Write-Host "Speed Test" }
#$v | Measure-Object -Property Ticks -Average

