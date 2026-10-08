param location string
param name string


resource storageAcc 'Microsoft.Storage/storageAccounts@2026-04-01' = {
  name: name
  location: location
  kind: 'StorageV2'
  sku:{
    name: 'Standard_LRS'
  }
  properties: {
    minimumTlsVersion: 'TLS1_2' 
  }
}
