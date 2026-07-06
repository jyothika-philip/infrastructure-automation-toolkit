# Author: Jyothika Philip
# Project: Infrastructure Automation Toolkit
# Script: Windows Service Monitoring
# Version: 1.0
# Purpose: Monitor selected Windows services and generate TXT and CSV reports

$ReportFolder = "C:\SysAdmin-Automation\reports"
$ReportPath = "$ReportFolder\service-health-report.txt"
$CsvPath = "$ReportFolder\service-health-report.csv"

New-Item -ItemType Directory -Path $ReportFolder -Force | Out-Null
Clear-Content -Path $ReportPath -ErrorAction SilentlyContinue

$Services = @(
    "Spooler",
    "WPDBusEnum",
    "W32Time",
    "Dnscache"
)

$RunningCount = 0
$StoppedCount = 0
$StoppedServices = @()
$ServiceResults = @()
$Date = Get-Date

Add-Content -Path $ReportPath -Value "Service Health Report"
Add-Content -Path $ReportPath -Value "---------------------"
Add-Content -Path $ReportPath -Value "Generated On: $Date"
Add-Content -Path $ReportPath -Value ""

foreach ($ServiceName in $Services)
{
    $Service = Get-Service $ServiceName

    if ($Service.Status -eq "Running")
    {
        Write-Host "[OK] $($Service.DisplayName) is running." -ForegroundColor Green
        Add-Content -Path $ReportPath -Value "[OK] $($Service.DisplayName) is running."
        $RunningCount++
    }
    else
    {
        Write-Host "[ERROR] $($Service.DisplayName) is stopped." -ForegroundColor Red
        Add-Content -Path $ReportPath -Value "[ERROR] $($Service.DisplayName) is stopped."
        $StoppedCount++
        $StoppedServices += $Service.DisplayName
    }

    $ServiceResults += [PSCustomObject]@{
        ServiceName = $Service.Name
        DisplayName = $Service.DisplayName
        Status = $Service.Status
    }
}

Add-Content -Path $ReportPath -Value ""
Add-Content -Path $ReportPath -Value "Summary"
Add-Content -Path $ReportPath -Value "-------"
Add-Content -Path $ReportPath -Value "Running Services: $RunningCount"
Add-Content -Path $ReportPath -Value "Stopped Services: $StoppedCount"

if ($StoppedCount -gt 0)
{
    Add-Content -Path $ReportPath -Value ""
    Add-Content -Path $ReportPath -Value "Stopped Services:"
    
    foreach ($StoppedService in $StoppedServices)
    {
        Add-Content -Path $ReportPath -Value "- $StoppedService"
    }
}
else
{
    Add-Content -Path $ReportPath -Value ""
    Add-Content -Path $ReportPath -Value "All monitored services are running."
}

$ServiceResults | Export-Csv -Path $CsvPath -NoTypeInformation

Write-Host ""
Write-Host "Service health report generated successfully."
Write-Host "TXT Report: $ReportPath"
Write-Host "CSV Report: $CsvPath"
