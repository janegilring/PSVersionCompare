function Compare-PSVersionCommand
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory=$false)]
    [string]
    $SourceVersionPath,
    
    [Parameter(Mandatory=$false)]
    [string]
    $CompareVersionPath,
    
    [Parameter(Mandatory=$false)]
    [string]
    $ModuleFilter = '*'
  )
  

$SourceVersion = Import-CliXml -Path $SourceVersionPath | Where-Object Module -like $ModuleFilter | Sort-Object -Property Name
$CompareVersion = Import-CliXml -Path $CompareVersionPath | Where-Object Module -like $ModuleFilter | Group-Object -Property Module | Sort-Object -Property Name

foreach ($Module in $CompareVersion) {
 
$SourceModule = $SourceVersion | Where-Object {$_.Module -eq $Module.Name}

if ($SourceModule) {

Write-Host "Command differences in module $($Module.Name)" -ForegroundColor Yellow

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

