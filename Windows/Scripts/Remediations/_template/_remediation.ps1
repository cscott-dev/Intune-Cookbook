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
    RUN AS: (System/User)
    CONTEXT: (64/32)-bit

    Follow the PowerShell Best Practices and Style Guide:
        https://github.com/PoshCode/PowerShellPracticeAndStyle/tree/master
#>

#region Functions
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
        $GLOBAL:ScriptLogPath = $GLOBAL:ScriptLogPath ?? "$ENV:PROGRAMDATA\Microsoft\IntuneManagementExtension\Logs"
        $GLOBAL:ScriptLogName = $GLOBAL:ScriptLogName ?? 'IntuneRemediations'
        
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
#endregion

#region Main Logic

#* NOTE: Add main remediation script code here.

#endgregion