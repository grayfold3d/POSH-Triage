<<<<<<< HEAD
# POSH-Triage
Tools for parsing Forensic images

# Start-ImageParsing.ps1
PowerShell script that automates the use of artifact parsing tool against mounted images and volume shadow copies.
    
The following tools are run where applicable to the image being processed:
Eric Zimmerman Tools (https://ericzimmerman.github.io/)
* JLECmd.exe 
* LEcmd.exe
* PEcmd.exe
* SBECmd.exe
* AppCompatParser.exe
* AmcacheParser.exe
* RecentFileCacheParser.exe
* WxTCmd.exe
* MFTECmd.exe
* Registry Explorer project file creation
* VSCMount.exe
Obsidian Forensics - Hindsight (https://github.com/obsidianforensics/hindsight)
* Hindsight.exe 
NirSoft BrowsingHistoryView (https://www.nirsoft.net/utils/browsing_history_view.html)
* BrowsingHistoryView.exe

## Requirements
* Eric Zimmerman tools should all be located in the same directory
* Script should be run from an administrator prompt
* Windows 10/PowerShell 5 or greater

The default location of tools can be set by modifying the lines below in Start-ImageParsing.ps1:
 <pre>
 [string]$toolPath = "C:\forensic program files\zimmerman", # Change to directory containing Zimmerman tools
 [string]$hindsightPath = "C:\forensic program files\Hindsight\hindsight.exe", # Change to location of Hindsight.exe
 [string]$nirsoftPath = "C:\forensic program files\Nirsoft", # Change to directory containing Nirsoft tools
</pre>

## Examples
Note that that intent of this example is to show that the path to the various tools can be specified using parameters.  The recommendation is to update the script so these parameters aren't needed.
<pre>
.\Start-ImageParsing.ps1 -imagePath D:\[root] -toolPath C:\Utilities\Zimmerman -hindsightPath c:\Utilities\Hindsight\Hindsight.exe -nirsoftPath c:\utilities\Nirsoft -outPath \\SERVER\Cases\2018-06-01_1520_Laptop1 
</pre>
Example using:
* -imagePath to specify the path to the mounted image
* -toolPath to specify the path to directory containing Eric Zimmerman tools
* -hindSightpath to specify path to Hindsight.exe
* -nirsoftPath to specify path to Nirsoft utlities 
* -outPath to specify location to save processed files

<pre>
.\Start-ImageParsing.ps1 -imagePath J: -outPath \\SERVER\Cases\2018-06-01_1520_Laptop1 -vsc
</pre>
Example using:
* -imagePath to specify the path to the mounted image
* -outPath to specify location to save processed files
* -vsc switch parameter to mount Volume Shadow Copies and parse each using tools in script

<pre>
.\Start-ImageParsing.ps1 -imagePath "\\SIFTWORKSTATION\mnt\shadow_mount\VSS1" -outPath G:\Cases
</pre>
Example using:
* -imagePath to specify mounted Volume Shadow Copy on SIFT Workstation
* -toolPath parameter is not specified and will therefore use the default location
* -outPath to specify location to save processed files


# To Do
* Provide ability to combine exported files into timeline
* Add functions for additional tools
* Combine and dedupe VSC output files 

# Known Issues and limtitations
* Arsenal Image Mounter - Unable to parse $MFT. Hindsight displays locked file message on some Volume Shadow Copies.
* FTK Imager - Unable to mount and parse Volume Shadow Copies. SBECmd.exe fails to process NTUSER.DAT files when hive is dirty. Hold SHIFT while script is executing to allow parsing of dirty hive 
* SIFT Workstation - Unable to mount/parse Volume Shadow copies and Shellbags

# Version History
0.5 
* Added functions to mount and parse Volume Shadow Copies
* Added functions for Hindsight.exe and BrowsingHistoryView.exe
* Added logic to detect image mounting source and provide alert of limitations of mount type
* Modified logging. Now includes Start-ImageParsing_Commands.log which includes command history and Start-ImageParsing_Detailed.log which includes all output streams
* Revisions to some commands to fix bugs and better support multiple image mounting methods
0.4
* Added function to create Registry Explorer project file containing SAM, SECURITY, SOFTWARE, SYSTEM hives and all NTUSER.DAT, USRClass.DAT hives on the image
0.3 
* Fixed AmcacheParser failure when hive was dirty and disk was mounted using FTK Imager
0.2 
* Added function to parse MFT using MTECmd.exe. Corrected issue with AMCacheParser. Refactored commands to support toolPath containing spaces
0.1 
* Initial release 
   
=======
# POSH-Triage
Tools for parsing Forensic images

# Start-ImageParsing.ps1
PowerShell script that automates the use of Eric Zimmerman's cmd line tools (https://ericzimmerman.github.io/) against a mounted forensic image.  A Registry Explorer project file is also created containing all user/system hives stored on the image.
The following tools are run where applicable to the image being processed:
* JLECmd.exe 
* LEcmd.exe
* PEcmd.exe
* SBECmd.exe
* AppCompatParser.exe
* AmcacheParser.exe
* RecentFileCacheParser.exe
* WxTCmd.exe
* MFTECmd.exe
* Registry Explorer project file creation

## Requirements
* All tools must be located in the same directory
* Script should be run from an administrator prompt
* PowerShell 3 or greater


## Examples
<pre>
.\Start-ImageParsing.ps1 -imagePath D:\[root] -toolPath C:\Utilities\Zimmerman -outPath \\SERVER\Cases\2018-06-01_1520_Laptop
</pre>
Example using:
 * -imagePath to specify the path to the mounted image
 * -toolPath to specify the path to directory containing tools 
 * -outPath to specify location to save processed files
<pre>
.\Start-ImageParsing.ps1 -imagePath "\\SIFTWORKSTATION\mnt\shadow_mount\VSS1" -outPath G:\Cases
</pre>
Example using:
* -imagePath to specify mounted Volume Shadow Copy on SIFT Workstation
* -toolPath parameter is not specified and will therefore use the default location
* -outPath to specify location to save processed files

The default location of tools can be set by modifying the line below in Start-ImageParsing.ps1:
 <pre>
 [string]$toolPath = "C:\forensic program files\zimmerman", # Change to directory containing tools
</pre>

# To Do
* Provide ability to combine exported files into timeline
* Automatic parsing of additional artifacts using additional tools

# Known Issues
* SBECmd fails to process NTUSER.DAT files when hive is dirty and disk is mounted using FTK Imager. This occurs due to a capitalization difference between hive and transaction log names.
* $MFT is file is not accessible and able to be parsed when image is mounted using Arsenal Image Mounter.

# Version History
* 0.4 - Added function to create Registry Explorer project file containing SAM, SECURITY, SOFTWARE, SYSTEM hives and all NTUSER.DAT, USRClass.DAT hives on the image
* 0.3 - Fixed AmcacheParser failure when hive was dirty and disk was mounted using FTK Imager
* 0.2 - Added function to parse MFT using MTECmd.exe. Corrected issue with AMCacheParser. Refactored commands to support toolPath containing spaces
* 0.1 - Initial release 
   
>>>>>>> e0f719d16192451f1546d7bbfa034ebfa4082805
