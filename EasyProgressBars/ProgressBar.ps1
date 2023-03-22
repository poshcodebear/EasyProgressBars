function New-ProgressBar
{
    [CmdletBinding(DefaultParameterSetName='Default')]
    param
    (
        [Parameter(Mandatory)]
        [string] $Activity,
        
        [Parameter(Mandatory)]
        [int] $TotalCount,
        
        [Parameter(Mandatory, ParameterSetName='Parent')]
        [ProgressBar] $Parent,
        
        [Parameter(Mandatory, ParameterSetName='View')]
        [Management.Automation.ProgressView] $View
    )
    process
    {
        switch ($PSCmdlet.ParameterSetName)
        {
            'Parent'  { return [ProgressBar]::new($Activity, $TotalCount, $Parent) }
            'View'    { return [ProgressBar]::new($Activity, $TotalCount, $View) }
            'Default' { return [ProgressBar]::new($Activity, $TotalCount) }
        }
    }
}

function Get-ProgressBar
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [int] $Id
    )
    
    process
    {
        if ($Id)
        {
            [ProgressBar]::ProgressBarStack.where({$_.Id -eq $Id})
        }
        else
        {
            [ProgressBar]::ProgressBarStack
        }
    }
}

function Write-ProgressBar
{
    [CmdletBinding(DefaultParameterSetName='Default')]
    param
    (
        [Parameter(Mandatory)]
        [ProgressBar] $ProgressBar,
        
        [Parameter(Mandatory)]
        [string] $CurrentOperation,
        
        [Parameter(Mandatory, ParameterSetName='IncrementAmount')]
        [int] $IncrementAmount,
        
        [Parameter(Mandatory, ParameterSetName='NoIncrement')]
        [switch] $NoIncrement
    )
    process
    {
        switch ($PSCmdlet.ParameterSetName)
        {
            'IncrementAmount' { $ProgressBar.WriteProgress($CurrentOperation, $true, $IncrementAmount) }
            'NoIncrement '    { $ProgressBar.WriteProgress($CurrentOperation, $false) }
            'Default'         { $ProgressBar.WriteProgress($CurrentOperation, $true) }
        }
    }
}

function Remove-ProgressBar
{
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Low')]
    param
    (
        [Parameter(Mandatory)]
        [ProgressBar[]] $ProgressBar
    )
    process
    {
        foreach ($bar in $ProgressBar)
        {
            if ($PSCmdlet.ShouldProcess($bar, 'Remove ProgressBar'))
            {
                $bar.Dispose(3)
            }
        }
    }
}
