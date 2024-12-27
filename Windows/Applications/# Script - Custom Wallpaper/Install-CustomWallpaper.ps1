<#PSScriptInfo
.VERSION        0.1
.AUTHOR         Chris Scott (chris.scott@aryon.com.au)
.COMPANYNAME    Aryon Pty Ltd
.RELEASENOTES
    0.1 - 2024-12-27 - Initial Script Creation
#>
<#
.SYNOPSIS
    A brief synopsis of the script
.DESCRIPTION
    A longer description of the function, its purpose, common use cases, etc.
.NOTES
    CREDIT: https://github.com/okieselbach/Intune/blob/master/Set-Wallpaper.ps1
#>

#region Assemblies
# Assembly required to refresh wallpaper
Add-Type @'
    using System.Runtime.InteropServices;

    public class Wallpaper {
        [DllImport("user32.dll", SetLastError=true, CharSet=CharSet.Auto)]
        private static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);

        public static void Refresh(string path) {
            SystemParametersInfo(20, 0, path, 0x01|0x02); 
        }
    }
'@
#endregion

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

function Get-GreatestCommonDivisor([int]$A, [int]$B) {
    # Using Euclidean algorithm for better performance
    while ($B -ne 0) {
        $Temp = $B
        $B = $A % $B
        $A = $Temp
    }
    return [Math]::Abs($A)
}

function Get-Ratio([int]$Width, [int]$Height) {
    if ($Width -le 0 -or $Height -le 0) {
        Write-Log "Invalid dimensions provided: width=$Width, height=$Height" -LogLevel Error
        throw 'Both width and height must be positive integers'
    }

    try {
        $GCD = Get-GreatestCommonDivisor $Width $Height
        $XRatio = $Width / $GCD
        $YRatio = $Height / $GCD

        return [PSCustomObject]@{
            Width   = $Width
            Height  = $Height
            Divisor = $GCD
            XRatio  = $XRatio
            YRatio  = $YRatio
            Ratio   = '{0}:{1}' -f $XRatio, $YRatio
        }
    }
    catch {
        Write-Log "Error calculating ratio: $_" -LogLevel Error
        throw
    }
}

function Get-Wallpaper {
    try {
        Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop

        # Get primary monitor resolution
        $PrimaryScreen = [System.Windows.Forms.Screen]::PrimaryScreen
        if (-not $PrimaryScreen) {
            throw 'Unable to detect primary screen'
        }

        $X = $PrimaryScreen.Bounds.Width
        $Y = $PrimaryScreen.Bounds.Height

        Write-Log "Detected primary monitor resolution: ${X}x${Y}"

        # Get aspect ratio
        $Ratio = Get-Ratio $X $Y
        Write-Log "Found aspect ratio: $($Ratio.Ratio) ($($X)x$($Y))"

        # Define common ratios and their fallbacks
        $RatioMap = @{
            '16:9'    = @('16x9')                         # 1920x1080, 3840x2160
            '16:10'   = @('16x10', '16x9')                # 1920x1200, 2560x1600
            '8:5'     = @('16x10', '16x9')                # Same as 16:10
            '3:2'     = @('3x2')                          # 3000x2000, 3240x2160
            '32:9'    = @('32x9', '16x9')                 # 5120x1440
            '21:9'    = @('21x9', '16x9')                 # 2560x1080, 3440x1440
            '64:27'   = @('21x9', '16x9')                 # Ultra-wide variant
            '43:18'   = @('21x9', '16x9')                 # Ultra-wide variant
            '12:5'    = @('21x9', '16x9')                 # Ultra-wide variant
            '4:3'     = @('4x3', '3x2')                   # 1440x1080, 1600x1200
            '5:4'     = @('5x4', '3x2')                   # 1280×1024, 2560x2048
            '5:3'     = @('5x3', '3x2')                   # 1280×768, 800x480
            '1:1'     = @('1x1', '3x2')                   # 2048x2048
            '4:1'     = @('4x1', '16x9')                  # Advertisement displays
            '256:135' = @('17x9', '16x9')                 # Cinematic 4K
            '17:9'    = @('17x9', '16x9')                 # Cinematic 4K
        }

        # Get wallpaper formats to try, defaults to 16:9
        $FormatsToTry = $RatioMap[$Ratio.Ratio]
        if ($null -eq $FormatsToTry) {
            Write-Log "No suitable wallpaper format found for aspect ratio $($Ratio.Ratio), defaulting to 16x9" `
                -LogLevel Warning
            $FormatsToTry = $RatioMap['16:9']
        }

        # Try each format until one succeeds
        foreach ($Format in $FormatsToTry) {
            $Path = "$PSScriptRoot\Wallpapers\$Format.jpg"

            if (Test-Path $Path) {
                Write-Log "Found wallpaper for $Format format: $Path"
                return $Path
            }
        }

        throw 'No suitable wallpaper found'
    }
    catch {
        Write-Log "Error getting wallpaper: $_" -LogLevel Error
        throw
    }
}

function Set-Wallpaper {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path
    )
    
    try {
        Write-Log "Copying wallpaper to $ENV:LOCALAPPDATA"
        Copy-Item -Path $Path -Destination "$ENV:LOCALAPPDATA\Wallpaper.jpg" -Force
        $Path = "$ENV:LOCALAPPDATA\Wallpaper.jpg"

        Write-Log "Setting wallpaper to $Path and triggering refresh"
        [Wallpaper]::Refresh($Path)
    }
    catch {
        Write-Log "Error setting wallpaper: $_" -LogLevel Error
        throw
    }
}
#endregion

#region Main Logic

Write-Log 'Starting custom wallpaper installation'

if (Test-Path "$ENV:LOCALAPPDATA\Wallpaper.jpg") {
    Write-Log 'Existing wallpaper found, checking if update is required'
    $RegKey = Get-ItemProperty 'HKCU:\Control Panel\Desktop' -Name WallPaper -ErrorAction SilentlyContinue

    if ($null -eq $RegKey) {
        Write-Log 'WallPaper key in registry is missing, exiting...' -LogLevel Warning
    }
    else {
        $CurrentWallpaper = $RegKey.WallPaper
        Write-Log "Current wallpaper set in registry: $CurrentWallpaper"

        if ($CurrentWallpaper -eq "$ENV:LOCALAPPDATA\Wallpaper.jpg") {
            $PackagedWallpaper = Get-Wallpaper

            # Compare file hashes to see if an update is required
            if ($null -ne $PackagedWallpaper) {
                $CurrentHash = Get-FileHash -Path $CurrentWallpaper -Algorithm SHA256
                $PackagedHash = Get-FileHash -Path $PackagedWallpaper -Algorithm SHA256

                if ($CurrentHash.Hash -eq $PackagedHash.Hash) {
                    Write-Log 'Wallpaper is up to date, no action required'
                }
                else {
                    Write-Log 'Wallpaper update required, setting new wallpaper'
                    Set-Wallpaper -Path $PackagedWallpaper
                }
            }
        }
        else {
            Write-Log 'Wallpaper is not set to custom wallpaper, skipping...'
        }
    }
}
else {
    Write-Log 'No existing wallpaper found, setting new wallpaper'
    Set-Wallpaper -Path (Get-Wallpaper)
}

Write-Log 'Completed custom wallpaper installation'

#endregion