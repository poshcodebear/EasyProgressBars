class ProgressBar
{
    #region Instance Properties
    [int]         $Id
    [ProgressBar] $Parent
    [string]      $Activity
    [DateTime]    $StartTime
    [int]         $TotalCount
    [int]         $Iteration
    
    hidden [Guid] $Guid
    #endregion
    
    #region Static Properties
    static [Collections.Generic.List[ProgressBar]] $ProgressBarStack = @()
    #endregion
    
    #region Script Properties
    [ProgressBar[]] hidden $_Children = $($this |
        Add-Member -MemberType ScriptProperty -Name 'Children' -Value (
        {
            # get
            [ProgressBar]::ProgressBarStack.where({$_.Parent -eq $this})
        })
    )
    [string] hidden $_Status = $($this |
        Add-Member -MemberType ScriptProperty -Name 'Status' -Value (
        {
            # get
            "($($this.Iteration)/$($this.TotalCount)) " +
            "Elapsed time: ($($this.ElapsedTime)) " +
            "Remaining time: ($($this.RemainingTime))"
        })
    )
    [string] hidden $_ElapsedTime = $($this |
        Add-Member -MemberType ScriptProperty -Name 'ElapsedTime' -Value (
        {
            # get
            $elapsed = (Get-Date) - $this.StartTime
            $elapsed.ToString().split('.')[0]
        })
    )
    [string] hidden $_RemainingTime = $($this |
        Add-Member -MemberType ScriptProperty -Name 'RemainingTime' -Value (
        {
            # get
            $elapsed = (Get-Date) - $this.StartTime
            $eSecs = $elapsed.TotalSeconds
            $secondsRemaining = (($eSecs / ($this.Iteration + 1)) * $this.TotalCount) - $eSecs
            ([TimeSpan]([long]$secondsRemaining * 10000000)).ToString()
        })
    )
    [int] hidden $_PercentComplete = $($this |
        Add-Member -MemberType ScriptProperty -Name 'PercentComplete' -Value (
        {
            # get
            [int](($this.Iteration/$this.TotalCount * 100) ? ($this.Iteration/$this.TotalCount * 100) : 1)
        })
    )
    [Nullable[Management.Automation.ProgressView]] hidden $_View = $($this |
        Add-Member -MemberType ScriptProperty -Name 'View' -Value (
        {
            # get
            ($null -ne $this.Parent) ? $this.Parent.View : $this._View
        }) -SecondValue (
        {
            param($value)
            # set
            $this._View = $value
        })
    )
    #endregion
    
    #region Constructors
    hidden Init([string] $Activity, [int] $TotalCount)
        { $this.Init($Activity, $TotalCount, $null, $Global:PSStyle.Progress.View) }
        
    hidden Init([string] $Activity, [int] $TotalCount, [ProgressBar] $Parent)
        { $this.Init($Activity, $TotalCount, $Parent, $null) }
        
    hidden Init([string] $Activity, [int] $TotalCount, [Management.Automation.ProgressView] $View)
        { $this.Init($Activity, $TotalCount, $null, $View) }
        
    hidden Init(
        [string] $Activity,
        [int] $TotalCount,
        [ProgressBar] $Parent,
        [Nullable[Management.Automation.ProgressView]] $View)
    {
        $this.Activity   = $Activity
        $this.TotalCount = $TotalCount
        $this.Parent     = $Parent
        $this.StartTime  = Get-Date
        $this.Id         = [ProgressBar]::GetNextStackId()
        $this.Iteration  = 0
        $this.View       = $View
        $this.Guid       = New-Guid
        
        [ProgressBar]::ProgressBarStack += $this
    }
    
    ProgressBar([string] $Activity, [int] $TotalCount)
        { $this.Init($Activity, $TotalCount) }
        
    ProgressBar([string] $Activity, [int] $TotalCount, [ProgressBar] $Parent)
        { $this.Init($Activity, $TotalCount, $Parent) }
        
    ProgressBar([string] $Activity, [int] $TotalCount, [Management.Automation.ProgressView] $View)
        { $this.Init($Activity, $TotalCount, $View) }
        
    ProgressBar([string] $Activity, [int] $TotalCount, [ProgressBar] $Parent, [Management.Automation.ProgressView] $View)
        { $this.Init($Activity, $TotalCount, $Parent, $View) }
    #endregion
    
    #region Instance Methods
    [void] WriteProgress([string] $CurrentOperation)
        { $this.WriteProgress($CurrentOperation, $true) }
    [void] WriteProgress([string] $CurrentOperation, [bool] $IncrementCounter)
        { $this.WriteProgress($CurrentOperation, $true, 1) }
    [void] WriteProgress([string] $CurrentOperation, [bool] $IncrementCounter, [int] $IncrementAmount)
    {
        $CurrentView = $Global:PSStyle.Progress.View
        $Global:PSStyle.Progress.View = $this.View
        
        $progSplat = @{
            Id               = $this.Id
            Activity         = $this.Activity
            Status           = $this.Status
            PercentComplete  = $this.PercentComplete
            CurrentOperation = $CurrentOperation
        }
        
        if ($this.Parent)
        {
            $progSplat.ParentId = $this.Parent.Id
        }
        if ($Global:PSStyle.Progress.View -eq 'Minimal')
        {
            $progSplat.Activity = "$($this.Activity): $($CurrentOperation)"
        }
        
        Write-Progress @progSplat
        
        if ($IncrementCounter -and $this.Iteration -lt $this.TotalCount)
        {
            $this.Iteration += $IncrementAmount
        }
        
        $Global:PSStyle.Progress.View = $CurrentView
    }
    [string] ToString()
    {
        return "($($this.Id)) $($this.Activity) [$($this.Iteration)/$($this.TotalCount)]"
    }
    [void] Dispose()
        { $this.Dispose(3) }
    [void] hidden Dispose([int] $Depth)
    {
        $this.Children.foreach({$_.Dispose($Depth + 1)})
        
        [ProgressBar]::ProgressBarStack.Remove($this)
        
        (Get-Variable).where({
            $_.Value          -is [ProgressBar] -and
            $_.GetType().Name -eq 'PSVariable'  -and
            $_.Value.Guid     -eq $this.Guid
        }) | Remove-Variable -Scope $Depth
    }
    #endregion
    
    #region Static Methods
    static [int] hidden GetNextStackId()
    {
        $returnValue = 1
        
        if ([ProgressBar]::ProgressBarStack.Count -gt 0)
        {
            $foundUnusedId = $false
            do
            {
                if ($returnValue -in [ProgressBar]::ProgressBarStack.Id)
                {
                    $returnValue++
                    continue
                }
                $foundUnusedId = $true
            }
            until ($foundUnusedId)
        }
        
        return $returnValue
    }
    #endregion
}
