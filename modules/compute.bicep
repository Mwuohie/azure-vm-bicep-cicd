// ============================================================================
// Module: Compute
// Deploys Windows VM with public IP and NIC attached to the given subnet
// ============================================================================

// ---- INPUTS ----
param location string
param subnetId string
param vmName string = 'vm-lab'
param vmSize string = 'Standard_B1s'
param adminUsername string
@secure()
param adminPassword string
param publicIpName string = 'pip-vm-lab'
param nicName string = 'nic-vm-lab'

// ---- PUBLIC IP ----
resource publicIp 'Microsoft.Network/publicIPAddresses@2021-05-01' = {
  name: publicIpName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

// ---- NETWORK INTERFACE ----
resource nic 'Microsoft.Network/networkInterfaces@2021-05-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIp.id
          }
          subnet: {
            id: subnetId
          }
        }
      }
    ]
  }
}

// ---- VIRTUAL MACHINE ----
resource vm 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-Datacenter'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}

// ---- OUTPUTS ----
output vmName string = vm.name
output publicIpAddress string = publicIp.properties.ipAddress
output nicId string = nic.id
