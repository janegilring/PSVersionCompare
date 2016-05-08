$ModuleName   = "PSVersionCompare"
$ModulePath   = "$env:ProgramFiles\WindowsPowerShell\Modules"
$TargetPath = "$($ModulePath)\$($ModuleName)"

if(!(Test-Path $TargetPath)) { md $TargetPath | out-null}

$targetFiles = echo `
    *.xml `
    *.psm1 `
    *.psd1 `
    *.help.txt

    
Get-ChildItem -Path $targetFiles | 
    ForEach {
        Copy-Item -Verbose -Path $_.FullName -Destination $TargetPath #"$($TargetPath)\$($_.name)"
    }

if(!(Test-Path $TargetPath\Functions)) { md $TargetPath\Functions | out-null}

$targetFiles = echo `
    Functions

    
Get-ChildItem -Path $targetFiles | 
    ForEach {
        Copy-Item -Verbose -Path $_.FullName -Destination (Join-Path -Path $TargetPath -ChildPath Functions)
    }

    if(!(Test-Path $TargetPath\PSCommandData)) { md $TargetPath\PSCommandData | out-null}

$targetFiles = echo `
    PSCommandData

    
Get-ChildItem -Path $targetFiles | 
    ForEach {
        Copy-Item -Verbose -Path $_.FullName -Destination (Join-Path -Path $TargetPath -ChildPath PSCommandData)
    }