param lbName string
param location string

param subnetId string

param frontendName string = 'frontendInternalLB-01'
param backendName string = 'backendInternalLB-01'
param probePath string = '/'
param probeName string = 'healthProbe-http-80'
param ruleName string = 'loadBalancer-http-80'
//Since its an internal load balancer it wont allow communication with the outside internet
resource internalLoadBalancer 'Microsoft.Network/loadBalancers@2025-09-01' = {
  name: lbName
  location: location
  sku: {
    name: 'Standard'
  }
  properties:{

    frontendIPConfigurations:[{
      name: frontendName
      properties:{
        subnet: {id: subnetId }
        privateIPAllocationMethod: 'Dynamic'
      }
    }]

    backendAddressPools:[
      {
        name: backendName 
      }
    ]
//Probe checks if the backend pool is healthy by sending http requests because we setup IIS on our machines, so it can listen on port 80 and check for responses
    probes: [
      {
        name: probeName
        properties:{
          port: 80
          protocol: 'Http'
          requestPath: probePath
          intervalInSeconds: 5
          numberOfProbes: 2
        }
      }
    ]
//For LoadBalancerRules we first need to define the frontend, backend and probe configuration and then we setup actual rules
    loadBalancingRules:[
      {
        name: ruleName
        properties:{
          protocol: 'Tcp'
          frontendIPConfiguration:{
            id: resourceId('Microsoft.Network/LoadBalancers/frontendIPConfigurations', lbName, frontendName)
          }
          backendAddressPool:{
            id: resourceId('Microsoft.Network/LoadBalancers/backendAddressPools', lbName, backendName)
          }
          probe:{
            id: resourceId('Microsoft.Network/LoadBalancers/probes', lbName, probeName)
          }
  //Here we tell it if we get the frontend port 80 forward it to port 80 of the backend pool
          frontendPort: 80
          backendPort: 80
  //other config rules
          idleTimeoutInMinutes: 4
          enableTcpReset: true
          loadDistribution: 'Default'
          disableOutboundSnat: true
        }
      }
    ]
  }
}

output backendPoolId string = resourceId('Microsoft.Network/LoadBalancers/backendAddressPools', lbName, backendName)
