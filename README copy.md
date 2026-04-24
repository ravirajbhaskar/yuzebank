# Yuze Banking Infrastructure

Terraform infrastructure-as-code for Yuze Banking production environment on Azure.

## 📋 Overview

This repository contains modular Terraform configurations for deploying the complete Yuze Banking infrastructure on Azure, including:

- **Identity & Governance:** Key Vault, Managed Identities, Service Bus
- **Network:** VNet, NSG, Application Gateway (WAF), NAT Gateway, DNS
- **Database:** SQL Database, Storage Accounts, Redis Cache, Event Hub
- **Monitoring:** Log Analytics, Application Insights, Alerts
- **Compute:** AKS, Azure Container Registry, Function Apps

## 🚀 Getting Started

### Prerequisites

1. **Terraform:** v1.13.4 or later
2. **Azure CLI:** Latest version
3. **Azure Subscription:** Production subscription access
4. **Service Principal:** With Contributor and Key Vault Administrator roles

### Azure DevOps Pipeline Setup

**👉 See [AZURE_DEVOPS_SETUP.md](./AZURE_DEVOPS_SETUP.md) for complete pipeline configuration guide**

Key steps:
1. Configure variable group `Yuze_28-Jul` with Azure credentials
2. Create environment `env-yuze-banking-prod-cin` with approval checks
3. Set up service connection `sp-ado-tf-yuze-prod-cin`
4. Create pipeline from `azurepipeline.yaml`

### Automated SSH Key Management

**AKS SSH keys are fully automated in the CI/CD pipeline:**

#### How It Works:
1. **Stage 4:** After Key Vault is deployed, pipeline automatically:
   - Generates 4096-bit RSA SSH key pair (if not already in Key Vault)
   - Stores both keys as **Key Vault secrets**:
     - `aks-ssh-private-key` (for SSH access to nodes)
     - `aks-ssh-public-key` (for AKS deployment)
   - Exports public key to pipeline variable
2. **Stage 6:** Terraform uses the public key from pipeline variable to deploy AKS cluster

#### Benefits:
- ✅ **Fully Automated:** No manual SSH key generation required
- ✅ **Idempotent:** If keys exist in Key Vault, reuses them (no regeneration)
- ✅ **Secure Storage:** Keys stored as Key Vault secrets, not in git or pipeline variables
- ✅ **Team Access:** Team members can retrieve private key from Key Vault for node access
- ✅ **Consistent:** Same key reused across all pipeline runs

#### Retrieve SSH Key for Node Access:
```bash
# Get private key from Key Vault
az keyvault secret show \
  --vault-name "kv-yuze-prod-cin-xxxxx" \
  --name "aks-ssh-private-key" \
  --query "value" -o tsv > aks-private-key.pem

# Set permissions
chmod 600 aks-private-key.pem

# SSH to AKS node
ssh -i aks-private-key.pem azureuser@<node-ip>
```

**⚠️ No action required - SSH keys are automatically generated and stored in Key Vault!**

# Build and Test
TODO: Describe and show how to build your code and run the tests. 

# Contribute
TODO: Explain how other users and developers can contribute to make your code better. 

If you want to learn more about creating good readme files then refer the following [guidelines](https://docs.microsoft.com/en-us/azure/devops/repos/git/create-a-readme?view=azure-devops). You can also seek inspiration from the below readme files:
- [ASP.NET Core](https://github.com/aspnet/Home)
- [Visual Studio Code](https://github.com/Microsoft/vscode)
- [Chakra Core](https://github.com/Microsoft/ChakraCore)