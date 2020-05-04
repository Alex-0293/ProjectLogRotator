<#
    .SYNOPSIS 
        .AUTOR
        .DATE
        .VER
    .DESCRIPTION
    .PARAMETER
    .EXAMPLE
#>
$MyScriptRoot = "C:\DATA\ProjectServices\ProjectLogRotator\SCRIPTS"
$InitScript   = "C:\DATA\Projects\GlobalSettings\SCRIPTS\Init.ps1"

. "$InitScript" -MyScriptRoot $MyScriptRoot

# Error trap
trap {
    if ($Global:Logger) {
        Get-ErrorReporting $_ 
    }
    Else {
        Write-Host "There is error before logging initialized." -ForegroundColor Red
    }   
    exit 1
}
################################# Script start here #################################
Clear-Host

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

################################# Script end here ###################################
. "$GlobalSettings\$SCRIPTSFolder\Finish.ps1"