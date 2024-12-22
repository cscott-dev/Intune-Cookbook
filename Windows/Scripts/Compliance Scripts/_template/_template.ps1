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
    RUN AS: (System/User)
    CONTEXT: (64/32)-bit

    Follow the PowerShell Best Practices and Style Guide:
        https://github.com/PoshCode/PowerShellPracticeAndStyle/tree/master
#>

<#--- VARIABLES ---#>

#* NOTE: Add script variables here.

<#--- FUNCTIONS ---#>

function Write-Log {
    <#
    .SYNOPSIS
        Writes a CMTrace log to the %PROGRAMDATA%\Microsoft\IntuneManagementExtension\Logs\IntuneComplianceScripts.log
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
            $GLOBAL:ScriptLogName = "IntuneComplianceScripts"
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

#* NOTE: Add main script code here.
