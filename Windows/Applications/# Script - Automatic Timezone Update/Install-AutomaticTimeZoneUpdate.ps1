<#PSScriptInfo
.VERSION        1.0
.AUTHOR         Chris Scott (chris.scott@aryon.com.au)
.COMPANYNAME    Aryon Pty Ltd
.RELEASENOTES
    1.0 - 2024-12-23 - Initial Script Creation
#>
<#
.SYNOPSIS
    Enables and starts the Windows Automatic Time Zone Update service
.DESCRIPTION
    This script enables and starts the Windows Time Zone Auto Update service (tzautoupdate). The service allows Windows
    to automatically update the system's time zone based on the device's current location.
.NOTES
    This script is intended to be used as a Win32 app in Microsoft Intune.
    Location Services must be enabled on the device for the service to work correctly.
#>

<#--- FUNCTIONS ---#>

function Write-Log {
    <#
    .SYNOPSIS
        Writes a CMTrace-compatible log entry to the 
        %PROGRAMDATA%\Microsoft\IntuneManagementExtension\Logs\IntuneWin32Apps.log file.
    .PARAMETER Message
        The message to write to the log.
    .PARAMETER Component
        The component name. Defaults to script name and line number.
    .PARAMETER LogLevel
        The log level (Verbose, Information, Warning, Error). Defaults to "Information".
    .EXAMPLE
        Write-Log "Installing Package"
        Write-Log "Installation Failed" -LogLevel Error
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [AllowEmptyString()]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        [string]$Component = "$($MyInvocation.ScriptName | Split-Path -Leaf):$($MyInvocation.ScriptLineNumber)",

        [Parameter(Mandatory = $false)]
        [ValidateSet('Verbose', 'Information', 'Warning', 'Error')]
        [string]$LogLevel = 'Information'
    )

    begin {
        # Define log levels mapping
        $LogLevels = @{
            'Verbose'     = 0
            'Information' = 1
            'Warning'     = 2
            'Error'       = 3
        }

        # Set default log path and name if not defined
        if (-not $GLOBAL:ScriptLogPath) {
            $GLOBAL:ScriptLogPath = "$ENV:PROGRAMDATA\Microsoft\IntuneManagementExtension\Logs"
        }
        if (-not $GLOBAL:ScriptLogName) {
            $GLOBAL:ScriptLogName = 'IntuneWin32Apps'
        }
        
        # Ensure log directory exists
        if (-not (Test-Path -Path $GLOBAL:ScriptLogPath)) {
            try {
                New-Item -Path $GLOBAL:ScriptLogPath -ItemType Directory -Force | Out-Null
            }
            catch {
                Write-Warning "Failed to create log directory: $_"
                return
            }
        }

        $SCRIPT:LogPath = Join-Path -Path $GLOBAL:ScriptLogPath -ChildPath "$($GLOBAL:ScriptLogName).log"
    }

    process {
        try {
            $TimeGenerated = Get-Date
            $Line = '<![LOG[{0}]LOG]!><time="{1}" date="{2}" component="{3}" context="" type="{4}" thread="" file="">' `
                -f @(
                $Message,
                $TimeGenerated.ToString('HH:mm:ss.fff+000'),
                $TimeGenerated.ToString('MM-dd-yyyy'),
                $Component,
                $LogLevels[$LogLevel]
            )

            Add-Content -Path $SCRIPT:LogPath -Value $Line -Force -ErrorAction Stop
        }
        catch {
            Write-Warning "Failed to write to log file: $_"
        }
    }
}

<#--- MAIN SCRIPT ---#>

try {
    Write-Log "Enabling the 'tzautoupdate' service..."
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\tzautoupdate' -Name 'Start' -Value '3'
    Start-Service -Name 'tzautoupdate'
    Write-Log "Enabled and started the 'tzautoupdate' service."
}
catch {
    Write-Log "Failed to enable the 'tzautoupdate' service: $($_.Exception.Message)" -LogLevel Error
    exit 1
}