param vnet object
param location string
param nsg object
param StorageAccountName string
param windowsVM object
param publicIp object
param bastion object
param lbName string

param linuxWebConfig object
@secure()
param testvnet object
//secure()
//param adminPassword string

var attachments = [
  {
    vnetName: vnet.name
    subnetName: vnet.subnets[0].name
    addressPrefix: vnet.subnets[0].prefix
  }
  {
    vnetName: vnet.name
    subnetName: vnet.subnets[1].name
    addressPrefix: vnet.subnets[1].prefix
  }
  {
    vnetName: testvnet.name
    subnetName: testvnet.subnets[0].name
    addressPrefix: testvnet.subnets[0].prefix
  }
]

module winVM 'modules/compute/windowsVm.bicep' = {
  name: 'winVM'
  params: {
      loadbalancerBackendPoolId: internalLoadBalancerModule.outputs.backendPoolId
      location: location
      vmName: windowsVM.vmName
      nicName: windowsVM.nicName
      vmSize: windowsVM.vmSize
      count: windowsVM.count
      adminUsername: windowsVM.adminUsername
      subnetId: vnetModule.outputs.subnetIds[0].id
      scriptUri:windowsVM.scriptUri
  }
  dependsOn:[nsgModule]
}


module vnetModule 'modules/network/vnet.bicep' = {
  name: 'vnetModule' 
  params:{
    name : vnet.name
    location: location
    addressPrefix: vnet.addressPrefixes
    subnets: vnet.subnets
  }
}

module storageAccount 'modules/storageAccount/storageAccount.bicep' = {
  name: 'storageAccountModule'
  params: {
    name: StorageAccountName
    location: location
  }
}

module nsgModule 'modules/network/nsg.bicep' = {
  name: 'nsgModule'
  params: {
    location: location
    name: nsg.name
    rules: nsg.rules
    attachements: attachments
  } 
  dependsOn:[vnetModule]
}

module bastionIp 'modules/network/publicIp.bicep' = {
  name: 'bastionIp'
  params: {
    location: location
    name: publicIp.name
  }
}

module bastionHost 'modules/network/bastion.bicep' = {
  name: 'bastion'
  params: {
    name: bastion.name
    location: location
    bastionPublicIpId: bastionIp.outputs.ipId
    bastionSubnetId: vnetModule.outputs.subnetIds[2].id
  }
}

module internalLoadBalancerModule 'modules/network/loadBalancer.bicep' = {
name: 'internalLoadBalancer'
  params:{
    lbName: lbName
    location: location
    subnetId: vnetModule.outputs.subnetIds[0].id
  }
}

module linuxVm './modules/compute/linuxVm.bicep' = {
  name: 'mod-linux-web'
  params: {
    location: location
    baseName: linuxWebConfig.baseName
    vmSize: linuxWebConfig.vmSize
    subnetId: testnet.outputs.subnetIds[0].id
    count: linuxWebConfig.count
    adminUsername: linuxWebConfig.adminUsername
  }
  dependsOn: [nsgModule]
}

module testnet './modules/network/vnet.bicep' = {
  name: 'test-network'
  params: {
    name: testvnet.name
    location: location
    addressPrefix: testvnet.addressPrefixes
    subnets: testvnet.subnets
  }
}

module vnetPeering 'modules/network/vnetPeering.bicep' = {
  name: 'vnetPeering'
  params: {
    localVnetId: vnetModule.outputs.vnetId
    localVnetName: vnet.name
    remoteVnetId: testnet.outputs.vnetId
    remoteVnetName: testvnet.name
  }
}
