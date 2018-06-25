
#Now with more Molecules.
$Host | Add-Member -MemberType NoteProperty -Name PSCallTrace -Value (New-Object System.Collections.Generic.List[PSCustomObject]) -Force
$Public  = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )

foreach ($ScriptFile in @($Public + $Private) ) {
    try {
        . $ScriptFile.FullName #Dot Sourcing because ta11ow dislikes.
    }
    catch {
        Write-Warning "Unable to Load $($ScriptFile.FullName)"
        Write-Error $_
        break;
    }
}

Export-ModuleMember -Function $Public.BaseName