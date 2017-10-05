<# AutoName.ps1
https://github.com/diablolot53/sccm-scripts
This script will automatically set a computer's name using a prefix and serial number.

v.0.10.0 - 10/05/2017
#>

#------------------------------------------------------------------------------------------------------------
#Parameters
Param (
	[string]$LaptopPrefix = "NBK",       #Sets the naming prefix for laptop computers
	[string]$DesktopPrefix = "DSK",      #Sets the naming prefix for desktop computers
	[string]$Separator = "-",            #Sets the separator character between the prefix and suffix for the computer name
	[switch]$Debug                       #Debug mode
)

#-------------------------------------------------------------
#Variables


#-------------------------------------------------------------
#Functions
Function GenerateComputerName{
	<#
	.Description
		Combines the provided prefix and suffix to generate a computer name. 
		It is then checked to verify it's under the 15 character limit.
	.Example
		ComputerName -Prefix "Lap" -Suffix $SerialNumber
	.Outputs
		[String] - The formatted computer name
	#>
	
	Param (
		[String]$Prefix,      #Prefix input
		[String]$Suffix       #Suffix input
	)
	
	$TempComputerName = $Prefix+$Separator+$Suffix 

	#Check the length
	If (($TempComputerName).Length -gt 15) {
		Return $TempComputerName.Substring(0,15)
	}
	Else {
		Return $TempComputerName
	}
}

Function SetSCCMVariable{
	<#
	.Description
		Sets the specified SCCM task sequence variable with the provided value
	.Example
		SetSCCMVariable -SMSVar OSDComputerName -SMSVarValue $ComputerName
	#>

	Param(
		[string]$SMSVar,         #Name of the SCCM task sequence variable
		[string]$SMSVarValue     #Value for the task sequence variable 
	)

	$tsenv = New-Object -ComObject Microsoft.SMS.TSEnvironment
	$tsenv.Value($SMSVar) = $SMSVarValue
}

#-------------------------------------------------------------
#Retrieve the computer's serial number
$SerialNumber = (Get-WmiObject -Class Win32_Bios).SerialNumber

#Determine if the computer is a desktop or a laptop
If ((Get-WmiObject -Class Win32_Battery).Count -gt 0){
	#Computer is a laptop
	$ComputerName = GenerateComputerName -Prefix $LaptopPrefix -Suffix $SerialNumber
}
Else{
	#Computer is a desktop
	$ComputerName = GenerateComputerName -Prefix $DesktopPrefix -Suffix $SerialNumber
}

#Return the results
If ($Debug -eq $True){
	Return $ComputerName
}
Else {
	SetSCCMVariable -SMSVar "OSDComputerName" -SMSVarValue $ComputerName
}