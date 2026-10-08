@description('Id of the backendPool for the internal load balancer configuration - needs to be added to the NICs')
param loadbalancerBackendPoolId string

@description('Uri to the script file (SAS url from storage or raw Github URL)')
param scriptUri string
@description('Command to execute on the VM after the file is downloaded')
param scriptCommand string = 'powershell -ExecutionPolicy Bypass -File .\\setup-iis.ps1'

param location string
param vmName string
param nicName string
param subnetId string

param vmSize string
param adminUsername string = 'azureadmin'
//Using a .txt file because i dont have access to Azure Key Vault
@secure()
param adminPassword string = loadTextContent('admin_password.txt')

@description('How many VMs to create')
param count int

resource nic 'Microsoft.Network/networkInterfaces@2025-09-01' = [for i in range(1, count): {
  name: '${nicName}-${i}'
  location: location
  properties: {
    ipConfigurations: [
      {
        name:'ipconfig-01'
        properties: {
          privateIPAllocationMethod:'Dynamic'
          subnet: {id:subnetId}
          loadBalancerBackendAddressPools:[
            {id:loadbalancerBackendPoolId}
          ]
        }
      }
    ]
  }
}
]

resource windowsVm 'Microsoft.Compute/virtualMachines@2026-04-01' = [for i in range(1,count): {
  name: '${vmName}-${i}'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile:{
      computerName: '${vmName}-${i}'
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile:{
      imageReference:{
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2025-datacenter'
        version: 'latest'
      }
      osDisk:{
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
          }
      networkProfile: {
        networkInterfaces: [
          {
            id: nic[i-1].id
            properties: {
              primary: true
            }
          }
        ]
      }
  }
}]
//The VMs are connecting to the storage account and that way they are able to get the setup file from there, if we wanted to avoid the packets going over the internet we can setup "Azure Storage Service Endpoints"
//Also the setup file is in the storageAccount folder for referance
resource vmCustomScriptExtension 'Microsoft.Compute/virtualMachines/extensions@2026-04-01' = [
  for i in range(0,count): {
    name: 'cse-init-${i}'
    location:location
    parent: windowsVm[i]
    properties:{
      publisher:'Microsoft.Compute'
      type: 'CustomScriptExtension'
      typeHandlerVersion: '1.10'
      autoUpgradeMinorVersion: true
      settings:{
        fileUris: [
          scriptUri
        ]
      }
      protectedSettings:{
        commandToExecute: scriptCommand
      }
    }
  }
]
