param name string
param location string
param bastionPublicIpId string
param bastionSubnetId string

resource bastion 'Microsoft.Network/bastionHosts@2025-09-01' = {
  name: name
  location: location
  sku:{
    name: 'Standard'
  }
  properties:{
    disableCopyPaste: false
    enableTunneling: true // -> This enables native client support which allows you to connect to the VM using normal tools on the PC instead of using the Azure portal
    scaleUnits: 2
    ipConfigurations: [{
      name:'bastionIpConfig'
      properties: {
        publicIPAddress: {
          id: bastionPublicIpId
        }
        subnet: {
          id: bastionSubnetId
        }
      }
    }]
  }
}
