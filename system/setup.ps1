$setupCode = {
    function Show-Pipeline
    {
    <#
        .SYNOPSIS
            Demo function that shows how the pipeline processes objects.
        
        .DESCRIPTION
            Demo function that shows how the pipeline processes objects.
        
        .PARAMETER InputObject
            The object to pass through.
        
        .PARAMETER Name
            Name of the execution. Used when reporting the workflow to screen.
        
        .PARAMETER Stagger
            Stagger all input objects to be passed along when the next input is received.
        
        .PARAMETER Fail
            When to throw an exception.
        
        .PARAMETER Wait
            How many seconds to wait when processing an item.
            
        .PARAMETER ShowEnd
            Shows when the process block is ended.
        
        .EXAMPLE
            PS C:\> Show-Pipeline
    #>
        [CmdletBinding()]
        Param (
            [Parameter(ValueFromPipeline = $true)]
            $InputObject,
            
            [string]
            $Name,
            
            [switch]
            $Stagger,
            
            [ValidateSet('Begin','Process','End')]
            [string]
            $Fail,
            
            [int]
            $Wait,
            
            [switch]
            $ShowEnd,

            [ValidateScript( { $false } )]
            [bool]
            $BadInput
        )
        
        begin
        {
            #region Begin
            $color = @{
                first = 'DarkGreen'
                second = 'red'
                third = 'blue'
                default = 'black'
            }

            Write-PSFMessage -Level Host -Message "[<c='DarkGreen'>Begin</c>][<c='$($color[$name])'>$Name</c>] Killing puppies and processing $InputObject"
            if ($Fail -eq "Begin") { throw "[Begin][$Name] Failing as planned!" }
            $cache = $null
            #endregion Begin
        }
        
        process
        {
            foreach ($item in $InputObject)
            {
                #region Process
                $waiting = ""
                if ($Wait) { $waiting = " waiting for $wait seconds" }
                Write-PSFMessage -Level Host -Message "[<c='yellow'>Process</c>][<c='$($color[$name])'>$Name</c>] Killing puppies and processing $item$($waiting)"
                if ($Fail -eq "Process") { throw "[Process][$Name] Failing as planned!" }
                if ($Wait -gt 0) { Start-Sleep -Seconds $Wait }
                
                if ($Stagger)
                {
                    if ($cache) { $cache }
                    $cache = $item
                }
                else { $item }
                
                if ($ShowEnd) { Write-PSFMessage -Level Host -Message "[<c='yellow'>Process</c>][<c='$($color[$name])'>$Name</c>] Killing puppies and finihing processing $item$($waiting)" }
                #endregion Process
            }
        }
        
        end
        {
            #region End
            Write-PSFMessage -Level Host -Message "[<c='red'>End</c>][<c='$($color[$name])'>$Name</c>] Killing puppies and processing $InputObject"
            if ($Fail -eq "End") { throw "[End][$Name] Failing as planned!" }
            if ($Stagger) { $cache }
            #endregion End
        }
    }

    function Show-NoPipeline
    {
        <#
            .SYNOPSIS
                Demo function that does not support pipeline.

            .DESCRIPTION
                Demo function that does not support pipeline.
                It does not use begin/process/end, it just sends objects into output at some point.

            .PARAMETER Fail
                Using this parameter will terminate the function with an exception.
        #>
        [CmdletBinding()]
        param (
            [switch]
            $Fail
        )

        #region Plain Code
        if ($Fail) { throw "Failing as ordered to" }

        foreach ($item in ("a","b","c"))
        {
            Write-PSFMessage -Level Host -Message "[<c='darkblue'>NoPipe(?)</c>] Killing puppies and sending $item"
            $item
        }
        #endregion Plain Code
    }
    $rootPresentationPath = (Get-PSFConfigValue -FullName 'psdemo.path.presentationsroot')
    $tempPath = Get-PSFConfigValue -FullName psutil.path.temp -Fallback $env:TEMP

    $null = New-Item -Path $tempPath -Name demo -Force -ErrorAction Ignore -ItemType Directory
    $null = New-PSDrive -Name demo -PSProvider FileSystem -Root $tempPath\demo -ErrorAction Ignore
    Set-Location demo:
    Get-ChildItem -Path demo:\ -ErrorAction Ignore | Remove-Item -Force -Recurse

    $filesRoot = Join-Path $rootPresentationPath "P2019-PowerShellSaturdayHannover\PowerShell"
    
    function prompt {
        $string = ""
        try
        {
            $history = Get-History -ErrorAction Ignore
            if ($history)
            {
                $insert = ([PSUtil.Utility.PsuTimeSpanPretty]($history[-1].EndExecutionTime - $history[-1].StartExecutionTime)).ToString().Replace(" s", " s ")
                $padding = ""
                if ($insert.Length -lt 9) { $padding = " " * (9 - $insert.Length) }
                $string = "$padding[<c='red'>$insert</c>] "
            }
        }
        catch { }
        Write-PSFHostColor -String "$($string)Demo:" -NoNewLine
        
        "> "
    }
    Import-Module PSUtil
    Unregister-PSFConfig -Module DemoModule
    Set-PSFConfig -FullName 'DemoModule.Setting1' -Value 42 -SimpleExport -Description 'Just a demo setting with no intrinsic meaning'
    Set-PSFConfig -FullName psframework.text.encoding.defaultwrite -Value ([System.Text.Encoding]::UTF8) -DisableValidation
}
. $setupCode
Set-Content -Value $setupCode -Path $profile.CurrentUserCurrentHost