<#
	.SYNOPSIS
		A function to compare PowerShell variables between two computers.

	.DESCRIPTION
		Compare-PSVersionVariable have two parameter sets which makes it possible to compare based on either XML-files pre-gathered from systems, or data gathered directly via PowerShell remoting.

	.PARAMETER  SourceVersionPath
		Path to the source XML-file for the comparison

	.PARAMETER  CompareVersionPath
		Path to the differemce XML-file for the comparison

	.PARAMETER SourceVersionComputerName
		Name of the source computer for the comparison

	.PARAMETER CompareVersionComputerName
		Name of the difference computer for the comparison

	.EXAMPLE
    Compare-PSVersionVariable -SourceVersionComputerName HPV-VM-2016TP4 -CompareVersionComputerName HPV-JR-2016TP5

	.EXAMPLE
    $PSCommandDataRoot = 'C:\Program Files\WindowsPowerShell\Modules\PSVersionCompare\PSCommandData'
    $SourceVersionPath = Join-Path -Path $PSCommandDataRoot -ChildPath 'Microsoft Windows Server 2016 Datacenter Technical Preview 4_5.0.10586.0_Desktop_Variables.xml'
    $CompareVersionPath = Join-Path -Path $PSCommandDataRoot -ChildPath 'Microsoft Windows Server 2016 Datacenter Technical Preview 5_5.1.14284.1000_Desktop_Variables.xml'
    Compare-PSVersionVariable -SourceVersionPath $SourceVersionPath  -CompareVersionPath $CompareVersionPath

	.INPUTS
		System.String

	.OUTPUTS
		System.String

	.LINK
		about_PSVersionCompare

#>
function Compare-PSVersionVariable
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
    $CompareVersionComputerName
    
  )
  
  
  switch ($PSCmdlet.ParameterSetName) {

        'InputFromXml' {
        
          $SourceVersion = Import-CliXml -Path $SourceVersionPath | Sort-Object -Property Name
          $CompareVersion = Import-CliXml -Path $CompareVersionPath | Sort-Object -Property Name        
        
         }
        'InputFromComputer' { 
        
          $SourceVersion = Get-PSVersionVariable -ComputerName $SourceVersionComputerName | Sort-Object -Property Name
          $CompareVersion = Get-PSVersionVariable -ComputerName $CompareVersionComputerName | Sort-Object -Property Name 
        
        }
      }

      Compare-Object -ReferenceObject $SourceVersion -DifferenceObject $CompareVersion -Property Name -IncludeEqual -PassThru


}