# PWSH.PSCallTrace
Debug and Logging using PSCallTrace Module
Hey Guys,

I am very new to Reddit, so this is my first real post Contributing to the Community.

What this Module Does.

It allows a user to Hook into Native PowerShell Functions, and grab debug information. This information can be a number of things.

How what its Message is Example: Write-Host

Its Module Information

Where it was executed. Line/File/Module

What Information / Data was given to it as Arguments and what arguments was actually passed to it.

Time of Execution / the Number of Ticks it took to complete.

Why is this cool?

It allows you to quickly log information for debugging purposes. As well as a single location so you can dump log data to a file.

Where Can I get it?

Currently its on the PowerShellGallery so you can get it by running

Install-Module -Name PSCallTrace

or by Accessing it from the Gallery itself

https://www.powershellgallery.com/packages/PSCallTrace/1.0

Can you show me what it looks like?

Yup!

PSCallTrace Example Output

Help I'm stuck, what functions are there?

Get-PSCallTrace

Get-PSCallTrace Displays the output of all of the TraceData that has been accumulated.

New-PSCallTraceHook

New-PSCallTraceHook hooks an existing PowerShell function in this session in order to properly generate callback data.

Invoke-PSCallTrace

Invoke-PSCallTrace generates debug information, and loads it into the PSCallTrace object.

There's some examples in the Get-Help, as well as -Examples

Finally.

I look forward to hearing what you guys think about this! And hopefully potentially new features.