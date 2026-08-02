# Author: Jyothika Philip
# Project: Infrastructure Automation Toolkit
# Script: Active Directory User Automation
# Version: 1.0
# Purpose: Create Active Directory users from a CSV file,
#          validate required fields, skip duplicates, and handle errors.

function New-LabUser
{
    param(
        $User,
        $Password
    )

    # Validate required CSV fields
    if (
        [string]::IsNullOrWhiteSpace($User.FirstName) -or
        [string]::IsNullOrWhiteSpace($User.LastName) -or
        [string]::IsNullOrWhiteSpace($User.Username)
    )
    {
        Write-Host "[ERROR] User record contains missing required information." `
            -ForegroundColor Red

        Write-Host "FirstName: '$($User.FirstName)' | LastName: '$($User.LastName)' | Username: '$($User.Username)'" `
            -ForegroundColor Red
    }
    else
    {
        try
        {
            # Check whether the username already exists
            $ExistingUser = Get-ADUser `
                -Filter "SamAccountName -eq '$($User.Username)'" `
                -ErrorAction Stop

            if ($ExistingUser)
            {
                Write-Host "[SKIP] $($User.Username) already exists." `
                    -ForegroundColor Yellow
            }
            else
            {
                # Create the new Active Directory user
                New-ADUser `
                    -Name "$($User.FirstName) $($User.LastName)" `
                    -GivenName $User.FirstName `
                    -Surname $User.LastName `
                    -SamAccountName $User.Username `
                    -UserPrincipalName "$($User.Username)@lab.local" `
                    -Department $User.Department `
                    -Path "OU=AutomationLab,DC=lab,DC=local" `
                    -AccountPassword $Password `
                    -Enabled $true `
                    -ChangePasswordAtLogon $true `
                    -ErrorAction Stop

                Write-Host "[OK] Created $($User.Username)." `
                    -ForegroundColor Green
            }
        }
        catch
        {
            Write-Host "[ERROR] Failed to process $($User.Username)." `
                -ForegroundColor Red

            Write-Host "Reason: $($_.Exception.Message)" `
                -ForegroundColor Red
        }
    }
}

# Location of the CSV input file
$CsvPath = "C:\SysAdmin-Automation\ad-users.csv"

# Convert the temporary password into the SecureString format required by AD
$Password = ConvertTo-SecureString `
    "P@ssword123!" `
    -AsPlainText `
    -Force

# Import the CSV; each row becomes a PowerShell object
$Users = Import-Csv -Path $CsvPath

# Send each imported user object to the function
foreach ($User in $Users)
{
    New-LabUser -User $User -Password $Password
}
