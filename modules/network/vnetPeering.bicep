param localVnetName string
param localVnetId string

@description('Remote vnet name in the same RG/Subscription')
param remoteVnetName string
param remoteVnetId string

resource localToRemote 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2025-09-01' = {
  name: '${localVnetName}/peer-${localVnetName}-to-${remoteVnetName}'
  properties:{
    remoteVirtualNetwork: {id: remoteVnetId }
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
    allowVirtualNetworkAccess: true
  }
}

resource remoteToLocal 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2025-09-01' = {
  name: '${remoteVnetName}/peer-${remoteVnetName}-to-${localVnetName}'
  properties:{
    remoteVirtualNetwork: {id: localVnetId }
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
    allowVirtualNetworkAccess: true
  }
}
