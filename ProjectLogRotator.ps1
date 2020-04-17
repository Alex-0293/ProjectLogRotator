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

$MyScriptRoot = Get-WorkDir

Get-VarsFromFile    "$MyScriptRoot\Vars.ps1"
Initialize-Logging   $MyScriptRoot "Latest"

Add-ToLog -Message "Project log rotator started." -logFilePath $Global:LogFilePath -display -status "Info"

$LogsFolders = Get-ChildItem -path $Global:ProjectsFolder -Directory -Filter "LOGS" -Recurse
[datetime] $DeleteAfter = (Get-Date).AddDays(-1* $Global:DaysToRotateLog)


foreach ($LogsFolder in $LogsFolders ){
    $LogFiles = Get-ChildItem -path $LogsFolder.FullName -filter "*.log" -Recurse
    foreach ($LogFile in $LogFiles){
        $Content = Get-Content -Path $LogFile  -Encoding utf8
        [array]$NewContent = @() 
        foreach ($Line in $Content){
            try {
                [datetime]$Date = [datetime]::ParseExact($line.Substring(0,19), "yyyy-MM-dd HH:mm:ss", $null)
            }
            Catch {
                [datetime]$Date = [datetime]::ParseExact($line.Substring(0, 19), "dd.MM.yyyy HH:mm:ss", $null)
            }
            if ($Date -ge $DeleteAfter){
                $NewContent += $line
            }
        }
        $Diff = Get-DifferenceBetweenArrays -FirstArray $Content -SecondArray $NewContent
        if ($Diff.count -gt 0) {
            Add-ToLog -Message "Rotating file [$LogFile]." -logFilePath $Global:LogFilePath -display  -status "Info"
            Out-File -path $LogFile -InputObject $NewContent -Encoding utf8 -Force
        }
    }
}

Add-ToLog -Message "Project log rotator completed." -logFilePath $Global:LogFilePath -display -status "Info"