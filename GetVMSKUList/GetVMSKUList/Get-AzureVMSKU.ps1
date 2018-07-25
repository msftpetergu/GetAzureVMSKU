<#
.SYNOPSIS
    Export Azure VM sizes.
.DESCRIPTION
    This script exports VM SKUs on region basis.
.PARAMETER Cloud
    Specify cloud environment. Valid environments: Public, Mooncake, Fairfax, Blackforest.
.PARAMETER File
	Specify which file to export.
.EXAMPLE
    .\Get-AzureVMSKU.ps1 -Environment Mooncake -File .\SKUList.csv
    Export VM SKU into .\SKUList.csv
.NOTES
    Author: Peter Gu
    Date: 7/25/2018
    Ver: 1.0
.LINK
	Overview of Azure PowerShell: https://docs.microsoft.com/en-us/powershell/azure/overview
#>

Param(
    [Parameter(Mandatory=$False, Position=1)][string]$File = '.\SKUList.csv',
	[Parameter(Mandatory=$False, Position=1)][string][ValidatePattern("^Public$|^Mooncake$|^Fairfax$|^Blackforest$")]$Cloud = 'Public'
)

switch ($Cloud)
{
	"Public" {$Environment = "AzureCloud"}
	"Mooncake" {$Environment = "AzureChinaCloud"}
	"Fairfax" {$Environment = "AzureUSGovernment"}
	"Blackforest" {$Environment = "AzureGermanCloud"}
}

while ((Get-AzureRmContext).Account -eq $null)
{
	Login-AzureRmAccount -Environment $Environment
}

$colSKUList = @()
$Locations = Get-AzureRmLocation

foreach ($l in $Locations)
{

    $SKUInRegion = $l | Get-AzureRmVMSize
    foreach ($sku in $SKUInRegion)
	{
        $objSKUList = New-Object System.Object
        $objSKUList | Add-Member -Type NoteProperty -Name Location -Value $l.DisplayName
        $objSKUList | Add-Member -Type NoteProperty -Name Name -Value $sku.Name 
        $objSKUList | Add-Member -Type NoteProperty -Name NumberOfCores -Value $sku.NumberOfCores 
        $objSKUList | Add-Member -Type NoteProperty -Name MemoryInMB -Value $sku.MemoryInMB 
        $objSKUList | Add-Member -Type NoteProperty -Name MaxDataDiskCount -Value $sku.MaxDataDiskCount 
        $objSKUList | Add-Member -Type NoteProperty -Name OSDiskSizeInMB -Value $sku.OSDiskSizeInMB 
        $objSKUList | Add-Member -Type NoteProperty -Name ResourceDiskSizeInMB -Value $sku.ResourceDiskSizeInMB 
        $colSKUList += $objSKUList
    }
}

$colSKUList | epcsv -not $File
#if (Test-Path($File)) {ii $File}
if (Test-Path($File)) {Write-Host ("Successfully exported VM SKU list to " + (dir $File).FullName) -ForegroundColor Green}
$colSKUList | Out-GridView