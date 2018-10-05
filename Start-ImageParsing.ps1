<#
.Synopsis
   Start-ImageParsing - automates the use of artifact extraction tools against
   mounted images
.DESCRIPTION
   Start-ImageParsing - automates the use of artifact parsing tool against mounted images and volume shadow copies
    Eric Zimmerman Tools (https://ericzimmerman.github.io/).
    Obsidian Forensics Hindsight (https://github.com/obsidianforensics/hindsight)
    NirSoft BrowsingHistoryView (https://www.nirsoft.net/utils/browsing_history_view.html)    
   
   *** The following files are required for full functionality.
   jlecmd.exe, lecmd.exe, pecmd.exe, sbecmd.exe, AppCompatParser.exe, amcacheparser.exe, 
   RecentFileCacheParser.exe, WxTCmd.exe, MFTeCmd.exe, VSCMount.exe, Hindsight.exe, BrowsingHistoryView.exe. 
   Eric Zimmerman tools should all be saved in the same directory. 

   The script can be edited to set the location of the tools on your system or they can
   be specified using the -toolPath, -hindsightPath and -nirsoftPath parameters. Output of script will be set using the -outPath parameter.
   The -vsc switch parameter should be used to parse Volume Shadow Copies.

   Image Mounting limitations: The following limitations should be epected

   - Arsenal Image Mounter - Unable to parse $MFT
   - FTK Imager - Unable to mount and parse Volume Shadow Copies.
   - SIFT Workstation - Unable to mount/parse Volume Shadow copies and Shellbags
       
.EXAMPLE
    Example using:
     -imagePath to specify the path to the mounted image
     -toolPath to specify the path to directory containing Eric Zimmerman tools
     -hindSightpath to specify path to Hindsight.exe
     -nirsoftPath to specify path to Nirsoft utlities 
     -outPath to specify location to save processed files

   .\Start-ImageParsing.ps1 -imagePath D:\[root] -toolPath C:\Utilities\Zimmerman -hindsightPath c:\Utilities\Hindsight\Hindsight.exe -nirsoftPath c:\utilities\Nirsoft -outPath \\SERVER\Cases\2018-06-01_1520_Laptop1 
.EXAMPLE
    Example using:
     -imagePath to specify the path to the mounted image
     -toolPath to specify the path to directory containing tools 
     -outPath to specify location to save processed files
     -vsc switch parameter to mount Volume Shadow Copies and parse each using tools in script

   .\Start-ImageParsing.ps1 -imagePath J: -toolPath C:\Utilities\Zimmerman -outPath \\SERVER\Cases\2018-06-01_1520_Laptop1 -vsc
.EXAMPLE
   Example using:
    -imagepath to specify mounted Volume Shadow Copy on SIFT Workstation
    -toolpath parameter is not specified and will therefore use the default location
    -outPath to specify location to save processed files

   .\Start-ImageParsing.ps1 -imagePath "\\SIFTWORKSTATION\mnt\shadow_mount\VSS1" -outPath G:\Cases\2018-06-01_1520_Laptop1\Processed
#>
param(
    [string]$imagePath,
    [string]$toolPath = "C:\forensic program files\zimmerman", # Change to directory containing Zimmerman tools
    [string]$hindsightPath = "C:\forensic program files\Hindsight\hindsight.exe", # Change to location of Hindsight.exe
    [string]$nirsoftPath = "C:\forensic program files\Nirsoft", # Change to directory containing Nirsoft tools
    [string]$outPath,
    [switch]$vsc
)

function log ($text){
    $timestamp = Get-Date -Format 'yyyy-MM-dd hh:mm:ss'
    $output = "$timestamp $text"
    Write-Output $output >> $Log
}

#JLEcmd
function Start-JLEcmd
{
    if(Test-Path $toolpath\jlecmd.exe){
        $jle = (Get-Item imagepath:\users\*\Appdata\Roaming\Microsoft\Windows\Recent -Force).FullName 
        ForEach ($dir in $jle) {
            $userdir = (($dir -split "\\users\\")[1] -split "\\appdata")[0]
            $command = "& ""$toolPath\jlecmd.exe"" $($options[0]) ""$dir"" $($options[2]) $($options[3]) ""$outPath\$userdir"""
            log $command
            try{
                iex $command 
            }catch{
                log "##ERROR - $Error[0]"
            }
        }
    }
    else
    {
        log "JLECmd.exe not found. Jump lists will not be processed."
    }

}

#LECmd
function Start-LECmd
{
    if(Test-Path $toolpath\LECmd.exe){
        $recent = (Get-Item imagePath:\users\*\Appdata\Roaming\Microsoft\Windows\Recent\ -Force).FullName
        ForEach ($dir in $recent) {
            $userdir = (($dir -split "\\users\\")[1] -split "\\appdata")[0]
            $command = "& ""$toolPath\lecmd.exe"" $($options[0]) ""$dir"" $($options[2])  $($options[3])  ""$outPath\$userdir"""
            log $command
            try{
                iex $command
            }catch{
                log "##ERROR - $Error[0]"
            }
        }
    }
    else
    {
        log "LECmd.exe not found. Recent folder will not be processed."
    }
}   

#PECmd
function Start-PECmd
{
    if(Test-Path $toolPath\pecmd.exe){
        if(Test-Path imagePath:\Windows\Prefetch){
            $prefetch = (Get-Item imagePath:\Windows\Prefetch -Force).FullName
            $command = "& ""$toolPath\pecmd.exe"" $($options[0])  ""$prefetch"" $($options[2]) $($options[3])  ""$outPath"""
            log $command
            try{
                iex $command
            }catch{
                log "##ERROR - $Error[0]"
            }
        }
        else
        {
            log "No Prefetch folder present"
        }
    }
    else
    {
        log "PECmd.exe not found. Prefetch files will not be processed."
    }
}

#SBECmd
function Start-SBECmd
{
    if(Test-Path $toolPath\SBECmd.exe){
        $hivePath = (Get-Item imagepath:\users -Force).FullName
            $command = "& ""$toolPath\SBECmd.exe"" $($options[0]) ""$hivePath"" $($options[3]) ""$outPath"""
            log $command
            try{
                iex $command
            }catch{
                log "##ERROR - $Error[0]"
            }
    }
    else
    {
        log "SBECmd.exe not found. Shellbags will not be processed"
    }
}

#AppCompatCacheParser
function Start-AppCompatParser
{
    if(Test-Path $toolPath\AppCompatCacheParser.exe){
        $appCompatCache = (Get-Item imagePath:\Windows\System32\Config\SYSTEM -Force).FullName
        $command = "& ""$toolPath\AppCompatCacheParser.exe"" $($options[1]) ""$appCompatCache"" $($options[3]) ""$outPath"""
        log $command
        try{
            iex $command
        }catch{
            log "##ERROR - $Error[0]"
        }
    }
    else
    {
        log "AppCompatCacheParser.exe not found. AppCompatCache will not be processed."
    }
}

#amcache
function Start-AmCacheParser
{
    if(Test-Path $toolPath\AmcacheParser.exe){
        if(Test-Path imagePath:\Windows\appcompat\Programs\Amcache.hve){                                               
            $amCache = (Get-Item imagePath:\Windows\appcompat\Programs\Amcache.hve -Force).FullName
            $command = "& ""$toolPath\AmcacheParser.exe"" $($options[1]) ""$amCache"" $($options[3]) ""$outPath""" 
            log $command
            try{
                iex $command 
            }catch{
                log "##ERROR - $Error[0]"
            }
        }
        else
        { 
            log "AmCache.hve not found"
        }
    }
    else
    {
        log "AmcacheParser.exe not found. AmCache will not be processed"
    }
}

#recentfilecache
function Start-RecentFileCache
{
    if(Test-Path $toolPath\RecentFileCacheParser.exe){
        if(Test-Path imagePath:\Windows\appcompat\Programs\recentfilecache.bcf){
            $recentFileCache = (Get-Item imagePath:\Windows\appcompat\Programs\recentfilecache.bcf -Force).FullName
            $command = "& ""$toolPath\RecentFileCacheParser.exe"" $($options[1]) ""$recentFileCache"" $($options[2])  $($options[3]) ""$outPath"""
            log $command
            try{
                iex $command
            }catch{
                log "##ERROR - $Error[0]"
            }
        }
        else
        { 
            log "RecentFileCache.bcf not found"
        }
    }
    else
    {
        log "RecentFileCacheParser.exe not found. RecentFileCache.bcf will not be processed."
    }
}

#activitiescache
function Start-WxTCmd
{
    if(Test-Path $toolPath\WxTCmd.exe){
        if(Test-Path imagePath:\users\*\AppData\Local\ConnectedDevicesPlatform\*\ActivitiesCache.db){
            $activitiesCache = (Get-Item imagePath:\users\*\AppData\Local\ConnectedDevicesPlatform\*\ActivitiesCache.db).FullName 
            ForEach ($dir in $activitiesCache) {
                $userdir = (($dir -split "\\users\\")[1] -split "\\appdata")[0]
                $command = "& ""$toolPath\WxTCmd.exe"" $($options[1])  ""$dir"" $($options[3])  ""$outPath\$userdir"""
                log $command
                try{
                    iex $command 
                }catch{
                    log "##ERROR - $Error[0]"
                }
            }
        }
        else
        {
            log "ActivitiesCache.db not found or is not accessible"
        }
    }
    else
    {
        log "WxTCmd.exe not found. ActvitiesCache will not be processed."
    }
}

#MFTECmd
function Start-MFTECmd
{
    if(Test-Path $toolPath\MFTECmd.exe){
        try {
            $MFT = (Get-Item 'imagePath:\$MFT' -Force -ErrorAction Stop).FullName
            $command = "& ""$toolPath\MFTECmd.exe"" $($options[1]) '$MFT' $($options[3])  ""$outPath"""
            log $command
                try{
                    iex $command
                }catch{
                    log "##ERROR - $Error[0]"
                } 
        }catch{
            log "##Error - MFT not found or accessible"
        }
    }
    else
    {
        log "MFTECmd.exe not found. MFT will not be processed."
    }
}

#Registry Explorer Project File
function New-RegExpProj
{ 
   try {
        $reproj = "$outPath\regexplorer.re_proj"
        $systemHives = @('SAM','SYSTEM','SOFTWARE','SECURITY')
        $hives = @()
        $hives += (Get-ChildItem imagepath:\Windows\System32\Config\* -include $systemhives -ErrorAction Stop).FullName
        $hives += (Get-ChildItem imagepath:\users\*\* -Filter NTUSER.DAT -Hidden -ErrorAction Stop).FullName
        $hives += (Get-ChildItem imagepath:\users\*\AppData\Local\Microsoft\Windows\* -Filter UsrClass.dat -Hidden -ErrorAction Stop).FullName
        $hives = $hives | ForEach-Object {$_ -replace ("\\","\\")}
        $reprojBody = $hives -join ","
        "[$($reprojBody)]" | Out-File $reproj
        log "Exporting Registry Explorer Project File to $($reproj)"
    }catch{ 
        log "##Error - $Error[0]"
    }
}
# NirSoft Browsing History View
function Start-BrowsingHistoryView
{
    if(Test-Path $nirsoftpath\browsinghistoryview.exe){
        $userPath = Get-Item imagepath:\users
        $command = "& ""$nirsoftPath\browsinghistoryview.exe"" $($options[6]) $($options[7]) $($options[8]) ""$userPath"" $($options[9]) ""$outPath\BrowsingHistoryView_Output.csv"""
        log $command
        try{
            iex $command 
        }catch{
            log "##ERROR - $Error[0]"
        }
        
    }
    else
    {
        log "BrowsingHistoryView.exe not found. Browsing History will not be processed"
    }

}

#Hindsight Chrome Processing
function Start-Hindsight
{
    if(Test-Path $hindsightPath){
        if(Test-Path "imagepath:\users\*\AppData\Local\Google\Chrome\User Data\Default"){
            $chromePath = (Get-Item "imagepath:\users\*\AppData\Local\Google\Chrome\User Data\Default").FullName
            $hOptions = @('-i','-o','-b','-f','-t')
            ForEach ($dir in $chromePath) {
                $userdir = (($dir -split "\\users\\")[1] -split "\\appdata")[0]
                $command = "& ""$hindsightPath"" $($hoptions[0])  ""$dir"" $($hoptions[1])  ""$outPath\$userdir\chrome"""
                log $command
                try{
                    iex $command
                }catch{
                    log "##ERROR - $Error[0]"
                }
            }
        }
    }
    else
    {
        log "Hindsight.exe not found. Chrome data will not be processed."
    }
}

#VSCMount
function Start-VSCMount
{
    if(Test-Path $toolPath\VSCMount.exe){
            $command = "& ""$toolPath\VSCMount.exe"" $($options[4]) '$imagePath' $($options[5])  ""$outPath\Mounted_VSC"""
            log $command
                try{
                    iex $command
                }catch{
                    log "##ERROR - $Error[0]"
                }
    }
    else
    {
        log "VSCMount.exe not found. Volume Shadow Copy will not be processed."
    }
}

# Parse Volume Shadows
function Start-VSCParsing
{  
    # Storing original $outPath variable 
    $baseOutpath = $outPath
    # Get Mounted VSC folders
    $mountedVSC = Get-Item -Path $outPath\Mounted_VSC* | Get-ChildItem
    # Loop through Volume Shadow copies
    foreach($vsc in $mountedVSC){
        $vscPath = $vsc.FullName
        $vscName = $vsc.Name
       
        #Updating image imagePath and $outPath to point to VSC data
        Remove-PSDrive -Name imagePath 
        New-PSDrive -name imagepath -PSProvider FileSystem -Root $vscPath | Out-Null
        $outPath = "$baseOutpath\Processed_VSC\$vscName"

        #Create output folder for parsed VSC
        if(!(Test-Path $outPath)){
            New-Item -path $outPath -ItemType Directory | Out-Null
        }

        # Run processing tools on VSC data
        Write-Host "Parsing Volume Shadow Copies" -ForegroundColor Green

        Write-Host "Starting JLECmd.exe" -ForegroundColor Green
        Start-JLECmd 

        Write-Host "Starting LECmd.exe" -ForegroundColor Green
        Start-LECmd 

        Write-Host "Starting PECmd.exe" -ForegroundColor Green
        Start-PECmd 

        Write-Host "Starting AppCompatParser.exe" -ForegroundColor Green
        Start-AppCompatParser 

        Write-Host "Starting AmCacheParser.exe" -ForegroundColor Green
        Start-AmCacheParser 

        Write-Host "Starting SBECmd.exe" -ForegroundColor Green
        Start-SBECmd 

        Write-Host "Starting RecentFileCache.exe" -ForegroundColor Green
        Start-RecentFileCache 

        Write-Host "Starting WxTCmd.exe" -ForegroundColor Green
        Start-WxTCmd 

        Write-Host "Starting Registry Explorer Project file creation" -ForegroundColor Green
        New-RegExpProj 

        Write-Host "Starting BrowsingHistoryView.exe" -ForegroundColor Green
        Start-BrowsingHistoryView 

        Write-Host "Starting Hindsight.exe" -ForegroundColor Green
        Start-Hindsight 
        
    }
}

function Get-ImageMountSource
{
    # Check to verify imagepath is a disk and not mapped drive
    if ($imagepath.Substring(1,1) -eq ':') {
        $driveLetter = $imagepath.Substring(0,1)

        # Check if DiskID contains Arsenal
        if(Get-Partition -DriveLetter $driveLetter -ErrorAction SilentlyContinue | Where-Object {$_.DiskID -like '*Arsenal*'}) {
            $mountSource = 'arsenal'
            Write-Host '***Image mounted using Arsenal Image Mounter. $MFT is not able to be parsed.***' -ForegroundColor Red -BackgroundColor White
        }
        else
        {
            $mountsource = 'other'
            Write-Host '***Image was not mounted using Arsenal Image Mounter. Volume Shadow Copies cannot be mounted or parsed.***' -ForegroundColor Red -BackgroundColor White
        }
    }
    elseif ($iimagepath.Substring(0,2) -eq "\\") {
        Write-Host '***Image was not mounted using SMBShare. Volume Shadow Copies cannot be mounted or parsed. SBECmd.exe must be run manually against hives***' -ForegroundColor Red -BackgroundColor White
        $mountsource = "SMBShare"
    }
    Write-Output $mountSource
}

#### Main ####

# Verifying drives mounted with FTK include '[root]' in the $imagepath
if(Get-ChildItem $imagepath\ -filter '[root]'){
  $imagepath = $imagepath + '\[root]' 
}

# Create PSDrive to fix issues caused by mounted images containing brackets in path
try {
    New-PSDrive -name imagepath -PSProvider FileSystem -Root $imagePath -ErrorAction Stop | Out-Null
    } catch {
    Write-Host "Unable to create PSDrive. Verify your are running as administrator and have access to image" -ForegroundColor Red
    log "##ERROR - $Error[0]"
    break
}

# Set log output and create directory/file
$log = "$outPath\Start-ImageParsing_Commands.log"
$detailedLog = "$outpath\Start-ImageParsing_Detailed.log"
if(!(Test-Path $outPath)){
    New-Item -path $outPath -ItemType Directory | Out-Null
}
if(!(Test-Path $log)){
    New-Item -path $log -ItemType File | out-null
}

# Global cmd line argument array
$options = @('-d','-f','-q','--csv','--dl','--mp','/HistorySource','3','/HistorySourceFolder','/scomma')

$mountSource = Get-ImageMountSource
# Short pause to display mounting source and implications
Start-Sleep -Seconds 3

Write-Host "Starting JLECmd.exe" -ForegroundColor Green
Start-JLECmd *>&1 | tee -filePath $detailedLog -Append

Write-Host "Starting LECmd.exe" -ForegroundColor Green
Start-LECmd *>&1 | tee -filePath $detailedLog -Append

Write-Host "Starting PECmd.exe" -ForegroundColor Green
Start-PECmd *>&1 | tee -filePath $detailedLog -Append

Write-Host "Starting AppCompatParser.exe" -ForegroundColor Green
Start-AppCompatParser *>&1 | tee -filePath $detailedLog -Append

Write-Host "Starting AmCacheParser.exe" -ForegroundColor Green
Start-AmCacheParser *>&1 | tee -filePath $detailedLog -Append

Write-Host "Starting RecentFileCache.exe" -ForegroundColor Green
Start-RecentFileCache *>&1 | tee -filePath $detailedLog -Append

Write-Host "Starting WxTCmd.exe" -ForegroundColor Green
Start-WxTCmd *>&1 | tee -filePath $detailedLog -Append

Write-Host "Starting Registry Explorer Project file creation" -ForegroundColor Green
New-RegExpProj *>&1 | tee -filePath $detailedLog -Append

Write-Host "Starting BrowsingHistoryView.exe" -ForegroundColor Green
Start-BrowsingHistoryView *>&1 | tee -filePath $detailedLog -Append

Write-Host "Starting Hindsight.exe" -ForegroundColor Green
Start-Hindsight *>&1 | tee -filePath $detailedLog -Append

# Checking image mounting source and to exclude actions source isn't able to process
if ($mountSource -eq 'arsenal'){
    # Perfoming Volume Shadow Mount/Parse if mount source is Arsenal and -VSC switch was provided
    if($vsc){
        Write-Host "Starting VSCMount.exe" -ForegroundColor Green
        Start-VSCMount *>&1 | tee -filePath $detailedLog -Append

        Write-Host "Starting SBECmd.exe" -ForegroundColor Green
        Start-SBECmd *>&1 | tee -filePath $detailedLog -Append
        
        Write-Host "Parsing Volume Shadow Copies" -ForegroundColor Green
        Start-VSCParsing *>&1 | tee -filePath $detailedLog -Append
    }
}
elseif ($mountSource -eq "Other"){
    Write-Host "Starting SBECmd.exe" -ForegroundColor Green
    Start-SBECmd *>&1 | tee -filePath $detailedLog -Append
    #Parsing $MFT if mount source is not Arsenal
    Write-Host "Starting MFTECmd.exe" -ForegroundColor Green
    Start-MFTECmd *>&1 | tee -filePath $detailedLog -Append    
}
else
{  
    #Parsing $MFT if mount source is not Arsenal
    Write-Host "Starting MFTECmd.exe" -ForegroundColor Green
    Start-MFTECmd *>&1 | tee -filePath $detailedLog -Append
}