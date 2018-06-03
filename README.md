# POSH-Triage
Tools for parsing Forensic images

# Start-ImageParsing.ps1
PowerShell script that automates the use of Eric Zimmerman's cmd line tools ((https://ericzimmerman.github.io/)) against a forensic image.
The following tools are run where applicable to the image being processed:
* JLECmd.exe 
* LEcmd.exe
* PEcmd.exe
* SBECmd.exe
* AppCompatParser.exe
* AmcacheParser.exe
* RecentFileCacheParser.exe
* WxTCmd.exe

	Example
	.\Start-TriageParsing.ps1 -imagePath D:\[root] -toolPath C:\Utilities\Zimmerman -outpath \\SERVER\Cases\2018-06-01_1520_Laptop

	 Example uses:
	 -imagePath to specify the path to the mounted image
     -toolPath to specify the path to directory containing tools 
     -outpath to specify location to save processed files

     Example
     .\Start-TriageParsing.ps1 -imagePath D:\[root] -outpath G:\Cases\2018-06-01_1520_Laptop1\Processed

     Example using default location of the -toolpath parameter which can be set by editing the following line in StartImageParsing.ps1
     [string]$toolPath = "C:\forensic program files\zimmerman", # Change to directory containing tools

# To Do
* Provide ability to combine exported files into timeline
* Automatic parsing of additional artifcats using additional tools

# Version History
 0.1 - Initial release    
