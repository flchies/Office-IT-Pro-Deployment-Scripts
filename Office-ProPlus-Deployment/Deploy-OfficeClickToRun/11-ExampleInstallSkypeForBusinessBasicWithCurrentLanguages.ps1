#  Office ProPlus Click-To-Run Deployment Script example
#
#  This script demonstrates how utilize the scripts in OfficeDev/Office-IT-Pro-Deployment-Scripts repository together to create
#  Office ProPlus Click-To-Run deployment script that will Convert existing 32-Bit Click-To-Run installs to 64-bit with the same 
#  Products and Languages that are currently installed

Process {
 $scriptPath = "."

 if ($PSScriptRoot) {
   $scriptPath = $PSScriptRoot
 } else {
   $scriptPath = (Get-Item -Path ".\").FullName
 }
 
 $productsToRemove = ("O365ProPlusRetail",
          "O365BusinessRetail",
          "VisioProRetail",
          "ProjectProRetail",
          "SPDRetail",
          "VisioProXVolume",
          "VisioStdXVolume",
          "ProjectProXVolume",
          "ProjectStdXVolume",
          "InfoPathRetail");

#Importing all required functions - These files must be in the same directory as this script
. $scriptPath\Generate-ODTConfigurationXML.ps1
. $scriptPath\Install-OfficeClickToRun.ps1
. $scriptPath\Remove-PreviousOfficeInstalls.ps1
. $scriptPath\Remove-OfficeClickToRun.ps1
. $scriptPath\SharedFunctions.ps1
. $scriptPath\Edit-OfficeConfigurationFile.ps1

$targetFilePath = "$env:temp\configuration.xml"

$SourcePath = $scriptPath
if((Validate-UpdateSource -UpdateSource $SourcePath) -eq $false) {
    $SourcePath = $NULL    
}

#This example will detect the current install of Office that is currently installed. If the current install of Office Click-To-Run 32-bit it will
#then generate a Configuration XML based on the current configuration It will then remove the Version attribute from the XML to ensure the installation gets the latest version
#and change the configuration XML to 64-Bit.  It will remove the existing install of Office Click-To-Run and resinstall Office Click-To-Run with the 64-Bit version




    Generate-ODTConfigurationXml -Languages CurrentOfficeLanguages -TargetFilePath $targetFilePath | Out-Null

    $LanguagesToAdd = Get-LanguagesFromXML -TargetFilePath $targetFilePath
    
    try{
    foreach($prod in $productsToRemove){#remove all products
    Remove-ODTProductToAdd -ProductId $prod -TargetFilePath $targetFilePath | Out-Null
    }
    } catch{}
    
    Add-ODTProductToAdd -LanguageIds $LanguagesToAdd -TargetFilePath $targetFilePath -ProductId SkypeforBusinessEntryRetail | Out-Null
    
    Install-OfficeClickToRun -TargetFilePath $targetFilePath

 



# Configuration.xml file for Click-to-Run for Office 365 products reference. https://technet.microsoft.com/en-us/library/JJ219426.aspx
}