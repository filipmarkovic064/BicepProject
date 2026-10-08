param name string
param location string
param sku string = 'Standard'
param allocation string = 'Static'

resource bastionIp 'Microsoft.Network/publicIPAddresses@2025-09-01' = {
  name: name
  location: location
  sku: { name: sku}
  properties:{ publicIPAllocationMethod:allocation}
}

output ipId string = bastionIp.id
