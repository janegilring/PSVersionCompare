Import-Module $PSScriptRoot\..\PSVersionCompare.psd1 -Force

InModuleScope PSVersionCompare {

Describe 'Compare-PSVersionCommand' {

 Context "Desired output" {

#dummy test for initial AppVeyor setup
$true | Should Be $true

     }

   }

}
