<#
.SYNOPSIS
Function to create "Windows To Go" drives.

.DESCRIPTION
The New-WindowsToGo function will create one or more "Windows To Go" drives. It can create up to 11 drives in parallel. All drives should be "Windows To Go" certified and attached to the host computer before running this function. 

You must supply the path to a Windows Image file (.wim) that will be applied to the USB drives during the creation process. If required, you can also supply an unattended installation answer file (.xml) which will be inserted into each drive during creation. A driver, or collection of drivers in a folder, (with the extension .inf) can also be specified and the function will inject them into the USB drive(s) created. 

When executed, this function will check for the correct PowerShell version, administrator privileges, validity of any file paths supplied, presence of USB drives large enough to fit the supplied image, and prompts the user to select exactly which attached USB drives to use before committing to the creation process.

.FUNCTIONALITY
Create one or more "Windows To Go" drives.

.PARAMETER  InstallWIMPath
Path to a windows image file (.wim). This image will be applied to each "Windows To Go" drive created. This parameter is mandatory.

.PARAMETER  Index
Index of image to use inside of windows image file (.wim).This image will be applied to the "Windows To Go" drive(s) created. This is an optional parameter. The default is 1.

.PARAMETER  MinimumFreeSpace
This parameter is a numeric parameter that defines the minimum free space that should be left over for the OS after the drive is created. This is an optional parameter. The default is 2 GB.

.PARAMETER  UnattendPath
Path to a windows unattended installation answer file (.xml). This file affects SYSPREP in the Windows To Go drive and only has an effect on an image that has been captured during SYSPREP. This is an optional parameter. 

If no path is defined, an unattended installation file will be auto-generated to uninstall the Windows Recovery Environment (which is a normal practice for "Windows To Go" drives.) If you captured the supplied image while SYSPREP was running and supplied your own unattended installation file, the existing file in the image takes precedent.

.PARAMETER  Drivers
Path to a driver (.inf) file, or a collection of driver files within a folder. The function will attempt to inject these drivers into the drives. This is an optional parameter.

.PARAMETER  NoPrompts
This switch will automatically answer all prompts with default answers. There are only 2 prompts. The first confirms you wish to create drives based on the supplied inputs, and the second set of prompts confirms each drive to use. The default is to proceed with creation, and use all compatible drives attached to the host computer. This parameter is optional.

.EXAMPLE
New-WindowsToGo D:\sources\install.wim
Create "Windows To Go" disk(s) using Windows installation media attached to the computer.

.EXAMPLE
New-WindowsToGo D:\sources\install.wim -Drivers ~\Desktop\Drivers\
Create "Windows To Go" disk(s) using Windows installation media attached to the computer. Inject .inf drivers found in "Drivers" folder on users desktop.

.EXAMPLE
New-WindowsToGo ~\Desktop\myimage.wim -UnattendPath ~\Desktop\unattend.xml -MinimumFreeSpace 8GB
Create "Windows To Go" disk(s) using a custom windows image file called "myimage.wim". Insert a custom unattended installation file called "unattend.xml" into the "Windows To Go" drive(s). Ensure that the drive(s) have at least 8GB of free space remaining after creation.

.EXAMPLE
New-WindowsToGo ~\Desktop\myimage.wim -NoPrompts
Create "Windows To Go" disk(s) using a custom windows image file called "myimage.wim". Do not prompt the user for input and image all compatible drives attached to host computer.

.NOTES
The function requires PowerShell version 5.0 or later (usually found in Windows 10 or later.) To improve performance, disable any real-time virus scan or security software. For example, turn off Windows Defender's real-time protection.

For support, visit the GitHub repository at https://github.com/FirbyKirby/WindowsToGo and create an issue.

.LINK
https://github.com/FirbyKirby/WindowsToGo
#>

Function New-WindowsToGo {
param (
    [parameter(Mandatory=$true, Position=1, HelpMessage="Specify a path to a windows image file (.wim) to be applied to a USB drive.")]
    [alias("Image","WIM","ImagePath","WIMPath")]
    [string]
    #Path to a windows image file (.wim) to image the USB disk with.
    $InstallWIMPath,

    [int]
    [alias("ImageIndex")]
    #Index to image inside of windows image file (.wim).
    $Index = 1,

    [long]
    [alias("FreeSpace","MarginSpace","ExtraSpace")]
    #Minimum Free Disk space. Default is 2GB. This is the "extra" OS partition space you want to have, at minimum, after the drive is created and the image is applied.
    $MinimumFreeSpace = 2GB,

    [string]
    [alias("Unattend","XML","AnswerFile","Answer","UnattendFile")]
    #Path to an unattended installation file (usually unattend.xml, always an XML file.)
    $UnattendPath,

    [string]
    [alias("Driver","DriverFolder","INF")]
    #Path to a folder of drivers to inject into the Windows To Go OS. Folder must have at least one .inf file.
    $Drivers,

    [switch]
    #Default answer to all prompts. Run the function without any prompts for user.
    $NoPrompts
)

#Set the system partition size.
$SystemPartitionSize = 350MB

Clear-Host
Write-Host "=============  Windows To Go Drive Creator - Version 1.0  ============="
Write-Host "For support visit https://github.com/FirbyKirby/WindowsToGo            "
Write-Host "NOTE: To improve performance, disable real-time virus scan software.   `n"

#Test to see if the function is running in an elevated powershell. If not, throw a warning and exit.
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")){
  Write-Warning "You do not have Administrator rights to run this function!`nPlease re-run this function as an Administrator!"
  return
}

#Test to see that the function is running in Powershell 4.0 or later. If not, throw a warning and exit.
if ($PSVersionTable.PSVersion.Major -lt 5){
  Write-Warning "This function requires PowerShell 5.0 or greater (usually Windows 10 or later.)`n Please re-run this scrip on a compatible computer."
  return
}

#Test to make sure the path is valid. If not, throw a warning and exit.
Write-Host "Checking supplied file paths..."
if (Test-Path $InstallWIMPath -PathType Leaf -Include *.wim){
  #If the path is good, let's gather some info about the image including its name, description and uncompressed size.
  $InstallWIMPath = Resolve-Path $InstallWIMPath
  $ImageName = (Get-WindowsImage -ImagePath $InstallWIMPath -Index $Index).ImageName
  $ImageDescription = (Get-WindowsImage -ImagePath $InstallWIMPath -Index $Index).ImageDescription
  $ImageSize = (Get-WindowsImage -ImagePath $InstallWIMPath -Index $Index).ImageSize
  
  #Calculate the minimum USB disk size required. Put it in a pretty string format for printing purposes too.
  $DriveSize = $ImageSize + $SystemPartitionSize + $MinimumFreeSpace
  $DriveSizeString = "{0:N2}" -f ($DriveSize / 1GB)
  
  #Let the user know a valid image file was found.
  Write-host "Valid image file found: $installWIMPath"
}
else{
  #Checked the file to make sure it was a valid path to a single .WIM file and found something wrong.
  write-Warning "Image file path does not point to a valid .wim file: $InstallWIMPath"
  write-Host "`nExiting the function."
  return
}

#Find out if we have a valid Unattended installation XML file path.
$ValidUnattendPath = $false

#First, check to see if a file path was supplied by the user.
If ($UnattendPath.Length -ne 0){
  #If a path was supplied, check to see that it's a file and not a folder, and that it's an XML file extension.
  If (Test-Path $UnattendPath -PathType Leaf -Include *.xml){
    $UnattendPath = Resolve-Path $UnattendPath
    Write-Host "Valid unattended installation file found: $UnattendPath"
    $ValidUnattendPath = $True
  }
  else{
    Write-Warning "Unattended installation file path does not point to a valid XML file: $UNattendPath"
    write-Host "`nExiting the function."
    return
  }
}

#Find out if we have a valid driver(s) path.
$ValidDriversPath = $false

#First, check to see if a file or folder path was supplied by the user.
If ($Drivers.Length -ne 0){
  #If a path was provided, recursively list all files with *.inf file pattern in the supplied path.
  $InfFiles = ls $Drivers -filter *.inf -recurse
  
  #If at least one *.inf file is found, we have a valid path.
  If ($InfFiles.Length -ne 0){
    $Drivers = Resolve-Path $Drivers
    Write-Host "Valid driver(s) found: $Drivers"

    #Output each .inf file found if user enables the -Verbose flag.
    Write-Verbose "Here are all the drivers to be inserted."
    foreach ($InfFile in $InfFiles){Write-Verbose $InfFile}
    $ValidDriversPath = $True
  }
  else{
    #Driver path supplied by user was invalid.
    Write-Warning "Drivers file path does not point to valid .inf file(s): $Drivers"
    write-Host "`nExiting the function."
    return
  }
}

#Give the user some info on the image we're going to apply during the creation process.
Write-host "`n======================================================================="
Write-Host "Image Name: $ImageName"
Write-Host "Image Description: $ImageDescription"
Write-Host "======================================================================="

#If the noprompts flag is applied, skip the prompt and give the default answer.
if ($NoPrompts){
  $Result = 0
}
else{
  #Prompt the user before you start so they know what they're getting into, unless the NoPrompts switch is supplied.
  Write-Host "`nThis function will create a `"Windows To Go`" drive on any $DriveSizeString GB or larger USB drive."
  Write-Host "The `"Windows To Go`" drive will be imaged with `"$ImageName.`""
  Write-Host "Ensure that at least one `"Windows To Go`" certified USB drive is currently attached to the computer."
  Write-Host "All data currently on the selected USB drive(s) will be lost."
  
  $title = "" #I could put a string here as a title, but I think these titles are redundant since the message is directly below.
  $message = "`nAre you sure you wish to continue?"

  $continue = New-Object System.Management.Automation.Host.ChoiceDescription "&Continue", `
    "Begin creating `"Windows To Go`" drives."

  $exit = New-Object System.Management.Automation.Host.ChoiceDescription "&Exit", `
    "Exits the function. No changes are made to the USB storage drives or your computer."

  $options = [System.Management.Automation.Host.ChoiceDescription[]]($continue, $exit)
  
  $result = $host.ui.PromptForChoice($title, $message, $options, 0) 
}

switch ($result)
    {
        0 {
            Write-Host "`nLet's get started."
        }
        1 {
            Write-Host "`nExiting the function. No changes were made to any USB storage drives or your computer."
            return
        }
    }

#Get the architecture of the windows image file (.wim) supplied by the user.
if ( (Get-WindowsImage -ImagePath $InstallWIMPath -Index $Index).Architecture -eq 0 ){
    $Arch = "x86"
}
else{
    $Arch = "amd64"
}

#Find all the USB drives attached to this computer that are not currently used as a boot drive, and of a size larger than the minimum required.
#Minimum drive size is set above and is a combination of the image size, system partition size, and the user supplied minimum free space.
$RawDisks = Get-Disk | Where-Object {$_.Path -match "USBSTOR" -and $_.Size -gt $DriveSize -and -not $_.IsBoot -and -not $_.IsReadOnly }
if ($RawDisks -eq $null)
{
    #If no drives are found that meet the minimum size requirement, or are not currently booted, tell the user and exit.
    Write-Warning "No USB storage drive(s) larger than $DriveSizeString GB were found."
    Write-Verbose "Please ensure that you have at least one USB drive connected before running this function."
    Write-Host "`nExiting the function."
    return
}

#Show the user all the USB drives currently connected which meet minimum size criteria and are non-boot.
$RawDisks | Format-Table @{Label="Disk"; Expression={$_.Number}},@{Label="Name"; Expression={$_.FriendlyName}},@{Label="Status"; Expression={$_.OperationalStatus}},@{Label="Writeable"; Expression={-not $_.IsReadOnly}},@{Label="Size"; Expression={"{0:N2}" -f ($_.AllocatedSize / 1GB) + ' GB'}}
Write-Host "USB drive(s) larger than $DriveSizeString GB found attached to this computer."

#Create a new empty array where our final, user selected disks will go for batch imaging.
$Disks = @()

#If no prompts switch is in place, just try and image all attached compatible drives.
if ($NoPrompts){
  foreach ($CurrentDisk in $RawDisks){$Disks = $Disks + $CurrentDisk}
}
else{
  #We need to make sure that just the USB storage drives that the user wants to create are selected.
  #The following sections will take the raw list of candidate drives and iterate through them asking the user to confirm or skip each one.
  #The final list of confirmed drives will then be created in parallel.
  Write-Host "Please confirm each USB drive you wish to use..."

  #Iterate through all the disks discovered and ask the user if they want to image them. If yes, add to a new array.
  foreach ($CurrentDisk in $RawDisks){
    #Get a friendly name for the current candidate drive, and it's reported drive number.
    $friendlyname = $CurrentDisk.FriendlyName
    $number = $CurrentDisk.Number
    
    #Compose message to user asking if they want to use the current drive.
    $title = "Confirm USB Target"
    $message = "Are you sure you wish to use Disk $number ($friendlyname)?"

    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
      "Use this USB drive."

    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
      "Skip this USB drive."

    $exit = New-Object System.Management.Automation.Host.ChoiceDescription "&Exit", `
      "Exit the function. Make no changes to USB drives or the host computer."

    $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no, $exit)
  
    $result = $host.ui.PromptForChoice($title, $message, $options, 0) 

    switch ($result)
      {
          0 {
              Write-Host "Selecting Disk $number ($friendlyname) for `"Windows To Go`" creation.`n"
              $Disks = $Disks + $CurrentDisk
          }
          1 {
              Write-Host "Skipping Disk $number ($friendlyname.)`n"
          }
          2 {
              Write-Host "Exiting the function. No changes were made to the USB storage drives or host computer."
              return
          }

      }
  }


  #Check to see if our new array of user selected disks is empty. If it is, tell the user they didn't select anything and exit the function.
  if ($Disks.count -eq 0)
  {
      Write-Warning "No USB drives were selected for `"Windows To Go`" creation."
      Write-Host "`nExiting the function. No changes made to USB drives or the host computer."
      return
  }
}

# Currently the provisioning function needs drive letters (for dism and bcdboot.exe) and the function is more
# reliable when the main process determines all of the free drives and provides them to the sub-processes.
# Use a drive index starting at 1, since we need 2 free drives to proceed. (system & operating system)
$driveLetters =    68..90 | ForEach-Object { "$([char]$_):" } |
Where-Object {(new-object System.IO.DriveInfo $_).DriveType -eq 'noRootdirectory'}

#Find the maximum number of drives we can create based on the number of available drive letters.
#This code rounds down when the division has a remainder (because you can't create a half drive, that would be silly.)
[decimal]$MaxDisks = $driveLetters.Length/2
$MaxDisks=[math]::floor($MaxDisks)
$CountOfDisks = $Disks.Count

#Check to see if we have enough drive letters to image the number if disks the user selected. If not, throw a warning and exit.
if ($MaxDisks -lt $CountOfDisks){
  Write-Warning "Preparing to create $CountOfDisks disk(s), but you only have enough drive letters to create $MaxDisks disks. The function can't proceed."
  Write-Verbose "You need to select fewer disks, or free drive letters by ejecting other disks attached to the computer. If the drive(s) you want to use currently have drive letters assigned to their partitions (which means you can navigate to them in Windows Explorer and see their files,) a good first step is to remove those drive letters. By default, `"Windows To Go`" drives do not have drive letters assigned when they are plugged into a computer anyway, and this function will remove drive letters when a drive is successfully created."
  Write-Verbose "To learn how to remove drive letters, visit http://windows.microsoft.com/en-us/windows/change-add-remove-drive-letter#1TC=windows-vista"
  Write-Host "`nExiting the function."
  return
}

#If we have enough drive letters, we have everything we need. Give the user some feedback about what we're about to do, and what they could do.
Write-Host "Preparing to create $CountOfDisks drive(s) in parallel."
Write-Host "NOTE: Up to $MaxDisks drives could be created with the drive letters available.`n"

#Time stamping process start. We'll display elapsed time to user at the end.
$starttime = get-date

#Create a SAN policy file. We'll clean this up at the end.
Write-Host "Generating SAN Policy file to ensure internal drives found by `"Windows to Go`" are not visible.`n"
$SanPolicyFile = CreateSANPolicyFile -Arch $Arch

#Get final unattended installation XML file path. If the XML file is created, flag this so we can delete the auto-generated file at the end of the process.
if ($ValidUnattendPath){
  #If you have a valid XML file supplied to the function, use that for the unattend file.
  $UnattendFile=$UnattendPath
  $GenerateUnattendFile = $false
}  
else{
  #If the unattend XML file path was not supplied, generate a default unattended installation XML file."
  Write-Host "Generating default unattended installation file to uninstall Windows Recovery Environment.`n"
  $UnattendFile = CreateUnattendFile -Arch $Arch
  $GenerateUnattendFile = $true
}

#Disable AutoPlay for the duration of the imaging process. Otherwise, windows explorer windows will pop-up all over the place as drive letters are assigned.
Write-Host "Disabling AutoPlay for removable and fixed drives to prevent Windows Explorer pop-ups.`n"
$AutoPlayPath ='HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer'
Set-ItemProperty $AutoPlayPath -Name NoDriveTypeAutoRun -Type DWord -Value 0xc

#We're ready to start creating "Windows To Go" drives. Let's let the user know.
if ($NoPrompts){
  Write-Host "Creating `"Windows To Go`" on compatible drive(s). This will take a while. You should get some coffee...`n"
}
else{
  Write-Host "Creating `"Windows To Go`" on user selected drive(s). This will take a while. You should get some coffee...`n"
}

#Initialize drive index.
$driveIndex = 1

#Spawn a process to create a "Windows To Go" drive for each disk the user selected.
foreach ($Disk in $Disks)
{
  #Get info on the disk to make a friendly job name.
  $FriendlyName = $Disk.FriendlyName
  $DiskNumber = $Disk.Number

  #Make sure you have enough drive letters before you start a job process.
  if ( $driveIndex  -lt $driveLetters.count ){
    Start-Job -Name "Creating `"Windows To Go`" on Disk $DiskNumber ($FriendlyName)" -ScriptBlock {
      #Initialize variables from arguments supplied to the job.
      $installWIMPath = $args[0]
      $UnattendFile = $args[1]
      $SanPolicyFile = $args[2]
      $Drivers = $args[3]
      $Disk = $args[4]
      $SystemDriveLetter = $args[5]
      $OSDriveLetter = $args[6]
      $ValidDriversPath = $args[7]
      $Index = $args[8]
      $SystemPartitionSize = $args[9]

      #Get info about the disk currently being created.
      $FriendlyName = $Disk.FriendlyName
      $DiskNumber = $Disk.Number

      write-host "`n======================================================================="
      Write-Host "Started creating `"Windows To Go`" for Disk $DiskNumber ($FriendlyName)."
            
      #Insurance policy against access collisions. Stagger start of jobs by imposing sleep. Stagger by 5 seconds.
      #Disk numbers are probably sequential, starting at 1, and we can only image 11 drives at max, so this will never make a delay more than 1 minute.
      Start-Sleep -Seconds ($DiskNumber * 5)

      #We want to make sure that all selected USB drives are online, writeable and cleaned. This command will erase all data from all selected USB Drives.
      Clear-Disk –InputObject $Disk -RemoveData -confirm:$False
      If (!$?){
        Write-Warning "Unable to clear disk."
        Write-Verbose "Confirm that the disk is online and writeable."
        Write-Host "Exiting the job."
        return
      }
      else{
        Write-Host "Erased all data from the USB drive."
      }

      #For compatibility between UEFI and legacy BIOS we use MBR for the disk partition style.
      Initialize-Disk –InputObject $Disk -PartitionStyle MBR

      #Create and format a new system partition.
      #A short sleep between creating a new partition and formatting helps ensure the partition is ready before formatting.
      $SystemPartition = New-Partition –InputObject $Disk -Size ($SystemPartitionSize) -IsActive
      Sleep 1
      Format-Volume -Partition $SystemPartition -FileSystem FAT32 -NewFileSystemLabel "WTG-SYSTEM" -confirm:$False | Out-Null


      #Create and format a new OS partition.
      #A short sleep between creating a new partition and formatting helps ensure the partition is ready before formatting.
      $OSPartition = New-Partition –InputObject $Disk -UseMaximumSize
      Sleep 1
      Format-Volume -NewFileSystemLabel "Windows To Go" -FileSystem NTFS -Partition $OSPartition -confirm:$False | Out-Null
      
      #Errors are unlikely if we were able to clear the disk, but let's check and see if any occurred during partitioning, formatting, and drive letter assignment.
      If (!$?){
        Write-Warning "Partition structure creation was unsuccessful."
        Write-Host "Exiting the job."
        return
      }
      else{
        write-host "Created `"Windows To Go`" partition structure."
      }

      #The "NoDefaultDriveLetter" prevents other computers from displaying contents of the drive when connected as a Data drive.    
      Set-Partition -InputObject $OSPartition -NoDefaultDriveLetter $TRUE
      Set-Partition -InputObject $SystemPartition -NewDriveLetter $SystemDriveLetter 
      Set-Partition -InputObject $OSPartition -NewDriveLetter $OSDriveLetter 
            
      write-host "Drive letters $SystemDriveLetter and $OSDriveLetter assigned for imaging and bcdboot operations."

      #Apply the specified image to the OS partition and store the log file into a unique file to prevent conflicts.
      Expand-WindowsImage –imagepath "$InstallWIMPath" –index $Index –ApplyPath "${OSDriveLetter}`:\" -Verify -CheckIntegrity -LogPath .\Log-disk_$($DiskNumber).log | Out-Null
      if (!$?){
        write-warning "Imaging was not successful. Check the log file for details."
                
        #Remove the drive letters now that we're finished with them. This will also close any explorer windows that opened.
        Get-Volume -Drive $SystemDriveLetter | Get-Partition | Remove-PartitionAccessPath -accesspath "$SystemDriveLetter`:\"
        Get-Volume -Drive $OSDriveLetter | Get-Partition | Remove-PartitionAccessPath -accesspath "$OSDriveLetter`:\"
        Write-Host "Drive Letters $SystemDriveLetter and $OSDriveLetter have been freed."
                
        write-host "`nExiting the job."
        return
      }
      else{
        Write-Host "Image applied successfully."
      }

      #Insert the unattended installation XML file. If one already exists (probably from SYSPREP,) throw a warning showing that the existing file will be used anyway.
      if (Test-Path ${OSDriveLetter}:\Windows\Panther\unattend.xml){
        Write-Warning "Existing unattended installation XML file found in image at ${OSDriveLetter}:\Windows\Panther\unattend.xml."
        Write-Warning "This existing file will be used instead of the file inserted by this function."
        Write-Verbose "Remove the existing file from the image and run this function again, or remove the existing file from the final `"Windows To Go`" drive in order to use the inserted file instead."
      }
      copy $UnattendFile ${OSDriveLetter}:\Windows\System32\sysprep\unattend.xml
      Write-Host "Unattended installation XML file inserted into `"Windows To Go`" OS."

      #Apply the SAN Policy XML file.
      Use-WindowsUnattend -UnattendPath $SanPolicyFile –Path "${OSDriveLetter}:\" -LogPath .\Log-disk_$($DiskNumber).log | Out-Null
      if (!$?){
        write-warning "Failed to apply SAN Policy. Check the log file for details."
                
        #Remove the drive letters now that we're finished with them. This will also close any explorer windows that opened.
        Get-Volume -Drive $SystemDriveLetter | Get-Partition | Remove-PartitionAccessPath -accesspath "$SystemDriveLetter`:\"
        Get-Volume -Drive $OSDriveLetter | Get-Partition | Remove-PartitionAccessPath -accesspath "$OSDriveLetter`:\"
        Write-Host "Drive Letters $SystemDriveLetter and $OSDriveLetter have been freed."
                
        write-host "`nExiting the job."
        return
      }
      else{
        Write-Host "SAN Policy file applied to `"Windows To Go`" OS."
      }

      #Inject any user supplied drivers into "Windows To Go" OS.
      If ($ValidDriversPath){
        #If there are valid drivers supplied to the function, inject them into the `"Windows To Go`" OS. If it's just a single file, remove the -recurse flag.
        #Force the function to insert all drivers, even the ones that are unsigned.
        If (Test-Path $Drivers -PathType Leaf){
          Add-WindowsDriver –Path “${OSDriveLetter}:\” -Driver $Drivers -ForceUnsigned -LogPath .\Log-disk_$($DiskNumber).log | Out-Null
        }
        else{
          Add-WindowsDriver –Path “${OSDriveLetter}:\” -Driver $Drivers –Recurse -ForceUnsigned -LogPath .\Log-disk_$($DiskNumber).log | Out-Null
        }
        if (!$?){
          #If there was an error, let the user know that we don’t know exactly how many drivers were injected (if any.)
          write-warning "Driver injection resulted in errors. Can't confirm that all drivers were injected successfully. Check the log file for details."
        }
        else{
          Write-Host "Drivers injected into `"Windows To Go`" OS."
        }
      }

      #We're running bcdboot from the newly applied image so we know that the correct boot files for the architecture and operating system are used.
      #This will DEFINITLY fail if we try to run an amd64 bcdboot.exe on an x86 host machine (or vice versa.)
      cmd /c "$OSDriveLetter`:\Windows\system32\bcdboot $OSDriveLetter`:\Windows /f ALL /s $SystemDriveLetter`:"
      if (!$?){
        write-warning "BCDBOOT.exe failed. Make sure the host OS and image OS are the same architecture (x86 or amd64.)"

        #Remove the drive letters now that we're finished with them. This will also close any explorer windows that opened.
        Get-Volume -Drive $SystemDriveLetter | Get-Partition | Remove-PartitionAccessPath -accesspath "$SystemDriveLetter`:\"
        Get-Volume -Drive $OSDriveLetter | Get-Partition | Remove-PartitionAccessPath -accesspath "$OSDriveLetter`:\"
        Write-Host "Drive Letters $SystemDriveLetter and $OSDriveLetter have been freed."

        write-host "Exiting the Job. System partition population was not successful."
        return
      }

      #We're all done. Try to flush the cache for the OS drive to allow the user to remove the drive.
      try{
        Write-VolumeCache -DriveLetter ${OSDriveLetter}
        Write-Host "Disk $DiskNumber ($FriendlyName) is now ready to be removed."
      }
      
      #If the system doesn't support automatically flushing the cache, let the user know that they will need to safely remove the disk.      
      catch [System.Management.Automation.CommandNotFoundException]{
        write-warning "Flush Cache not supported on this host computer. Be sure to safely remove disk $DiskNumber ($FriendlyName.)"
      }
            
      #Remove the drive letters now that we're finished with them. This will also close any explorer windows that opened.
      Get-Volume -Drive $SystemDriveLetter | Get-Partition | Remove-PartitionAccessPath -accesspath "$SystemDriveLetter`:\"
      Get-Volume -Drive $OSDriveLetter | Get-Partition | Remove-PartitionAccessPath -accesspath "$OSDriveLetter`:\"
      Write-Host "Drive letters $SystemDriveLetter and $OSDriveLetter have been freed."

      write-host "Finished creating `"Windows To Go`" on Disk $DiskNumber ($FriendlyName)."
      write-host "=======================================================================`n"
    } -ArgumentList  @($installWIMPath, $UnattendFile, $SanPolicyFile, $Drivers, $disk, $driveLetters[$driveIndex-1][0], $driveLetters[$driveIndex][0], $ValidDriversPath, $Index, $SystemPartitionSize) | Out-Null
  }
  $driveIndex  = $driveIndex  + 2
}

#Wait for all threads to finish
get-job | wait-job | Out-Null
Write-Host "Creation process complete. Here is a transcript of operations for each drive."

#Print output from all threads
get-job | receive-job | Out-Null

#Delete the job objects
get-job | remove-job

#Re-enable AutoPlay now that function has completed.
$AutoPlayPath ='HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer'
Set-ItemProperty $AutoPlayPath -Name NoDriveTypeAutoRun -Type DWord -Value 0x0
Write-Host "Reverted to original AutoPlay settings for removable and fixed drives."

#Delete helper files.
del $SanPolicyFile
if ($GenerateUnattendFile){
  #Only delete the unattend file if it was automatically generated
  del $UnattendFile
}
Write-Host "`nDeleted remaining helper files."

#Time stamp when the process completed and display to the user total time for all drives to be created.
$finishtime = get-date
$elapsedTime = new-timespan $starttime $finishtime
write-output "`nCreation tasks completed in: $elapsedTime  (hh:mm:ss.000)"
write-output "`n`"Windows To Go`" creator completed successfully."
return
}

########################################################################
#
# Helper Functions
#
#Create a default unattend answer file to use if no file is supplied by the user.
Function CreateUnattendFile {
param (
    [parameter(Mandatory=$true)]
    #Archtecture of the image this answer file will be applied to.
    [string]
    $Arch
)
    #If the unattended file already exists in the function location. Delete it.
    if ( Test-Path "WTGUnattend.xml" ) {
      del .\WtgUnattend.xml
    }

    #Create a new unattend file to uninstall the Windows Recovery Environment in the image if it exists.
    $UnattendFile = New-Item "WtgUnattend.xml" -type File

    #Create the content for the new unattend file.
    $fileContent = @"
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
    <settings pass="oobeSystem">
        <component name="Microsoft-Windows-WinRE-RecoveryAgent" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <UninstallWindowsRE>true</UninstallWindowsRE>
        </component>
    </settings>
</unattend>
"@
    
    #Put the new content into the new unattend XML file.
    Set-Content $UnattendFile $fileContent

    #Return the file object
    $UnattendFile 
}
#
#Create a SAN Policy to ensure that the internal drive of the computer the Windows To Go drive is used with is not booted.
Function CreateSANPolicyFile {
param (
    [parameter(Mandatory=$true)]
    #Architecture of the image file the policy is being applied to.
    [string]
    $Arch
)
    #If the SAN Policy file already exists in the function location. Delete it.
    if ( Test-Path "san_policy.xml" ) {
      del .\san_policy.xml
    }

    #Create a new SAN Policy file.
    $SanPolicyFile = New-Item "san_policy.xml" -type File

    #Create the content for the new policy file.
    $fileContent = @"
<?xml version='1.0' encoding='utf-8' standalone='yes'?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
  <settings pass="offlineServicing">
   <component
        xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        language="neutral"
        name="Microsoft-Windows-PartitionManager"
        processorArchitecture="$Arch"
        publicKeyToken="31bf3856ad364e35"
        versionScope="nonSxS"
        >
      <SanPolicy>4</SanPolicy>
    </component>
 </settings>
</unattend>
"@
    
    #Put the new content into the new SAN Policy file.
    Set-Content $SanPolicyFile $fileContent

    #Return the file object
    $SanPolicyFile 
}
#
#
#
######################################################################## 
