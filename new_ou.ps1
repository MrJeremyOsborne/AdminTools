# variables
$OUName     = "London"
$DomainDN   = "DC=Adatum,DC=com"
$OUPath     = "OU=$OUName,$DomainDN"

# Check if the OU exists
if (-not (Get-ADOrganizationalUnit -Filter "Name -eq '$OUName'" -SearchBase $DomainDN)) {
    
    # Create the OU if it does not exist
        New-ADOrganizationalUnit -Name $OUName -Path $DomainDN
        Write-Output "Organizational Unit '$OUName' created successfully."              }
else {
    # Create the OU if it does not exist
        Write-Output "Organizational Unit '$OUName' already exists."
     }


# variables
$OUName     = "London"
$DomainDN   = "DC=Adatum,DC=com"
$OUPath     = "OU=$OUName,$DomainDN"
$GroupName  = "London Users"

# Create a Global Security Group for "London" Users" inside the "London" OU if it does not exist
if (-not (Get-ADGroup -Filter "Name -eq '$GroupName'" -SearchBase $OUPath)) {
    New-ADGroup -Name $GroupName -GroupScope Global -GroupCategory Security -Path $OUPath
    Write-Output "Group '$GroupName' created successfully."                 }
else {
    Write-Output "Group '$GroupName' already exists."
     }


# variables
$LondonUsers = Get-ADUser -Filter {city -eq "London"} -Properties City

# Find all users whose city property is set to "London" and sort users alphabetically by name
get-aduser -filter {city -eq "London"} -Properties City | Select-Object Name, City | 
Sort-Object Name |Format-Table

#Move the London users to the "London" OU
foreach ($User in $LondonUsers) {
    Move-ADObject -Identity $User -TargetPath $OUPath
    Write-Output "User '$($User.Name)' moved to '$OUName' OU."
                                }

# Move the London users to the London Users group
foreach ($User in $LondonUsers) {
    Add-ADGroupMember -Identity $GroupName -Members $User
    Write-Output "User '$($User.Name)' added to '$GroupName' group."
                                }