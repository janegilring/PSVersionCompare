Import-Module $PSScriptRoot\..\PSVersionCompare.psd1 -Force


Describe 'about_PSVersionCompare' {

 Context "Desired output" {

(Get-Help about_PSVersionCompare).GetType().FullName | Should Be System.String

     }

   }
