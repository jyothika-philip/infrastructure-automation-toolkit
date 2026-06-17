# Author: Jyothika Philip
# Project: Infrastructure Automation Toolkit
# Script: System Inventory Script
# Version 1.0
# Purpose: Collect basic system information from a Windows Machine

$ReportPath = "C:\SysAdmin-Automation\reports\system-reports.txt"
$CsvPath = "C:\SysAdmin-Automation\reports\system-inventory.csv"

New-Item -Itemtype Directory -path "C:\SysAdmin-Automation\reports" -Force | Out-Null
Clear-Content -Path $ReportPath -ErrorAction SilentlyContinue

$ComputerName = hostname
$CurrentUser= whoami
$Date = Get-Date

$OS = Get-CimInstance Win32_OperatingSystem
$ComputerSystem = Get-CimInstance Win32_ComputerSystem
$IP = Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -ne "127.0.0.1"}

$Drive = Get-PSDrive -Name C
$FreeSpaceGB = [math]::Round($Drive.Free / 1GB, 2)
$UsedSpaceGB = [math]::Round($Drive.Used / 1GB, 2)
$DiskUsagePercent = [math]::Round(($Drive.Used /($Drive.Used + $Drive.Free))*100, 2)
$TotalRAMGB = [math]::Round([math]::Round($ComputerSystem.TotalPhysicalMemory / 1GB, 2))

Add-Content -Path $ReportPath -Value "System Inventory Report"
Add-Content -Path $ReportPath -Value "-----------------------"
Add-Content -Path $ReportPath -Value "Computer Name: $ComputerName"
Add-Content -Path $ReportPath -Value "Current User: $CurrentUser"
Add-Content -Path $ReportPath -Value "Generated On: $Date"

Add-Content -Path $ReportPath -Value ""
Add-Content -Path $ReportPath -Value "===SYSTEM INFORMATION==="
Add-Content -Path $ReportPath -Value "Operating System: $($OS.Caption)"
Add-Content -Path $ReportPath -Value "OS Version: $($OS.Version)"
Add-Content -Path $ReportPath -Value "Manufacturer: $($ComputerSystem.Manufacturer)"
Add-Content -Path $ReportPath -Value "Model: $($ComputerSystem.Model)"
Add-Content -Path $ReportPath -Value "Total RAM (GB): $TotalRAMGB"

Add-Content -Path $ReportPath -Value ""
Add-Content -Path $ReportPath -Value "===NETWORK INFORMATION==="
Add-Content -Path $ReportPath -Value "IP Address: $($IP.IPAddress)"

Add-Content -Path $ReportPath -Value ""
Add-Content -Path $ReportPath -Value "===Storage INFORMATION==="
Add-Content -Path $ReportPath -Value "Drive: $($Drive.Name)"
Add-Content -Path $ReportPath -Value "Drive: $FreeSpaceGB"
Add-Content -Path $ReportPath -Value "Drive: $UsedSpaceGB"
Add-Content -Path $ReportPath -Value "Disk Usage (%): $DiskUsagePercent"

$Inventory = [PSCustomObject]@{
    ComputerName = $ComputerName
    CurrentUser = $CurrentUser
    OperatingSystem = $OS.Caption
    OSVersion = $OS.Version
    Manufacturer = $ComputerSystem.Manufacturer
    Model = $ComputerSystem.Model 
    RAM_GB = $TotalRAMGB
    IPAddress = $IP.IPAddress
    Drive = $Drive.Name
    FreeSpaceGB = $FreeSpaceGB
    UsedSpace_GB = $UsedSpaceGB
    DiskUsagePercent = $DiskUsagePercent
}


$Inventory | Export-Csv -Path $CsvPath -NoTypeInformation
Write-Output "System inventory report generated successfully."
Write-Output "TXT Report: $ReportPath"
Write-Output "CSV Report: $CSVPath"
