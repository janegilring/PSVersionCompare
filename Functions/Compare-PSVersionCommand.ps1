<#
	.SYNOPSIS
		A function to compare PowerShell commands between two computers.

	.DESCRIPTION
		Compare-PSVersionCommand have two parameter sets which makes it possible to compare based on either XML-files pre-gathered from systems, or data gathered directly via PowerShell remoting.

	.PARAMETER  SourceVersionPath
		Path to the source XML-file for the comparison

	.PARAMETER  CompareVersionPath
		Path to the differemce XML-file for the comparison

	.PARAMETER SourceVersionComputerName
		Name of the source computer for the comparison

	.PARAMETER CompareVersionComputerName
		Name of the difference computer for the comparison

	.PARAMETER  ModuleFilter
		Wildcard filter to limit the modules to filter on, for example Microsoft.*

	.EXAMPLE
    Compare-PSVersionCommand -SourceVersionComputerName HPV-VM-2016TP4 -CompareVersionComputerName HPV-JR-2016TP5 -ModuleFilter Microsoft.*

	.EXAMPLE
    $PSCommandDataRoot = 'C:\Program Files\WindowsPowerShell\Modules\PSVersionCompare\PSCommandData'
    $SourceVersionPath = Join-Path -Path $PSCommandDataRoot -ChildPath 'Microsoft Windows Server 2016 Datacenter Technical Preview 4_5.0.10586.0_Desktop.xml'
    $CompareVersionPath = Join-Path -Path $PSCommandDataRoot -ChildPath 'Microsoft Windows Server 2016 Datacenter Technical Preview 5_5.1.14284.1000_Desktop.xml'
    Compare-PSVersionCommand -SourceVersionPath $SourceVersionPath  -CompareVersionPath $CompareVersionPath -ModuleFilter Microsoft.*

	.INPUTS
		System.String

	.OUTPUTS
		Deserialized.Selected.System.Management.Automation.CmdletInfo,Deserialized.Selected.System.Management.Automation.FunctionInfo,Deserialized.Selected.System.Management.Automation.AliasInfo

	.LINK
		about_PSVersionCompare

#>
function Compare-PSVersionCommand
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory=$true,ParameterSetName = 'InputFromXml')]
    [string]
    $SourceVersionPath,
    
    [Parameter(Mandatory=$true,ParameterSetName = 'InputFromXml')]
    [string]
    $CompareVersionPath,

    [Parameter(Mandatory=$true,ParameterSetName = 'InputFromComputer')]
    [string]
    $SourceVersionComputerName,
    
    [Parameter(Mandatory=$true,ParameterSetName = 'InputFromComputer')]
    [string]
    $CompareVersionComputerName,
    
    [Parameter(Mandatory=$false)]
    [string]
    $ModuleFilter = '*'
  )
  

switch ($PSCmdlet.ParameterSetName) {

        'InputFromXml' {
        
          $SourceVersion = Import-CliXml -Path $SourceVersionPath | Where-Object Module -like $ModuleFilter | Sort-Object -Property Name
          $CompareVersion = Import-CliXml -Path $CompareVersionPath | Where-Object Module -like $ModuleFilter | Group-Object -Property Module | Sort-Object -Property Name        
        
         }
        'InputFromComputer' { 
        
          $SourceVersion = Get-PSVersionCommand -ComputerName $SourceVersionComputerName | Where-Object Module -like $ModuleFilter | Sort-Object -Property Name
          $CompareVersion = Get-PSVersionCommand -ComputerName $CompareVersionComputerName | Where-Object Module -like $ModuleFilter | Group-Object -Property Module | Sort-Object -Property Name 
        
        }
}



foreach ($Module in $CompareVersion) {
 
$SourceModule = $SourceVersion | Where-Object {$_.Module -eq $Module.Name}

if ($SourceModule) {

Write-Host "Comparing module $($Module.Name)" -ForegroundColor Yellow

Compare-Object -ReferenceObject $SourceModule -DifferenceObject $Module.Group -Property Name -IncludeEqual -PassThru | ForEach-Object {

    $Command = $_

    if($_.SideIndicator -eq ‘==’)
    {
        $Command = $_

        $cmdold = $SourceModule | Where-Object {$_.Name -eq $Command.Name-and $_.Version -eq $Command.Version} | Select-Object -ExpandProperty Parameters
        $cmdnew = $Module.Group | Where-Object {$_.Name -eq $Command.Name -and $_.Version -eq $Command.Version} | Select-Object -ExpandProperty Parameters

        if (-not $cmdold) {

        Write-Host "$($Command.Name) not found in source version, skip"

        continue

        }


        $compare = Compare-Object $cmdold $cmdnew

        if ($compare)
        {
            try
            {
                $NewParameters = $compare | Where-Object {$_.SideIndicator -eq ‘=>’} | ForEach-Object {$_.InputObject + ‘ (+)’}
                $RemovedParameters = $compare | Where-Object {$_.SideIndicator -eq ‘<=’} | ForEach-Object {$_.InputObject + ‘ (-)’}

                “$($command.Name) (!)”
                $NewParameters + $RemovedParameters | Sort-Object | ForEach-Object { “`t$_”}
                “`n”
            }
            catch{}
        }
    }
    elseif($_.SideIndicator -eq ‘=>’)
    {
        “$($Command.name) (+)`n”
    }
    else
    {
        “$($Command.name) (-)`n”
    }
}
  
  } else {

  Write-Host "Module $($Module.Name) non-existent or not installed in source version" -ForegroundColor Magenta

  }
}
  
}

