param name string
param location string
param addressPrefix array
param subnets array

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2025-09-01' = {
  name:name
  location: location 
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefix
    }
    subnets:[
      for s in subnets : {
        name: s.name
        properties: {
          addressPrefix: s.prefix
        }
      }
    ]
  }
}

//Did this so windowVm can easily get subnetId in main.bicep
output subnetIds array = [
  for s in subnets: {
    name: s.name
    id:resourceId('Microsoft.network/virtualnetworks/subnets', name, s.name)
  }
]

output vnetId string = virtualNetwork.id
