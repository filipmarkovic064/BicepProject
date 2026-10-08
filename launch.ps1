New-AzResourceGroupDeployment `
  -ResourceGroupName az104-bicep-project-2 `
  -TemplateFile .\main.bicep `
  -TemplateParameterFile .\params\dev.parameters.json
