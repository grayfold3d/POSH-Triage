# POSH-Triage
Tools for parsing Forensic images

# Start-ImageParsing.ps1
PowerShell script that automates the use of Eric Zimmerman's cmd line tools (https://ericzimmerman.github.io/) against a mounted forensic image.
The following tools are run where applicable to the image being processed:
* JLECmd.exe 
* LEcmd.exe
* PEcmd.exe
* SBECmd.exe
* AppCompatParser.exe
* AmcacheParser.exe
* RecentFileCacheParser.exe
* WxTCmd.exe

## Requirements
* All tools must be located in the same directory
* Script should be run from an administrator prompt
* PowerShell 3 or greater

## Examples
<pre>
.\Start-TriageParsing.ps1 -imagePath D:\[root] -toolPath C:\Utilities\Zimmerman -outPath \\SERVER\Cases\2018-06-01_1520_Laptop
</pre>
Example using:
 * -imagePath to specify the path to the mounted image
 * -toolPath to specify the path to directory containing tools 
 * -outPath to specify location to save processed files
<pre>
.\Start-TriageParsing.ps1 -imagePath "\\SIFTWORKSTATION\mnt\shadow_mount\VSS1" -outPath G:\Cases
</pre>
Example using:
* -imagePath to specify mounted Volume Shadow Copy on SIFT Workstation
* -toolPath parameter is not specified and will therefore use the default location

The default location of tools can be set by modifying the line below in Start-TriageParsing.ps1:
 <pre>
 [string]$toolPath = "C:\forensic program files\zimmerman", # Change to directory containing tools
</pre>

# To Do
* Provide ability to combine exported files into timeline
* Automatic parsing of additional artifacts using additional tools
* Test functionality with PowerShell Core

# Version History
 0.1 - Initial release    
