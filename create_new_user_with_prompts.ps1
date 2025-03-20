# Description: Create a new user account in Active Directory using prompts for user input

# Import the Active Directory module
Import-Module ActiveDirectory


# Prompts for Account Information Input
$FirstName = Read-Host "Enter the user's first name (given name)"
$MiddleInitial = Read-Host "Enter the user's middle initial (if any)"
if ($MiddleInitial -eq "")  {
    $MiddleInitial = "NMN"  # Default value if no middle initial is provided
                            }
$LastName = Read-Host "Enter the user's last name (surname)"

# Function to check password complexity
function Test-PasswordComplexity {
    param (
        [String]$Password
          )
    if ($Password.Length -lt 12) { return $false }
    if ($Password -notmatch '[A-Z]') { return $false }
    if ($Password -notmatch '[a-z]') { return $false }
    if ($Password -notmatch '[0-9]') { return $false }
    if ($Password -notmatch '[\W_]') { return $false }
    return $true                                 
                                  }       

# Prompt for password and confirmation
do {
    $Password = Read-Host "Enter the user's password" -AsPlainText
    $ConfirmPassword = Read-Host "Re-enter the password" -AsPlainText

    # Confirm passwords match and meet complexity requirements
    if ($Password -ne $ConfirmPassword) {
        Write-Host "Passwords do not match. Please try again." -ForegroundColor Red
    } elseif (-not (Test-PasswordComplexity -Password $Password)) {
        Write-Host "Password does not meet complexity requirements. Please try again." -ForegroundColor Red
    }
} while ($Password -ne $ConfirmPassword -or -not (Test-PasswordComplexity -Password $Password))

# Convert the confirmed plain text password to SecureString
$SecurePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force

# Clear the plain text password from memory
$Password = $null
[System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR((ConvertTo-SecureString -String $Password -AsPlainText -Force)))
Write-Host "Password has been set successfully." -ForegroundColor Green

# User Principal Name (UPN) formatting
$DomainName = "adatum.com" # Replace with your domain name
if ($MiddleInitial -eq "NMN") {
    $UserPrincipalName = "$FirstName.$LastName@$DomainName".ToLower()
} else {
    $UserPrincipalName = "$FirstName.$MiddleInitial.$LastName@$DomainName".ToLower()
       }

# Security Account Manager (SAM) Account Name formatting
if ($MiddleInitial -eq "NMN") {
    $SamAccountName = "$FirstName$LastName"
} else {
    $SamAccountName = "$FirstName$MiddleInitial$LastName"
       }

# Function to check if the Organizational Unit (OU) exists in Active Directory
function Test-OUExists {
    param (
        [string]$OUName,
        [string]$DomainPath
    )
    $OUPath = "OU=$OUName,$DomainPath"
    $OUExists = Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$OUPath'" -ErrorAction SilentlyContinue
    return $OUExists
}
# Prompt for Organizational Unit (OU) name and check if it exists
$DomainPath = "DC=adatum,DC=com" # Replace with your domain path
while ($true) {
    $OUName = Read-Host "Enter the name of the OU where the user will be created"
    $OUExists = Test-OUExists -OUName $OUName -DomainPath $DomainPath
    if (-not $OUExists) {
        Write-Host "The OU '$OUName' does not exist. Please check the name and try again." -ForegroundColor Red
    } else {
        Write-Host "The OU '$OUName' exists. Proceeding with user creation..." -ForegroundColor Green
        $OUPath = "OU=$OUName,$DomainPath"
        break
    }
}

# Proceed with the rest of the script


# Prompts for  Organization Information Input
# Display Name and Email Address formatting
if ($MiddleInitial -eq "NMN") {
    $DisplayName = "$FirstName $LastName"
    $EmailAddress = "$FirstName.$LastName@$DomainName".ToLower()
} else {
    $DisplayName = "$FirstName $MiddleInitial $LastName"
    $EmailAddress = "$FirstName.$MiddleInitial.$LastName@$DomainName".ToLower()
       }

$JobTitle = Read-Host "Enter the user's job title"
$Department = Read-Host "Enter department where the user works"
$City = Read-Host "Enter city where the user is located"
$StateProvince = Read-Host "Enter state/province where the user is located"
$Country = Read-Host "Enter country where the user is located"


# Create the new user account in Active Directory
try {
    New-ADUser -Name $DisplayName `
               -GivenName $FirstName `
               -Surname $LastName `
               -SamAccountName $SamAccountName `
               -UserPrincipalName $UserPrincipalName `
               -EmailAddress $EmailAddress `
               -Title $JobTitle `
               -Department $Department `
               -City $City `
               -State $StateProvince `
               -Country $Country `
               -Path $OUPath `
               -AccountPassword $SecurePassword `
               -ChangePasswordAtLogon $True `
               -Enabled $true `
               -DisplayName $DisplayName 

Write-Host "User account '$DisplayName' has been created successfully in the '$OUName' OU." -ForegroundColor Green
} catch {
    Write-Host "Failed to create user account: $_" -ForegroundColor Red
        }