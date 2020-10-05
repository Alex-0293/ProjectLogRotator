# Rename this file to Settings.ps1
#### Script params    
    [array] $global:FoldersToApplyPath  = @()         # Folders where searching
  
######################### no replacement ########################   

    [string]$Global:LogFolder        = "LOGS"                                       # Logs folder name.
    [Int16] $Global:DaysToRotateLog  = 30                                           # Days count to save logs.
    [string]$Global:LogFilePath      = "$ProjectPath\LOGS\$($Global:gsScriptName).log"          # Path to this script log file.
    [array] $Global:ExcludeFiles     = @("Transcript.log")

    [bool] $Global:LocalSettingsSuccessfullyLoaded = $true

# Error trap
trap {
    $Global:LocalSettingsSuccessfullyLoaded = $False
    exit 1
}
