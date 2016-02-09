Windows To Go Creator
=====================

###DESCRIPTION  
This module, once installed, will allow a user to create Windows To Go drives from the PowerShell (PoSh) command line. It will allow the user to run the _New-WindowsToGo_ command at the PoSh command line. This function will create one or more "Windows To Go" drives. It can create up to 11 drives in parallel. All drives must be attached before running this function. You must supply an image file to apply to the drive. You can also supply an unattended installation XML file which will be inserted into each drive. A driver, or collection of drivers in a folder, can also be specified and the function will inject them into the final drive(s). The function also checks for the correct PowerShell version, administrator privelages, presence of drives large enough to fit the supplied image, and prompts the user to select exactly which drives to use before commiting to the creation process.


###REQUIREMENTS  
PowerShell version 4.0 or later (usually included with Windows 8.1 or later.)

###INSTALLATION  
1. Move the folder _WindowsToGo Module_ into _%USERPROFILE%\Documents\WindowsPowerShell\Modules\_.  
**NOTE:** %USERPROFILE% is your user's folder in Windows. It's usually _C:\Users\<your user name>_.
2. Open an elevated PoSh command line by pressing **Windows Key + W** and typing _powershell_. Right click _Windows PowerShell_ in the resultant listing and choose _Run as Administrator_.
3. Type _Set-ExecutionPolicy RemoteSigned_ into the command line and press enter. Choose _Yes_ at the confirmation prompt.  
**WARNING:** This will reduce your security level when using PowerShell, but the risk should be minimal.
4. Type _Get-Module -ListAvailable_ at the command prompt and confirm that _WindowsToGo_ is listed under _Name_ in the _%USERPROFILE%\Documents\WindowsPowerShell\Modules\_ folder (this should be near the top of the output produced, right under the command line entry. You'll probably need to scroll up to find it.)
5. Once you've confirmed that the module is available in Step 3, type _Import-Module WindowsToGo_ at the command prompt. This will import the WindowsToGo module and make it available as a function you can call anywhere and at any time.  
**NOTE:** If the _Import-Module_ command works correctly, you will not see any output or feedback from running the command. You'll just get another command prompt.

###DOCUMENTATION  
Once the module is installed, you can learn how to use the module and the _New-WindowsToGo_ command by typing _Get-Help New-WindowsToGo_ at a PoSh command line.
	
###USAGE  
1. Open an elevated PoSh command line by pressing **Windows Key + W** and typing _powershell_. Right click _Windows PowerShell_ in the resultant listing and choose _Run as Administrator_.
2. Type _New-WindowsToGo_ and then enter the appropriate parameters.
3. Press enter to run the creator.

###SUPPORT  
For support, visit the [GitHub Repository](https://github.com/FirbyKirby/WindowsToGo) and create an issue.

###SPECIAL THANKS  
This module was created by generously leveraging the following sample scripts.
* [Deploy Windows To Go In Your Organization](https://technet.microsoft.com/en-us/library/jj721578.aspx)
* [Use PowerShell To Create Windows To Go Keys](https://blogs.technet.microsoft.com/heyscriptingguy/2015/10/02/use-powershell-to-create-windows-to-go-keyspart-5/)

======
This repository and any materials provided by NI therein are provided AS IS. NI DISCLAIMS ANY AND ALL LIABILITIES FOR AND MAKES NO WARRANTIES, EITHER EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR PARTICULAR PURPOSE, OR NON-INFRINGEMENT OF INTELLECTUAL PROPERTY. NI shall have no liability for any direct, indirect, incidental, punitive, special, or consequential damages for your use of the repository or any materials contained therein.
