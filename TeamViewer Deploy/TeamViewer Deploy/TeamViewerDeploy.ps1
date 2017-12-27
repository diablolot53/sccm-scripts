<#
    TeamViewer Host Install Script
    Last Updated - 12/27/2017
    Author - Ken Maurer

    This script will install the TeamViewer host MSI application and then remove the icon from the Public desktop
#>

#Parameters
Param (
	[Parameter(Mandatory = $true)]
    [string]$MSI  #Path to the TeamViewer installation MSI file
)

#Functions
Function VerifyFile {
	<#
		Purpose
			Verify file is used to verify the file provided is available

		Return
			$True = The provided file was found
			$False = The provided file was not found
	#>
    Param (
        [string] $File   #Path of file to check
    )
	$Results = Test-Path -Path $File
    Return $Results
}

#Begin Script
#Verify the MSI file exists before attempting the installation
If (VerifyFile -File $MSI -eq $True){
	$Arguments = "/i $MSI /q"
	$Process = Start-Process -FilePath msiexec.exe -ArgumentList $Arguments -Wait -PassThru
	If ($Process.ExitCode -ne 0){
		#If the installation failed, display the error message and end the script
		Write-Host "Installation failed"
		Write-Verbose "Exit Code: $($Process.ExitCode)"
		Write-Verbose "Argument List: $Arguments"
		Write-Verbose "MSI File: $MSI"
		Exit 1
	}
}
Else {
	#If the file is not found display an error message and exit the script
	Write-Host "MSI Not Found"
	Write-Verbose "MSI File: $MSI"
	Exit 1
}

#Remove the Public User's desktop icon
$TeamViewerIcon = "C:\Users\Public\Desktop\TeamViewer * Host.lnk"
If (VerifyFile -File $TeamViewerIcon -eq $True){
	Remove-Item -Path $TeamViewerIcon
}