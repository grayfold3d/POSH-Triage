<#
.Synopsis
   Get-ZimmermanTools.ps1 - automates download and extraction of Eric Zimmerman tools
.DESCRIPTION
   Get-ZimmermanTools.ps1 - automates download and extraction of Eric Zimmerman tools
   Tools are downloaded to location defined in -outDir parameter and extracted from
   zip files. Zip files are removed after all tools are 
    
.EXAMPLE

   .\Get-ZimmermanTools.ps1 -imagePath D:\[root] -outDir c:\Utilities\Zimmerman 

#>

param(
    [string]$outDir = 'C:\Forensic Program Files\Zimmerman'
)

function Get-ZimmermanTools
{
    $baseURI = 'https://f001.backblazeb2.com/file/EricZimmermanTools/'
    $filenames = @('AmcacheParser.zip',
                   'AppCompatCacheParser.zip',
                   'bstrings.zip',
                   'hasher.zip',
                   'JLECmd.zip',
                   'JumpListExplorer.zip',
                   'LECmd.zip',
                   'MFTECmd.zip',
                   'PECmd.zip',
                   'RecentFileCacheParser.zip',
                   'RegistryExplorer_RECmd.zip',
                   'RBCmd.zip',
                   'SDBExplorer.zip',
                   'ShellBagsExplorer.zip',
                   'TimelineExplorer.zip',
                   'VSCMount.zip',
                   'WxTCmd.zip'
                   )

    ### Testing for $outDir path and creating if it does not exist ###
    If(!(Test-Path "$outDir")) {
        New-Item -Path "$outDir" -ItemType Directory | Out-Null
    }

    # Forcing TLS 1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    # Loop over each file in $filename array
    foreach($file in $filenames){
        $url = "$baseURI/$file"
        $savePath = "$outDir\$file"
        # Download zip file
        Try
        {
            (New-Object System.Net.WebClient).DownloadFile($url, $savePath) 
        } 
        catch 
        {
            Write-Host "Download of $($file) failed. $($error[0])" -ForegroundColor Red
        }
        # Verify file exists 
        if(Test-Path $savePath){
            # Extract file from archive
            $error.clear()
            Try
            {
                Expand-Archive -Path $savePath -DestinationPath $outDir -Force
            } 
            Catch 
            {
                Write-Host "Unzipping archive failed. $($error[0])" -ForegroundColor Red     
            }
            if(!($error)){
                # Remove zip files
                Remove-Item -Path $savePath -Force
            }
            #Unblock Files
            Get-ChildItem $outDir -Recurse | Unblock-File
        }         
    } 
}

Write-Host "Downloading and Extracting Files. Please wait for script to complete." -ForegroundColor Green
Try
{
    Get-ZimmermanTools
} 
Catch 
{
   Write-Output "Download failed. ##Error: $($error[0])"
} 