// ============================================================================
// Bicep template: Windows VM with networking
// Progressive build - currently: storage account + VNet + subnet
// ============================================================================

param location string = resourceGroup().location
param storageAccountName string = 'stlab${uniqueString(resourceGroup().id)}'
param adminUsername string = 'azureadminuser'
@secure()
param adminPassword string


//=============STORAGE ACCOUNT=========================
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
  }
}

//=============VNET and SUBNET=========================
resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: 'vnet-lab'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: ['10.0.0.0/16']
    }
    subnets: [
      {
        name: 'subnet-vms'
        properties: {
          addressPrefix: '10.0.1.0/24'
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
    ]
  }
}

//============Network Security Group=========================
resource nsg 'Microsoft.Network/networkSecurityGroups@2021-05-01' = {
  name: 'nsg-vms'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowRDP'
        properties: {
          priority: 100
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '3389'
        }
      }
    ]
  }
}

//=========PUBLIC IP ADDRESS=========================
resource publicIp 'Microsoft.Network/publicIPAddresses@2021-05-01' = {
  name: 'pip-vm-lab'
  location: location
  properties: {
    publicIPAllocationMethod: 'Static'
  }
  sku: {
    name: 'Standard'
  }
}

//=========NETWORK INTERFACE=========================
resource nic 'Microsoft.Network/networkInterfaces@2021-05-01' = {
  name: 'nic-vm-lab'
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
            id: '${vnet.id}/subnets/subnet-vms'
          }
        }
      }
    ]
  }
}


//=========VIRTUAL MACHINE=========================
resource vm 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: 'vm-lab'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B1s'
    }
    osProfile: {
      computerName: 'vm-lab'
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

//=============OUTPUTS=========================
output storageAccountId string = storageAccount.id
output storageAccountName string = storageAccount.name
output vnetName string = vnet.name
output nsgName string = nsg.name
output publicIpAddress string = publicIp.properties.ipAddress
output nicName string = nic.name
output vmName string = vm.name
output rdpcommand string = 'mstsc /v:${publicIp.properties.ipAddress}'

