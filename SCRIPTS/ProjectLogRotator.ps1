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
# Error trap
trap {
    Get-ErrorReporting $_    
    exit 1
}
#########################################################################

Clear-Host

[string]$MyScriptRoot        = Get-WorkDir
[string]$Global:ProjectRoot  = Split-Path $MyScriptRoot -parent

Get-VarsFromFile    "$ProjectRoot\VARS\Vars.ps1"
Initialize-Logging   $ProjectRoot "Latest"

Add-ToLog -Message "Project log rotator started." -logFilePath $Global:LogFilePath -display -status "Info"

$LogsFolders = Get-ChildItem -path $Global:ProjectsFolder -Directory -Filter "LOGS" -Recurse -ErrorAction SilentlyContinue
[datetime] $DeleteAfter = (Get-Date).AddDays(-1* $Global:DaysToRotateLog)


foreach ($LogsFolder in $LogsFolders ){
    $LogFiles = Get-ChildItem -path $LogsFolder.FullName -filter "*.log" -Recurse  -ErrorAction SilentlyContinue
    foreach ($LogFile in $LogFiles){
        if (!($Global:ExcludeFiles -contains $LogFile.name)){
            $FilePath = $LogFile.FullName
            Write-Host $LogFilePath
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
                            Add-ToLog -Message "Error in [$Line] line skipped!" -logFilePath $Global:LogFilePath -display -status "Error"
                        }
                    }
                }
                if (($Date -ge $DeleteAfter) -and $resolved){
                    $NewContent += $line
                }
            }

            if ($NewContent.count -gt 0) {
                Add-ToLog -Message "Rotating file [$FilePath]." -logFilePath $Global:LogFilePath -display  -status "Info"
                Out-File  -FilePath $FilePath -InputObject $NewContent -Encoding utf8 -Force
            }
        }
    }
}

Add-ToLog -Message "Project log rotator completed." -logFilePath $Global:LogFilePath -display -status "Info"