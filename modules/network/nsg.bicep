param name string
param location string
param rules array
param attachements array

resource nsg 'Microsoft.Network/networkSecurityGroups@2025-09-01' = {
  name: name
  location: location
  properties: {
    securityRules: [
      for r in rules: r
    ]
  }
}

resource subnetAssoicate 'Microsoft.Network/virtualNetworks/subnets@2025-09-01' = [
  for a in attachements: {
      name: '${a.vnetName}/${a.subnetName}'
      properties: {
        addressPrefix: a.addressPrefix
        networkSecurityGroup: {
          id: nsg.id
        }
      }
    }
]
