<#PSScriptInfo
.VERSION        1.0
.AUTHOR         Chris Scott (chris.scott@aryon.com.au)
.COMPANYNAME    Aryon Pty Ltd
.RELEASENOTES
    1.0 - 2024-12-23 - Initial Script Creation
#>
<#
.SYNOPSIS
    Uninstalls the Automatic Timezone Update service.
.DESCRIPTION
    This script disables and stops the 'tzautoupdate' service, which is responsible for automatic timezone updates on 
    Windows.
.NOTES
    This script is intended to be used as a Win32 app in Microsoft Intune.
#>

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
        [ValidateSet("Verbose", "Information", "Warning", "Error")]
        [String]$LogLevel = "Information"
    )

    begin {
        # Using global variables to easily overwrite it in main script.
        if ([String]::IsNullOrEmpty($GLOBAL:ScriptLogPath)) {
            $GLOBAL:ScriptLogPath = "$ENV:PROGRAMDATA\Microsoft\IntuneManagementExtension\Logs"
        }
        if ([String]::IsNullOrEmpty($GLOBAL:ScriptLogName)) {
            $GLOBAL:ScriptLogName = "IntuneWin32Apps"
        }
        $Path = (Join-Path -Path $GLOBAL:ScriptLogPath -ChildPath $GLOBAL:ScriptLogName) + '.log'
    }
    process {
        switch ($LogLevel) {
            "Verbose" {
                $LogLevelInteger = 0
            }
            "Information" {
                $LogLevelInteger = 1
            }
            "Warning" {
                $LogLevelInteger = 2
            }
            "Error" {
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

<#--- MAIN SCRIPT ---#>

try {
    Write-Log "Disabling the 'tzautoupdate' service..."
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\tzautoupdate' -Name 'Start' -Value '4'
    Start-Service -Name 'tzautoupdate'
    Write-Log "Disabled the 'tzautoupdate' service."
} catch {
    Write-Log "Failed to dinable the 'tzautoupdate' service: $($_.Exception.Message)" -LogLevel Error
    exit 1
}
