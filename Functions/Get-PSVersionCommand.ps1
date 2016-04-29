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

($((Get-CimInstance -ClassName win32_operatingsystem).Caption) + '_' + $PSVersionTable.PSVersion.ToString() + '_' + $PSEdition + '.xml')

}

if (-not ($Path)) {
$Path = Join-Path -Path '~\Documents\' -ChildPath $PathInfo
}

Write-Verbose "Path not specified, generated path: $Path"

$PSVersionCommandData | Export-Clixml -Path $Path

Write-Verbose "Exported PSVersionCommand data from computer $($ComputerName) to path $path"

} else {

$PSVersionCommandData

}

Remove-PSSession -Session $Session
  
}

