Windows To Go Creator
=====================

###DESCRIPTION  
This module, once installed, will allow a user to create "Windows To Go" drives from PowerShell (PoSh.) It will allow a user to run the _New-WindowsToGo_ command at the PoSh command prompt.

The _New-WindowsToGo_ function will create one or more "Windows To Go" drives. It can create up to 11 drives in parallel. All drives should be "Windows To Go" certified and attached to the host computer before running this function. You must supply the path to a Windows Image file (.wim) that will be applied to the USB drives during the creation process. If required, you can also supply an unattended installation answer file (.xml) which will be inserted into each drive during creation. A driver, or collection of drivers in a folder, (with the extension .inf) can also be specified and the function will inject them into the USB drive(s) created.

When executed, this function will check for the correct PowerShell version, administrator privelages, validity of any file paths supplied, presence of USB drives large enough to fit the supplied image, and prompts the user to select exactly which attached USB drives to use before commiting to the creation process.

###REQUIREMENTS  
PowerShell version 4.0 or later (usually included with Windows 8.1 or later.)

###INSTALLATION  
1. Move the folder _WindowsToGo_ into _%USERPROFILE%\Documents\WindowsPowerShell\Modules\_.  
**NOTE:** %USERPROFILE% is your user's folder in Windows. It's usually _C:\Users\\[your user name\]_.
2. Open an elevated PoSh command prompt by pressing **Windows Key + W** and typing _powershell_. Right click _Windows PowerShell_ in the resultant listing and choose _Run as Administrator_.
3. Type `Set-ExecutionPolicy RemoteSigned` at the command prompt and press enter. Choose _Yes_ at the confirmation prompt.  
**WARNING:** This will reduce your security level when using PowerShell and will allow non-microsoft certified scripts and functions to run (like this one,) but the risk should be minimal if you're an infrequent PowerShell user.  You can reverse this change after you've finished using the function in this module by typing `Set-ExecutionPolicy Restricted` at the command prompt.
4. Type `Get-Module -ListAvailable` at the command prompt and confirm that _WindowsToGo_ is listed under _Name_ in the _%USERPROFILE%\Documents\WindowsPowerShell\Modules\_ folder (this should be near the top of the output produced, right under the command prompt entry and you'll probably need to scroll up to find it.)
5. Once you've confirmed that the module is available in Step 3, type `Import-Module WindowsToGo` at the command prompt.  This will import the _WindowsToGo_ module and make it available as a function you can call anywhere and at any time.  
**NOTE:** If the `Import-Module` command works correctly, you will not see any output or feedback from running the command. You'll just get another command prompt.

###DOCUMENTATION  
Once the module is installed, you can learn how to use the module and the _New-WindowsToGo_ command by typing `Get-Help New-WindowsToGo` at a PoSh command prompt.
	
###USAGE  
1. Open an elevated PoSh command prompt by pressing **Windows Key + W** and typing _powershell_. Right click _Windows PowerShell_ in the resultant listing and choose _Run as Administrator_.
2. Type `New-WindowsToGo` and then enter the appropriate parameters and press enter. Use `Get-Help New-WindowsToGo` at the PoSh command prompt if you need help using the function

###EXAMPLES  
`PS> New-WindowsToGo D:\sources\install.wim`  
Create "Windows To Go" disk(s) using Windows installation media attached to the computer (usually through DVD or USB.)

`PS> New-WindowsToGo D:\sources\install.wim -Drivers ~\Desktop\Drivers\`  
Create "Windows To Go" disk(s) using Windows installation media attached to the computer. Inject .inf drivers found in "Drivers" folder on user's desktop.

`PS> New-WindowsToGo ~\Desktop\myimage.wim -UnattendPath ~\Desktop\unattend.xml -MinimumFreeSpace 8GB`  
Create "Windows To Go" disk(s) using a custom windows image file called "myimage.wim". Insert a custom unattended installtion file called "unattend.xml" into the "Windows To Go" drive(s). Ensure that the drive(s) have at least 8GB of free space remaining after creation.

`PS> New-WindowsToGo ~\Desktop\myimage.wim -NoPrompts`  
Create "Windows To Go" disk(s) using a custom windows image file called "myimage.wim". Do not prompt the user for input and image all compatible drives attached to the host computer.

###NOTES  
To improve performance while using the _New-WindowsToGo_ function, disable any real-time virus scan or security software. For example, turn off Windows Defender's real-time protection.

###UPGRADES  
If you would like to upgrade you're module, delete the contents of _%USERPROFILE%\Documents\WindowsPowerShell\Modules\WindowsToGo_ and repeate the installation process listed above for the new version. Be sure to restart your PoSh session or run the _Import-Module_ command with the _-Force_ switch, like this.  
`Import-Module WindowsToGo -Force`

###SUPPORT  
For support, visit the [GitHub Repository](https://github.com/FirbyKirby/WindowsToGo) and create an issue.

###SPECIAL THANKS  
This module was created by generously leveraging the following sample scripts.
* [Deploy Windows To Go In Your Organization](https://technet.microsoft.com/en-us/library/jj721578.aspx)
* [Use PowerShell To Create Windows To Go Keys](https://blogs.technet.microsoft.com/heyscriptingguy/2015/10/02/use-powershell-to-create-windows-to-go-keyspart-5/)

======
This repository and any materials provided by NI therein are provided AS IS. NI DISCLAIMS ANY AND ALL LIABILITIES FOR AND MAKES NO WARRANTIES, EITHER EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR PARTICULAR PURPOSE, OR NON-INFRINGEMENT OF INTELLECTUAL PROPERTY. NI shall have no liability for any direct, indirect, incidental, punitive, special, or consequential damages for your use of the repository or any materials contained therein.
