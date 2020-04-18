#rename this file to Vars.ps1 
    [string]$ProjectPath = "C:\ProjectLogRotator"
#### Script params    
    [string]$Global:ProjectsFolder   = "C:\Projects"
    [string]$Global:LogFolder        = "LOGS"
    [Int16] $Global:DaysToRotateLog  = 30
    [string]$Global:LogFilePath      = "$ProjectPath\LOGS\ProjectLogRotator.log"    
