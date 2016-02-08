Windows To Go Creator
=====================

###DESCRIPTION  
This module, once installed, will allow a user to create Windows To Go drives from the PowerShell (PoSh) command line.

###REQUIREMENTS  
PowerShell version 4.0 or later (usually included with Windows 8.1 or later.)

###INSTALLATION  
1. Unzip the module folder into %USERPROFILE%\Documents\WindowsPowerShell\Modules\. This should create a new folder called "WindowsToGo".
2. Open an elevated PoSh command line by pressing Windows Key + W and typing "powershell". Right click "PowerShell" in the resultant listing and choose "Run as Administrator".
3. Type "Set-ExecutionPolicy RemoteSigned" into the command line and press enter. Choose "Yes" at the confirmation prompt.  
WARNING: This will leave your computer vulnerable to security attacks. The risk should be minimal though.
4. Type "Get-Module -ListAvailable" at the command prompt and confirm that "WindowsToGo" is listed under "Name" in the %USERPROFILE%\Documents\WindowsPowerShell\Modules\ folder (this should be near the top.)
5. Once you've confirmed that the module is available in step 3, type "Import-Module WindowsToGo" at the command prompt. This will import the WindowsToGo module and make it available as a function you can call anywhere and at any time.

###DOCUMENTATION  
Once the module is installed, you can learn how to use the module by typing "Get-Help New-WindowsToGo" at a PoSh command line.
	
###USAGE  
1. Open an elevated PoSh command line by pressing Windows Key + W and typing "powershell". Right click "PowerShell" in the resultant listing and choose "Run as Administrator".
2. Type "New-WindowsToGo" and then enter the appropriate parameters.
3. Press enter to run the creator.

###SUPPORT  
For support, visit https://github.com/FirbyKirby/WindowsToGo and create an issue.

###SPECIAL THANKS  
This module was created by generously leveraging the following sample scripts.
https://technet.microsoft.com/en-us/library/jj721578.aspx
https://blogs.technet.microsoft.com/heyscriptingguy/2015/10/02/use-powershell-to-create-windows-to-go-keyspart-5/

======
This repository and any materials provided by NI therein are provided AS IS. NI DISCLAIMS ANY AND ALL LIABILITIES FOR AND MAKES NO WARRANTIES, EITHER EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR PARTICULAR PURPOSE, OR NON-INFRINGEMENT OF INTELLECTUAL PROPERTY. NI shall have no liability for any direct, indirect, incidental, punitive, special, or consequential damages for your use of the repository or any materials contained therein.
