<#	
.SYNOPSIS
Installs the GitHub version of the PSVersionCompare module.

.DESCRIPTION
Installs the GitHub version of the PSVersionCompare module in AllUsers or CurrentUser path. 
This file won't be necessary when the module is installed by using PowerShellGet.

.PARAMETER Scope
Sets the installation directory. This parameter is optional. The default is AllUsers.
Valid values are:
-- AllUsers: "$env:ProgramFiles\WindowsPowerShell\Modules"
-- CurrentUser: "$Home\Documents\WindowsPowerShell\Modules"

.EXAMPLE
InstallModule.ps1
This command installs the PSVersionCompare module in ProgramFiles.

.EXAMPLE
InstallModule.ps1 -Scope AllUsers
This command installs the PSVersionCompare module in ProgramFiles.

.EXAMPLE
InstallModule.ps1 -Scope CurrentUser
This command installs the PSVersionCompare module in the $home directory.
#>


param
(
	[ValidateSet('AllUsers', 'CurrentUser')]
	[string]
	$Scope = 'AllUsers'
)

$ModuleName   = "PSVersionCompare"

switch ($Scope) {
	AllUsers { $ModulePath = "$env:ProgramFiles\WindowsPowerShell\Modules" ; break;}
	CurrentUser  { $ModulePath = "$home\Documents\WindowsPowerShell\Modules";  break;}
}

$TargetPath = "$($ModulePath)\$($ModuleName)"

if(!(Test-Path $TargetPath)) { mkdir $TargetPath | out-null}

$targetFiles = Write-Output `
    *.xml `
    *.psm1 `
    *.psd1 `
    *.help.txt

    
Get-ChildItem -Path $targetFiles | 
    ForEach-Object {
        Copy-Item -Verbose -Path $_.FullName -Destination $TargetPath #"$($TargetPath)\$($_.name)"
    }

if(!(Test-Path $TargetPath\Functions)) { mkdir $TargetPath\Functions | out-null}

$targetFiles = Write-Output `
    Functions

    
Get-ChildItem -Path $targetFiles | 
    ForEach-Object {
        Copy-Item -Verbose -Path $_.FullName -Destination (Join-Path -Path $TargetPath -ChildPath Functions)
    }

    if(!(Test-Path $TargetPath\PSCommandData)) { mkdir $TargetPath\PSCommandData | out-null}

$targetFiles = Write-Output `
    PSCommandData

    
Get-ChildItem -Path $targetFiles | 
    ForEach-Object {
        Copy-Item -Verbose -Path $_.FullName -Destination (Join-Path -Path $TargetPath -ChildPath PSCommandData)
    }