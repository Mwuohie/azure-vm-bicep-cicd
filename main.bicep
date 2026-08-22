// ============================================================================
// Bicep template: Bare minimum starter
// Deploys a single storage account to verify the deployment pipeline works
// ============================================================================

param location string = resourceGroup().location
param storageAccountName string = 'stlab${uniqueString(resourceGroup().id)}'

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


output storageAccountId string = storageAccount.id
output storageAccountName string = storageAccount.name


