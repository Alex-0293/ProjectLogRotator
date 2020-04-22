<#
    .SYNOPSIS 
        Alexk
        xx.xx.xxxx
        1
    .DESCRIPTION
    .PARAMETER
    .EXAMPLE
#>
$ImportResult = Import-Module AlexkUtils  -PassThru -Force
if ($null -eq $ImportResult) {
    Write-Host "Module 'AlexkUtils' does not loaded!"
    exit 1
}
else {
    $ImportResult = $null
}
#requires -version 3

#########################################################################
function Get-WorkDir () {
    if ($PSScriptRoot -eq "") {
        if ($PWD -ne "") {
            $MyScriptRoot = $PWD
        }        
        else {
            Write-Host "Where i am? What is my work dir?"
        }
    }
    else {
        $MyScriptRoot = $PSScriptRoot
    }
    return $MyScriptRoot
}
Function Initialize-Script   () {
    [string]$Global:MyScriptRoot = Get-WorkDir
    [string]$Global:GlobalSettingsPath = "C:\DATA\Projects\GlobalSettings\SETTINGS\Settings.ps1"

    Get-SettingsFromFile -SettingsFile $Global:GlobalSettingsPath
    if ($GlobalSettingsSuccessfullyLoaded) {    
        Get-SettingsFromFile -SettingsFile "$ProjectRoot\$($Global:SETTINGSFolder)\Settings.ps1"
        if ($Global:LocalSettingsSuccessfullyLoaded) {
            Initialize-Logging   "$ProjectRoot\$LOGSFolder\$ErrorsLogFileName" "Latest"
            Write-Host "Logging initialized."            
        }
        Else {
            Add-ToLog -Message "[Error] Error loading local settings!" -logFilePath "$(Split-Path -path $Global:MyScriptRoot -parent)\$LOGSFolder\$ErrorsLogFileName" -Display -Status "Error" -Format 'yyyy-MM-dd HH:mm:ss'
            Exit 1 
        }
    }
    Else { 
        Add-ToLog -Message "[Error] Error loading global settings!" -logFilePath "$(Split-Path -path $Global:MyScriptRoot -parent)\LOGS\Errors.log" -Display -Status "Error" -Format 'yyyy-MM-dd HH:mm:ss'
        Exit 1
    }
}
# Error trap
trap {
    Get-ErrorReporting $_    
    exit 1
}
#########################################################################

Clear-Host
Initialize-Script

Add-ToLog -Message "Project log rotator started." -logFilePath $ScriptLogFilePath -display -status "Info"

foreach ($Folder in $FoldersToApplyPath){
    
    $LogsFolders = Get-ChildItem -path $Folder -Directory -Filter $LOGSFolder -Recurse -ErrorAction SilentlyContinue
    [datetime] $DeleteAfter = (Get-Date).AddDays(-1* $Global:DaysToRotateLog)

    foreach ($LogsFolder in $LogsFolders ){        
        $LogFiles = Get-ChildItem -path $LogsFolder -filter "*.log" -ErrorAction SilentlyContinue

        foreach ($LogFile in $LogFiles){

            if (!($Global:ExcludeFiles -contains $LogFile)){                
                $FilePath = $LogFile
                Add-ToLog -Message "    Processing [$FilePath]." -logFilePath $ScriptLogFilePath -display -status "Info"
                $Content = Get-Content -Path $FilePath  -Encoding utf8
                [array]$NewContent = @() 
                foreach ($Line in $Content){
                    $Resolved = $True            
                    try {
                        [datetime]$Date = [datetime]::ParseExact($line.Substring(0, 19).trim(), "yyyy-MM-dd HH:mm:ss", $null)
                    }
                    Catch {                
                        try {
                            [datetime]$Date = [datetime]::ParseExact($line.Substring(0, 19).trim(), "dd.MM.yyyy HH:mm:ss", $null)
                        }
                        Catch {
                            try{
                                [datetime]$Date = [datetime]::ParseExact($line.Substring(0, 19).trim(), "dd.MM.yyyy H:mm:ss", $null) 
                            }
                            Catch{
                                $Resolved = $false
                                Add-ToLog -Message "    Error in [$Line] line skipped!" -logFilePath $ScriptLogFilePath -display -status "Error"
                            }
                        }
                    }
                    if (($Date -ge $DeleteAfter) -and $resolved){
                        $NewContent += $line
                    }
                }

                if ($NewContent.count -gt 0) {
                    Add-ToLog -Message "    Rotating file [$FilePath]." -logFilePath $ScriptLogFilePath -display  -status "Info"
                    Out-File  -FilePath $FilePath -InputObject $NewContent -Encoding utf8 -Force
                }
            }
        }
    }
}
Add-ToLog -Message "Project log rotator completed." -logFilePath $ScriptLogFilePath -display -status "Info"