<#
    .SYNOPSIS 
        .AUTOR
        .DATE
        .VER
    .DESCRIPTION
    .PARAMETER
    .EXAMPLE
#>
Clear-Host
$Global:ScriptName = $MyInvocation.MyCommand.Name
$InitScript        = "C:\DATA\Projects\GlobalSettings\SCRIPTS\Init.ps1"
if (. "$InitScript" -MyScriptRoot (Split-Path $PSCommandPath -Parent) -force ) { exit 1 }
# Error trap
trap {
    if ($Global:Logger) {
       Get-ErrorReporting $_
        . "$GlobalSettings\$SCRIPTSFolder\Finish.ps1"  
    }
    Else {
        Write-Host "There is error before logging initialized." -ForegroundColor Red
    }   
    exit 1
}
################################# Script start here #################################

foreach ($Folder in $FoldersToApplyPath){
    
    $LogsFolders = Get-ChildItem -path $Folder -Directory -Filter $LOGSFolder -Recurse -ErrorAction SilentlyContinue
    [datetime] $DeleteAfter = (Get-Date).AddDays(-1* $Global:DaysToRotateLog)

    foreach ($Item in $LogsFolders ){ 
        write-host $Item.FullName       
        $LogFiles = Get-ChildItem -path $Item.FullName  -filter "*.log" -ErrorAction SilentlyContinue

        foreach ($LogFile in $LogFiles){
            if ( -not ($Global:ExcludeFiles -contains $LogFile) -and ($LogFile.LastWriteTime -gt $DeleteAfter)) {                
                $FilePath = $LogFile.FullName
                Add-ToLog -Message "Processing [$FilePath]." -logFilePath $ScriptLogFilePath -display -status "Info" -level ($ParentLevel + 1)
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
                                Add-ToLog -Message "Error in [$Line] line skipped!" -logFilePath $ScriptLogFilePath -display -status "Error" -level ($ParentLevel + 1)
                            }
                        }
                    }
                    if (($Date -gt $DeleteAfter) -and $resolved){
                        $NewContent += $line
                    }
                }

                if (($NewContent.count -gt 0) -and ($NewContent.count -ne $Content.count)) {
                    Add-ToLog -Message "Rotating file [$FilePath]." -logFilePath $ScriptLogFilePath -display  -status "Info" -level ($ParentLevel + 1)
                    Out-File  -FilePath $FilePath -InputObject $NewContent -Encoding utf8 -Force
                }
            }
        }
    }
}

################################# Script end here ###################################
. "$GlobalSettings\$SCRIPTSFolder\Finish.ps1"