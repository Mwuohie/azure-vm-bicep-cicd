// ============================================================================
// Bicep template: Windows VM with networking
// Progressive build - currently: storage account + VNet + subnet
// ============================================================================

param location string = resourceGroup().location
param storageAccountName string = 'stlab${uniqueString(resourceGroup().id)}'


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
        }
      }
    ]
  }
}


//=============OUTPUTS=========================
output storageAccountId string = storageAccount.id
output storageAccountName string = storageAccount.name
output vnetName string = vnet.name
