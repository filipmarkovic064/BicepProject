param location string
param baseName string
param vmSize string
param subnetId string
param count int = 1
param adminUsername string = 'linuxadmin'

//Using a .txt file because i dont have access to Azure Key Vault
@secure()
param adminPassword string = loadTextContent('admin_password.txt')


var indexes  = [for i in range(1, count): i]
var vmNames  = [for i in indexes: '${baseName}-${i}']
var nicNames = [for n in vmNames: replace(n, 'vm-', 'nic-')]

resource nics 'Microsoft.Network/networkInterfaces@2024-07-01' = [for (n, i) in nicNames: {
  name: n
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig-01'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: { id: subnetId }

        }
      }
    ]
  }
}]
resource vms 'Microsoft.Compute/virtualMachines@2024-07-01' = [for (vmName,i) in vmNames: {
  name: vmName
  location: location
  properties: {
    hardwareProfile: { vmSize: vmSize }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'ubuntu-24_04-lts'
        sku: 'server'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: { storageAccountType: 'Standard_LRS' }
      }
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
      linuxConfiguration: {
                disablePasswordAuthentication: false
      }
    }
    networkProfile: {
      networkInterfaces: [
        { id: nics[i].id }
      ]
    }
  }
}]
