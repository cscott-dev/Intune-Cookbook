<#PSScriptInfo
.VERSION        0.1
.AUTHOR         Chris Scott (chris.scott@aryon.com.au)
.COMPANYNAME    Aryon Pty Ltd
.RELEASENOTES
    0.1 - YYYY-MM-DD - Initial Script Creation
#>
<#
.SYNOPSIS
    A brief synopsis of the script
.DESCRIPTION
    A longer description of the function, its purpose, common use cases, etc.
.NOTES
    Follow the PowerShell Best Practices and Style Guide:
        https://github.com/PoshCode/PowerShellPracticeAndStyle/tree/master
#>

<#--- VARIABLES ---#>

$ScriptTarget = "$ENV:ProgramData\Microsoft\IntuneManagementExtension\Scripts"
$ScriptName = 'Set-CustomWallpaper.ps1'
$ImageName = 'CustomWallpaper.png'

<#--- FUNCTIONS ---#>

function Write-Log {
    <#
    .SYNOPSIS
        Writes a CMTrace log to the %PROGRAMDATA%\Microsoft\IntuneManagementExtension\Logs\IntuneWin32Apps.log
        file.
    .PARAMETER Message
        The message to write to the log.
    .PARAMETER Component
        The component to write to the log. Defaults to the script name and line number.
    .PARAMETER LogLevel
        The log level to write the message as. Defaults to "Information".
        Valid values are "Verbose", "Information", "Warning", "Error".
    .EXAMPLE
        Write-Log "Installing Package"
            Writes a line with the "Information" log level.
        Write-Log "Error: Failed to install: $($_.Exception.Message)" -LogLevel Error
            Writes a line with the "Error" log level.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [AllowEmptyString()]
        [String]$Message,

        [Parameter(Mandatory = $False)]
        [String]$Component = "$($MyInvocation.ScriptName | Split-Path -Leaf):$($MyInvocation.ScriptLineNumber)",

        [Parameter(Mandatory = $False)]
        [ValidateSet('Verbose', 'Information', 'Warning', 'Error')]
        [String]$LogLevel = 'Information'
    )

    begin {
        # Using global variables to easily overwrite it in main script.
        if ([String]::IsNullOrEmpty($GLOBAL:ScriptLogPath)) {
            $GLOBAL:ScriptLogPath = "$ENV:PROGRAMDATA\Microsoft\IntuneManagementExtension\Logs"
        }
        if ([String]::IsNullOrEmpty($GLOBAL:ScriptLogName)) {
            $GLOBAL:ScriptLogName = 'IntuneWin32Apps'
        }
        $Path = (Join-Path -Path $GLOBAL:ScriptLogPath -ChildPath $GLOBAL:ScriptLogName) + '.log'
    }
    process {
        switch ($LogLevel) {
            'Verbose' {
                $LogLevelInteger = 0
            }
            'Information' {
                $LogLevelInteger = 1
            }
            'Warning' {
                $LogLevelInteger = 2
            }
            'Error' {
                $LogLevelInteger = 3
            }
        }
        
        $Time = "$(Get-Date -Format HH:mm:ss).$((Get-Date).Millisecond)+000"
        $Line = '<![LOG[{0}]LOG]!><time="{1}" date="{2}" component="{3}" context="" type="{4}" thread="" file="">'
        $Format = $Message, $Time, (Get-Date -Format MM-dd-yyyy), $Component, $LogLevelInteger
        $Line = $Line -f $Format

        Add-Content -Value $Line -Path $Path -Force
    }
}

#region Main Script Block

try {
    # Create the script directory if it doesn't exist
    if (!(Test-Path $ScriptTarget)) {
        Write-Log "Creating directory: $ScriptTarget"
        New-Item -Path $ScriptTarget -ItemType Directory -Force | Out-Null
    }
}
catch {
    Write-Log "Failed to create directory at $ScriptTarget`: $($_.Exception.Message)" -LogLevel Error
    exit 1
}

try {
    # Copy the background image to the Public Pictures directory
    Write-Log "Copying Background Image to $ENV:SystemDrive\Users\Public\Pictures"
    $Image = Join-Path -Path $PSScriptRoot -ChildPath $ImageName
    Copy-Item $Image -Destination "$ENV:SystemDrive\Users\Public\Pictures" -Force
}
catch {
    Write-Log "Failed to copy Background Image to $ENV:SystemDrive\Users\Public\Pictures: $($_.Exception.Message)" -LogLevel Error
    exit 2
}

try {
    # Copy the script to the script directory
    Write-Log "Copying $Script to $ScriptTarget"
    $Script = Join-Path -Path $PSScriptRoot -ChildPath $ScriptName
    Copy-Item $Script -Destination $ScriptTarget -Force
}
catch {
    Write-Log "Failed to copy $Script to $ScriptTarget`: $($_.Exception.Message)" -LogLevel Error
    exit 3
}

try {
    Write-Log "Adding $Script to Run Once"
    # Load the Default User Profile
    reg load 'HKU\DEFAULT_USER' 'C:\Users\Default\NTUSER.DAT'
    # Set Default Background using a "Run Once" that calls the Set-CustomBackground script.
    reg add 'HKU\DEFAULT_USER\Software\Microsoft\Windows\CurrentVersion\RunOnce' /v 'SetBackground' /t REG_SZ /d "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File $Target\$Script" /f
    # Unload the Default User Profile
    reg unload 'KHU\DEFAULT_USER'
}
catch {
    Write-Log "Failed to add $Script to Run Once: $($_.Exception.Message)" -LogLevel Error
    exit 4
}
#endregion