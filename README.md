# Azure VM Deployment with Bicep and GitHub Actions

Azure Windows VM deployment using Bicep templates and GitHub Actions CI/CD 
with OIDC federation.

## Architecture
- Windows Server 2022 VM (Standard_B1s)
- VNet with subnet
- NSG restricting inbound to RDP
- Public IP for external access
- Deployed via modular Bicep templates

## CI/CD
- GitHub Actions triggered on push to main
- OIDC federation to Azure (no stored credentials)
- Validates then deploys the Bicep template

## Modules
- `modules/network.bicep` — VNet, subnet, NSG
- `modules/compute.bicep` — Public IP, NIC, VM

## Prerequisites
- Azure subscription
- GitHub repo secrets: AZURE_CLIENT_ID, AZURE_TENANT_ID, AZURE_SUBSCRIPTION_ID, VM_ADMIN_PASSWORD
