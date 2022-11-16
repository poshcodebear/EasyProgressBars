. $PSScriptRoot\Class.ProgressBar.ps1
. $PSScriptRoot\ProgressBar.ps1

$exportSplat = @{
    #Alias = @()
    Function = @(
        'New-ProgressBar'
        'Get-ProgressBar'
        'Write-ProgressBar'
        'Remove-ProgressBar'
    )
    #Variable = @()
}

Export-ModuleMember @exportSplat
