<#
.Synopsis
   Start-ImageParsing - automates the use of artifact extraction tools against
   mounted images
.DESCRIPTION
   Start-TriageParsing - automates the use of artifact extraction tools namely, those 
   created by Eric Zimmerman (https://ericzimmerman.github.io/) 
     
   The script can be edited to set the location of the tools on your system or they can
   be specified using the -toolPath parameter. Output of script will be set using the -outPath parameter.
   
   *** The following files are required for full functionality and must be in the same directory:
   jlecmd.exe, lecmd.exe, pecmd.exe, sbecmd.exe, AppCompatParser.exe, amcacheparser.exe, 
   RecentFileCacheParser.exe, WxTCmd.exe. 

       
.EXAMPLE
    Example using:
     -imagePath to specify the path to the mounted image
     -toolPath to specify the path to directory containing tools 
     -outPath to specify location to save processed files

   .\Start-TriageParsing.ps1 -imagePath D:\[root] -toolPath C:\Utilities\Zimmerman -outPath \\SERVER\Cases\2018-06-01_1520_Laptop1 
.EXAMPLE
   Example using:
    -imagepath to specify mounted Volume Shadow Copy on SIFT Workstation
    -toolpath parameter is not specified and will therefore use the default location

   .\Start-TriageParsing.ps1 -imagePath "\\SIFTWORKSTATION\mnt\shadow_mount\VSS1" -outPath G:\Cases\2018-06-01_1520_Laptop1\Processed
#>
param(
    [string]$imagePath,
    [string]$toolPath = "C:\forensic program files\zimmerman", # Change to directory containing tools
    [string]$outPath
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
        $jle = (Get-Item imagepath:\users\*\Appdata\Roaming\Microsoft\Windows\Recent).FullName 
        ForEach ($dir in $jle) {
            $userdir = (($dir -split "\\users\\")[1] -split "\\appdata")[0]
            $command = "& $toolPath\jlecmd.exe $($options[0]) ""$dir"" $($options[2]) $($options[3]) ""$outPath\$userdir"""
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
        $recent = (Get-Item imagePath:\users\*\Appdata\Roaming\Microsoft\Windows\Recent\).FullName
        ForEach ($dir in $recent) {
            $userdir = (($dir -split "\\users\\")[1] -split "\\appdata")[0]
            $command = "& $toolPath\lecmd.exe $($options[0]) ""$dir"" $($options[2])  $($options[3])  ""$outPath\$userdir"""
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
        $prefetch = (Get-Item imagePath:\Windows\Prefetch).FullName
        $command = "& $toolPath\pecmd.exe $($options[0])  ""$prefetch"" $($options[2]) $($options[3])  ""$outPath"""
        log $command
        try{
            iex $command
        }catch{
            log "##ERROR - $Error[0]"
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
    if(Test-Path $toolPath\sbecmd.exe){
        $registry = (Get-ChildItem imagepath:\users\*\* -Filter NTUSER.DAT).Directory
        foreach ($dir in $registry){
            $userdir = split-path $dir -leaf
            $command = "& $toolPath\SBECmd.exe $($options[0]) ""$dir"" $($options[3]) ""$outPath\$userdir"""
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
        log "SBECmd.exe not found. Shellbags will not be processed"
    }
}

#AppCompatCacheParser
function Start-AppCompatParser
{
    if(Test-Path $toolPath\AppCompatCacheParser.exe){
        $appCompatCache = (Get-Item imagePath:\Windows\System32\Config\SYSTEM).FullName
        $command = "& $toolPath\AppCompatCacheParser.exe $($options[1]) ""$appCompatCache"" $($options[3]) ""$outPath"""
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
        if(Test-Path imagePath:\Windows\AppCompat\Programs\AmCache.hve){                                               
            $amCache = (Get-Item imagePath:\Windows\AppCompat\Programs\AmCache.hve).FullName
            $command = "& $toolPath\AmcacheParser.exe $options[1] ""$amCache"" $options[3] ""$outPath""" 
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
        if(Test-Path imagePath:\Windows\AppCompat\Programs\recentfilecache.bcf){
            $recentFileCache = (Get-Item imagePath:\Windows\AppCompat\Programs\recentfilecache.bcf).FullName
            $command = "& $toolPath\RecentFileCacheParser.exe $($options[1]) ""$recentFileCache"" $($options[2])  $($options[3]) ""$outPath"""
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
                $command = "& $toolPath\WxTCmd.exe $($options[1])  ""$dir"" $($options[3])  ""$outPath\$userdir"""
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
        log "WxTCmd.exe not found. ActvitiesCache will not be processed."
    }
}

# Create PSDrive to fix issues caused by mounted images containing brackets in path
$imagepath = New-PSDrive -name imagepath -PSProvider FileSystem -Root $imagePath

# Set log output and create directory/file
$log = "$outPath\Start-Parse.log"
New-Item -path $outPath -ItemType Directory | Out-Null
New-Item -path $log -ItemType File | out-null

# Global cmd line argument array
$options = @('-d','-f','-q','--csv')

Start-JLECmd
Start-LECmd
Start-PECmd
Start-SBECmd
Start-AppCompatParser
Start-AmCacheParser
Start-RecentFileCache
Start-WxTCmd