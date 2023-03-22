$ModuleName = ($PSScriptRoot).Split('\')[-1]

$ManifestSplat = @{
    # Module details:
    Author                   = 'Laurel Lowery, a.k.a. The PowerShell Bear'
    Description              = 'Helper functions to make setting up progress bars to track progress simple and straightforward'
    ModuleVersion            = '1.0.1'
    PowerShellVersion        = '7.2'
    
    # Exports:
    FileList                 = @(
        "$($ModuleName).psm1" # Do not remove
        'Class.ProgressBar.ps1'
        'ProgressBar.ps1'
    )
    AliasesToExport          = @()
    FunctionsToExport        = @(
        'New-ProgressBar'
        'Get-ProgressBar'
        'Write-ProgressBar'
        'Remove-ProgressBar'
    )
    VariablesToExport        = @()
    
    # Leave as-is (unless specifically needed):
    # Pathing:
    NestedModules            = "$($ModuleName).psm1"
    Path                     = "$($PSScriptRoot)\$($ModuleName)\$($ModuleName).psd1"
    
    Guid                     = 'f966ba35-3459-4957-a23c-a278ef711d9f'
    
    CompanyName              = 'poshcodebear.com'
    Copyright                = '(c) 2022 The PowerShell Bear'
    LicenseUri               = 'https://raw.githubusercontent.com/poshcodebear/EasyProgressBars/main/LICENSE'
    PassThru                 = $true
    CmdletsToExport          = @()
    Verbose                  = $true
    Confirm                  = $false
}

New-ModuleManifest @ManifestSplat
