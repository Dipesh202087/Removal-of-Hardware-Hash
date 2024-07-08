# Import the CSV file
$devices = Import-Csv -Path "C:\Users\IK2496\Downloads\Remove_Test.csv"

# Function to get Autopilot device ID by serial number or hardware hash
function Get-AutopilotDeviceId {
    param (
        [string]$identifier,
        [string]$identifierType
    )

    $autopilotDevices = Get-AutopilotDevice
    if ($identifierType -eq "SerialNumber") {
        $autopilotDevice = $autopilotDevices | Where-Object { $_.SerialNumber -eq $identifier }
    } elseif ($identifierType -eq "HardwareHash") {
        $autopilotDevice = $autopilotDevices | Where-Object { $_.ZtdHardwareHash -eq $identifier }
    }
    return $autopilotDevice.ZtdId
}

# Function to delete Autopilot device by ID
function Remove-AutopilotDeviceById {
    param (
        [string]$autopilotDeviceId
    )

    Remove-AutopilotDevice -Id $autopilotDeviceId
}

# Iterate over each identifier in the CSV and delete the corresponding device
foreach ($device in $devices) {
    $identifier = if ($device.PSObject.Properties.Match('SerialNumber').Count -gt 0) { 
        $device.SerialNumber 
    } elseif ($device.PSObject.Properties.Match('HardwareHash').Count -gt 0) { 
        $device.HardwareHash 
    }

    $identifierType = if ($device.PSObject.Properties.Match('SerialNumber').Count -gt 0) { 
        "SerialNumber" 
    } elseif ($device.PSObject.Properties.Match('HardwareHash').Count -gt 0) { 
        "HardwareHash" 
    }

    $autopilotDeviceId = Get-AutopilotDeviceId -identifier $identifier -identifierType $identifierType
    if ($autopilotDeviceId) {
        Write-Output "Deleting Autopilot device with ${identifierType}: ${identifier}, Autopilot Device ID: ${autopilotDeviceId}"
        Remove-AutopilotDeviceById -autopilotDeviceId $autopilotDeviceId
    } else {
        Write-Output "Autopilot device with ${identifierType}: ${identifier} not found."
    }
}
