// ============================================================================
// Module: Network
// Deploys VNet with subnet-vms, and NSG with RDP rule attached to subnet
// ============================================================================

// ---- INPUTS ----
param location string
param vnetName string = 'vnet-lab'
param vnetAddressPrefix string = '10.0.0.0/16'
param subnetName string = 'subnet-vms'
param subnetAddressPrefix string = '10.0.1.0/24'
param nsgName string = 'nsg-vms'

// ---- NETWORK SECURITY GROUP ----
resource nsg 'Microsoft.Network/networkSecurityGroups@2021-05-01' = {
  name: nsgName
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

// ---- VIRTUAL NETWORK + SUBNET ----
resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [vnetAddressPrefix]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetAddressPrefix
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
    ]
  }
}

// ---- OUTPUTS ----
output vnetId string = vnet.id
output subnetId string = '${vnet.id}/subnets/${subnetName}'
output nsgId string = nsg.id
output vnetName string = vnet.name
