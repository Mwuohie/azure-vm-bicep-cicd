// ============================================================================
// Main orchestrator
// Deploys network module, then compute module, wiring outputs to inputs
// ============================================================================

// ---- INPUTS ----
param location string = resourceGroup().location
param storageAccountName string = 'stlab${uniqueString(resourceGroup().id)}'
param adminUsername string = 'azureadminuser'
@secure()
param adminPassword string

// ---- STORAGE ACCOUNT (kept inline, one-off) ----
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccountName
  location: location
  sku: { name: 'Standard_LRS' }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
  }
}

// ---- NETWORK MODULE ----
module network 'modules/network.bicep' = {
  name: 'networkDeployment'
  params: {
    location: location
  }
}

// ---- COMPUTE MODULE ----
module compute 'modules/compute.bicep' = {
  name: 'computeDeployment'
  params: {
    location: location
    subnetId: network.outputs.subnetId
    adminUsername: adminUsername
    adminPassword: adminPassword
  }
}

// ---- OUTPUTS ----
output storageAccountName string = storageAccount.name
output vnetName string = network.outputs.vnetName
output vmName string = compute.outputs.vmName
output publicIpAddress string = compute.outputs.publicIpAddress
output rdpCommand string = 'mstsc /v:${compute.outputs.publicIpAddress}'
