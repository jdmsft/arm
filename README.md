# Azure Resource Manager assets by JDMSFT

Repo structure:

* **templates** host all my "module" ARM templates with parameter values embedded (for example purpose).
* **solutions** host all my "main deployment" ARM templates with associated parameters file refering to my "module" **templates** as linked template.

## Solutions

* [virtualNetworks](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fjdmsft%2Farm%2Fmain%2Fsolutions%2FvirtualNetworks%2Fazuredeploy.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Farm%2Fmain%2Fsolutions%2FvirtualNetworks%2FcreateUiDefinition.json)
* OPNsense *(not finished)*


To generate a Deploy to Azure link use : `'https://portal.azure.com/#create/Microsoft.Template/uri/'+$([uri]::EscapeDataString($url))` by replacing `$uri` by your uri.

## Addtional links

* [Implement CreateUiDefinition.json with private repository](https://techcommunity.microsoft.com/t5/azure-architecture-blog/creating-a-custom-and-secure-azure-portal-offering/ba-p/3038344)
* [Test you CreateUiDefinition.json directly from Azure Portal](https://learn.microsoft.com/en-us/azure/azure-resource-manager/managed-applications/test-createuidefinition)