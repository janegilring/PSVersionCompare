[![Build status](https://ci.appveyor.com/api/projects/status/jf3wbishvjj9a6i6?svg=true)](https://ci.appveyor.com/project/janegilring/psversioncompare)

# PSVersionCompare

Until PowerShell 5.0 was released as part of Windows Management Framework 5.0, the build number was rounded to .0, such as 1.0, 2.0, 3.0, and 4.0. However, in this new and fast moving pace Microsoft have gotten into, we will see more frequent updates to PowerShell than before. Due to this, the PowerShell version number isn’t simply 5.0 anymore as you might have expected. Now it’s a full build number, such as 5.0.10586.117 for the RTM release of Windows Management Framework 5 for downlevel operating systems.

Because of this difficulty, the PSVersion module was created (available as a separate module). It contains the Get-PSVersion function, which can read a mapping table and convert the PSVersion property to a “PSFriendlyVersionName” which makes more sense to a user.

Version number is one element, another one which is not easy to keep track of as a regular PowerShell user is what commands are new or changed. For example, parameters might be added or removed from existing cmdlets.

There are some code snippets available to compare changes between versions, but customizing these every time you use it might become tedious.  Since the need to perform this task will occur more and more often going forward, I decided to turn this into a reusable function. The function is named Compare-PSVersionCommand and is available in the module PSVersionCompare. You can either get it directly from GitHub, or use PowerShellGet to install it from the PowerShell Gallery: Install-Module -Name PSVersionCompare

In the initial version, Compare-PSVersionCommand have two parameter sets which makes it possible to compare based on either XML-files pre-gathered from systems, or data gathered directly via PowerShell remoting.

You can read more about the background and see examples in the following article on PowerShell Magazine:
http://www.powershellmagazine.com/2016/04/29/comparing-commands-between-powershell-versions/

# Todo list
A Name parameter for specifying what command to compare. If not specified, all commands will be compared.
Options for output- formats, such as CSV, JSON, and HTML. Default output format is meant for interactive usage, not to export.
An Online parameter for retrieving the XML files for the specified PS Versions from an online location. Defaults to the PSCommandData folder in the Git repository.
Add Pester tests
Add help
