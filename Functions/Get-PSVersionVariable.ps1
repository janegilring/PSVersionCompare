<#
	.SYNOPSIS
		A function to retrieve PowerShell default variables from a computer. Defaults to the local machine if -ComputerName is not specified.

	.DESCRIPTION
		If you run Get-PSVersionVariable without -Export, you will get all variables is returned. With the -Export parameter specified the results will be exported to an XML-file.

	.PARAMETER  ComputerName
		The name of the computer to retrieve information from.

	.PARAMETER  Path
		The path to the generated XML-file when -Export is specified. If -Path is not specified to Get-PSVersionVariable -Export, the default naming convention for the generated XML-file is “OS Caption_PSVersion_PSEdition_Variables.xml” (for example Microsoft Windows Server 2016 Datacenter Technical Preview 5_5.1.14284.1000_Core_Variables.xml).

	.PARAMETER  Export
		Switch parameter to specify export to an XML-file rather than returning the results

	.EXAMPLE
    Get-PSVersionVariable -Export

	.EXAMPLE
		Get-PSVersionVariable -ComputerName HPV-2016TP5 -Export -Verbose

	.EXAMPLE
		Get-PSVersionVariable -ComputerName HPV-2016TP5 -Export -Path "~\Microsoft Windows Server 2016 Datacenter Technical Preview 5_5.1.14284.1000_Core_Variables.xml"

	.INPUTS
		System.String

	.OUTPUTS
		System.String

	.LINK
		about_PSVersionCompare

#>
function Get-PSVersionVariable
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory=$false)]
    [string]
    $ComputerName = $env:computername,

    [Parameter(Mandatory=$false)]
    [string]
    $Path,

    [Parameter(Mandatory=$false)]
    [switch]
    $Export
  )
  
$Session = New-PSSession -ComputerName $ComputerName

$PSVersionVariableData = Invoke-Command -Session $Session -ScriptBlock {


powershell.exe -NoProfile -Command {Get-Variable | Select-Object -Property Name}

}

if ($Export) {

$PathInfo = Invoke-Command -Session $Session -ScriptBlock {

if (-not ($PSEdition)) {

$PSEdition = 'Desktop'

}

($((Get-CimInstance -ClassName win32_operatingsystem).Caption) + '_' + $PSVersionTable.PSVersion.ToString() + '_' + $PSEdition + '_Variables.xml')

}

if (-not ($Path)) {

$Path = Join-Path -Path '~\Documents\' -ChildPath $PathInfo

}

Write-Verbose "Path not specified, generated path: $Path"

$PSVersionVariableData | Select-Object -Property Name | Export-Clixml -Path $Path

Write-Verbose "Exported PSVersionVariable data from computer $($ComputerName) to path $Path"

Write-Host "Exported PSVersionVariable data from computer $($ComputerName) to path:"

return $Path

} else {

return $PSVersionVariableData

}

Remove-PSSession -Session $Session
  
}