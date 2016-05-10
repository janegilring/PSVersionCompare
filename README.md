[![Build status](https://ci.appveyor.com/api/projects/status/jf3wbishvjj9a6i6?svg=true)](https://ci.appveyor.com/project/janegilring/psversioncompare)

# Introduction

The PSVersionCompare module contains functionality for comparing commands between Windows PowerShell versions. By running Compare-PSVersionCommand and specifying either a set of 2 computer names or 2 XML-files to run the comparison against, output will be returned indicating whether a command or parameter is added (+), changed (!) or removed (-).

Until PowerShell 5.0 was released as part of Windows Management Framework 5.0, the build number was rounded to .0, such as 1.0, 2.0, 3.0, and 4.0. However, in this new and fast moving pace Microsoft have gotten into, we will see more frequent updates to PowerShell than before. Due to this, the PowerShell version number isn’t simply 5.0 anymore as you might have expected. Now it’s a full build number, such as 5.0.10586.117 for the RTM release of Windows Management Framework 5 for downlevel operating systems.

Because of this difficulty, the [PSVersion](https://github.com/janegilring/PSVersion) module was created (available as a separate module). It contains the Get-PSVersion function, which can read a mapping table and convert the PSVersion property to a “PSFriendlyVersionName” which makes more sense to a user.

Version number is one element, another one which is not easy to keep track of as a regular PowerShell user is what commands are new or changed. For example, parameters might be added or removed from existing cmdlets.

There are some code snippets available to compare changes between versions, but customizing these every time you use it might become tedious.  Since the need to perform this task will occur more and more often going forward, I decided to turn this into a reusable function. The function is named Compare-PSVersionCommand and is available in the module PSVersionCompare. You can either get it directly from GitHub, or use PowerShellGet to install it from the PowerShell Gallery: Install-Module -Name PSVersionCompare

In the initial version, Compare-PSVersionCommand have two parameter sets which makes it possible to compare based on either XML-files pre-gathered from systems, or data gathered directly via PowerShell remoting.

You can read more about the background and see examples in the [this](http://www.powershellmagazine.com/2016/04/29/comparing-commands-between-powershell-versions/) article on PowerShell Magazine.


# Installation

The module is published to the PowerShell Gallery, which means you can install it using the following command from the PowerShellGet module:

`Install-Module -Name PSVersionCompare`

or the following if you want it installed the current users profile (*$env:userprofile\Documents\WindowsPowerShell\Modules*) rather than the system wide location (*$env:programfiles\WindowsPowerShell\Modules*):

`Install-Module -Name PSVersionCompare -Scope CurrentUser`

When a new version is released with bug fixes or new functionality you can update to the latest version simply by typing the following command:

`Update-Module -Name PSVersionCompare`

PowerShellGet is included by default in PowerShell V5, and available downlevel for PowerShell 3.0 and 4.0.

If you want to install the module without leveraging PowerShellGet, you can either clone the Git-repository or download [this](https://github.com/janegilring/PSVersionCompare/archive/master.zip) ZIP-file and place the contains in one of the following locations:
- $env:userprofile\Documents\WindowsPowerShell\Modules\PSVersionCompare
- $env:programfiles\WindowsPowerShell\Modules\PSVersionCompare


# Usage

The module contains 2 functions:
- **Compare-PSVersionCommand** - A function to compare PowerShell commands between two computers. This function got two parameter sets which makes it possible to compare based on either XML-files pre-gathered from systems, or data gathered directly via PowerShell remoting.
- **Get-PSVersionCommand** - A function to retrieve PowerShell commands from a computer. Defaults to the local machine if -ComputerName is not specified. If you run Get-PSVersionCommand without -Export, you will get all commands from system wide modules returned. With the -Export parameter specified the results will be exported to an XML-file. Get-PSVersionCommand is internally leveraged by the Compare-PSVersionCommand function, but it is also exposed to the user in order to offer a convenient way to gather and export commands to an XML-file

Both functions supports the -ModuleFilter parameter, which makes it possible to filter what modules to retrieve commands from.

**Input gathered via PowerShell remoting**

```powershell
Compare-PSVersionCommand -SourceVersionComputerName HPV-VM-2016TP4 -CompareVersionComputerName HPV-JR-2016TP5 -ModuleFilter Microsoft.*
```

 
**Input from XML**
```powershell
$PSCommandDataRoot = 'C:\Program Files\WindowsPowerShell\Modules\PSVersionCompare\PSCommandData'

$SourceVersionPath = Join-Path -Path $PSCommandDataRoot -ChildPath 'Microsoft Windows Server 2016 Datacenter Technical Preview 4_5.0.10586.0_Desktop.xml'

$CompareVersionPath = Join-Path -Path $PSCommandDataRoot -ChildPath 'Microsoft Windows Server 2016 Datacenter Technical Preview 5_5.1.14284.1000_Desktop.xml'

Compare-PSVersionCommand -SourceVersionPath $SourceVersionPath  -CompareVersionPath $CompareVersionPath -ModuleFilter Microsoft.*
```

#Planned features

- A Name parameter for specifying what command to compare. If not specified, all commands will be compared.
- Options for output- formats, such as CSV, JSON, and HTML. Default output format is meant for interactive usage, not to export.
- An Online parameter for retrieving the XML files for the specified PS Versions from an online location. Defaults to the PSCommandData folder in the Git repository.
- Add Pester tests
- Add help

#Contributors

[Jan Egil Ring](https://twitter.com/JanEgilRing) - author

[June Blender](https://twitter.com/juneb_get_help) - invaluable assist with help content

Everyone is welcome to assist by forking the project and submitting pull requests with proposed fixes and enhancements.