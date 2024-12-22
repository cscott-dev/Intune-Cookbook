<#PSScriptInfo
.VERSION        0.1
.AUTHOR         Chris Scott (chris.scott@aryon.com.au)
.COMPANYNAME    Aryon Pty Ltd
.RELEASENOTES
    0.1 - XX/XX/XXXX - Initial Script Creation
#>
<#
.SYNOPSIS
    A brief synopsis of the script
.DESCRIPTION
    A longer description of the function, its purpose, common use cases, etc.
.NOTES
    Follow the PowerShell Best Practices and Style Guide: https://github.com/PoshCode/PowerShellPracticeAndStyle/tree/master
#>

<# --- VARIABLES --- #>

# Required for logging.
$ScriptName = "Script_"

<# --- FUNCTIONS --- #>

<#
.SYNOPSIS
    Writes a CMTrace log to the C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\$ScriptName.log file.
.EXAMPLE
    Write-Log "Installing Package"
        Writes a line with the "Information" log level.
    Write-Log "Error: Failed to install: $($_.Exception.Message)" -LogLevel Error
        Writes a line with the "Error" log level.
#>
function Write-Log {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [AllowEmptyString()]
        [String]$Message,

        # using CCMLog component as it is always visible and additionally append line number for easy troubleshooting
        [Parameter(Mandatory = $False)]
        [String]$Component = "$($MyInvocation.ScriptName | Split-Path -Leaf):$($MyInvocation.ScriptLineNumber)",

        [Parameter(Mandatory = $False)]
        [ValidateSet("Information", "Warning", "Error")]
        [String]$LogLevel = "Information"
    )

    begin {
        if ([String]::IsNullOrEmpty($GLOBAL:ScriptLogPath)) {
            # using a global variable to easily overwrite it in main script
            $GLOBAL:ScriptLogPath = "$ENV:PROGRAMDATA\Microsoft\IntuneManagementExtension\Logs"
        }
        if ($ScriptName -eq 'Script_') {
            Write-Error "`$ScriptName is not set. Exiting..."
            exit 1
        }

        $Path = (Join-Path -Path $GLOBAL:ScriptLogPath -ChildPath $ScriptName) + '.log'
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

<# --- MAIN SCRIPT START --- #>

# NOTE: Add main script here
Write-Log 