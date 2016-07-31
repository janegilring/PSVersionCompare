<#
	.SYNOPSIS
		A function to retrieve PowerShell commands from a computer. Defaults to the local machine if -ComputerName is not specified.

	.DESCRIPTION
		If you run Get-PSVersionCommand without -Export, you will get all commands from system wide modules returned. With the -Export parameter specified the results will be exported to an XML-file.

	.PARAMETER  ComputerName
		The name of the computer to retrieve information from.

	.PARAMETER  Path
		The path to the generated XML-file when -Export is specified. If -Path is not specified to Get-PSVersionCommand -Export, the default naming convention for the generated XML-file is “OS Caption_PSVersion_PSEdition_Commands.xml” (for example Microsoft Windows Server 2016 Datacenter Technical Preview 5_5.1.14284.1000_Core_Commands.xml).

	.PARAMETER  Export
		Switch parameter to specify export to an XML-file rather than returning the results

	.PARAMETER  ModuleFilter
		Wildcard filter to limit the modules to filter on, for example Microsoft.*

	.EXAMPLE
    Get-PSVersionCommand -Export

	.EXAMPLE
		Get-PSVersionCommand -ComputerName HPV-2016TP5 -Export -Verbose

	.EXAMPLE
		Get-PSVersionCommand -ComputerName HPV-2016TP5 -Export -Path "~\Microsoft Windows Server 2016 Datacenter Technical Preview 5_5.1.14284.1000_Core_Commands.xml"

	.INPUTS
		System.String

	.OUTPUTS
		System.String

	.LINK
		about_PSVersionCompare

#>
function Get-PSVersionCommand
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
    $Export,
    
    [Parameter(Mandatory=$false)]
    [string[]]
    $ModuleFilter = '*'
  )
  
$Session = New-PSSession -ComputerName $ComputerName

$PSVersionCommandData = Invoke-Command -Session $Session -ScriptBlock {


Get-Module -ListAvailable | Where-Object {

($PSItem.ModuleBase -like "$env:SystemRoot\system32\WindowsPowerShell\v1.0\Modules*" -or 
$PSItem.ModuleBase -like "$env:ProgramFiles\WindowsPowerShell\Modules*") -and 
$PSItem.Name -ne 'RemoteDesktop' #workaround for DefaultCommandPrefix issue, implemented only by the RemoteDesktop module. Will be investigated soon.

} | Select-Object Name,ModuleBase,Version -PipelineVariable Module | ForEach-Object -Process {

Get-Command -Module $PSItem.Name | Select-Object -Property Name,@{Name=’Parameters’;Expression={(Get-Command $_).Parameters.Keys}},@{Name=’Module’;Expression={$Module.Name}},@{Name=’ModuleVersion’;Expression={$Module.Version}}

}

}

if ($Export) {

$PathInfo = Invoke-Command -Session $Session -ScriptBlock {

if (-not ($PSEdition)) {

$PSEdition = 'Desktop'

}

($((Get-CimInstance -ClassName win32_operatingsystem).Caption) + '_' + $PSVersionTable.PSVersion.ToString() + '_' + $PSEdition + '_Commands.xml')

}

if (-not ($Path)) {

$Path = Join-Path -Path '~\Documents\' -ChildPath $PathInfo

}

Write-Verbose "Path not specified, generated path: $Path"

$PSVersionCommandData | Export-Clixml -Path $Path

Write-Verbose "Exported PSVersionCommand data from computer $($ComputerName) to path $Path"

Write-Host "Exported PSVersionCommand data from computer $($ComputerName) to path:"

return $Path

} else {

return $PSVersionCommandData

}

Remove-PSSession -Session $Session
  
}