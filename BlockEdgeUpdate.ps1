param(
    [ValidateSet("Block","Unblock")][string]$EdgeUpdate,
    [switch]$CheckUpdateStatus
)

Function SetEdgeUpdate{
    param(
        [ValidateRange(0,1)][int]$BlockValue
    )

    #Create HKLM:\SOFTWARE\Microsoft\EdgeUpdate if key isn't found
    If ((Test-Path -Path HKLM:\SOFTWARE\Microsoft\EdgeUpdate) -eq $False){
        New-Item -Path HKLM:\SOFTWARE\Microsoft\EdgeUpdate | Out-Null
    }

    #Set the DoNotUpdateToEdgeWithChromium value
    If ($Null -eq (Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\EdgeUpdate).DoNotUpdateToEdgeWithChromium){
        New-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\EdgeUpdate -Name DoNotUpdateToEdgeWithChromium -PropertyType DWORD -Value $BlockValue | Out-Null
    }
    Else{
        Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\EdgeUpdate -Name DoNotUpdateToEdgeWithChromium -Value $BlockValue
    }
}

#--------------Script--------------
Switch ($EdgeUpdate){
    "Block"{
        SetEdgeUpdate -BlockValue 1
    }
    "Unblock"{
        SetEdgeUpdate -BlockValue 0
    }
}

If ($CheckUpdateStatus -eq $True){
    If ($Null -eq (Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\EdgeUpdate -ErrorAction Ignore).DoNotUpdateToEdgeWithChromium){
        $DoNotUpdateToEdgeWithChromium = 0
    }
    Else{
        $DoNotUpdateToEdgeWithChromium = (Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\EdgeUpdate).DoNotUpdateToEdgeWithChromium
    }

    Switch ($DoNotUpdateToEdgeWithChromium){
        0 {Write-Host "Edge Chromium automatic delivery is not blocked `n"}
        1 {Write-Host "Edge Chromium automatic delivery is blocked `n"}
    }
}