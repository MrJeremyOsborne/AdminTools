# variables
$OUName     = "London"
$DomainDN   = "DC=Adatum,DC=com"
$OUPath     = "OU=$OUName,$DomainDN"
$GroupName = "London Users"

# Create a Global Security Group for "London" Users" inside the "London" OU if it does not exist
if (-not (Get-ADGroup -Filter "Name -eq '$GroupName'" -SearchBase $OUPath)) {
    New-ADGroup -Name $GroupName -GroupScope Global -GroupCategory Security -Path $OUPath
    Write-Output "Group '$GroupName' created successfully."                 }
else {
    Write-Output "Group '$GroupName' already exists."
     }

