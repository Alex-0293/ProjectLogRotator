# Rename this file to Settings.ps1
######################### value replacement ##################### 
  
######################### no replacement ######################## 
    [array]  $global:IgnoreFolders      = @($Global:TemplateProjectPath)           # Ignored folders names.  
    [array]  $global:FoldersToApplyPath = $Global:WorkFolderList                   # Folders where searching
    [string] $Global:LogFolder          = $Global:LOGSFolder                       # Logs folder name.
    [Int16]  $Global:DaysToRotateLog    = 30                                       # Days count to save logs.
    [array]  $Global:ExcludeFiles       = @("Transcript.log")

    [bool] $Global:LocalSettingsSuccessfullyLoaded = $true

# Error trap
trap {
    $Global:LocalSettingsSuccessfullyLoaded = $False
    exit 1
}
