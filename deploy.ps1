<#
.SYNOPSIS
  Deploys project resources for a VNET, Internally Load-balanced App Services Environment, App Gateway and Api Management Gateway. 
 
.DESCRIPTION
  Define parameters inline and run to deploy
 
.PARAMETER vnetRG
  Define the Resource Group to deploy the vnet

.PARAMETER aseRG
  Define the Resource Group to deploy the ASE

.PARAMETER subscriptionName
  Define the name or ID of the subscription to deploy into

.PARAMETER deploymentRegion
  Define the Azure Region to deploy the resources to
 
.INPUTS
  No Inputs
 
.OUTPUTS
  No Outputs. 
 
.NOTES
  Version:        0.1
  Author:         Jordan Smith - Microsoft Corporation
  Creation Date:  03.01.2018
  Purpose/Change: Initial script development

  
.EXAMPLE
  script.ps1 -vnetRG <string> -aseRG <string> -subscriptionName <string> -deploymentRegion <string>
#>

param(
    $vnetRG,
    $aseRG,
    $subscriptionName,
    $deploymentRegion
)

function login {
  param(
    $subscriptionName
  )
  login-azurermaccount
  Set-AzureRmContext -subscription $subscriptionName
}

function check-subscription {
  param(
    $subscriptionName
  )
  $sub = Get-AzureRmContext
   if ($sub.SubcriptionName -eq $null)
    {
      login $subscriptionName
    }
  elseif ($sub.SubcriptionName -ne $subscriptionName)
    {
      Set-AzureRmContext -subscription $subscriptionName
    }
}

function deploy-vnet {
  param(
   $vnetRG,
   $deploymentRegion
  )

 New-AzureRmResourceGroup -Name $vnetRG -location $deploymentRegion

 New-AzureRmResourceGroupDeployment -Name vnet-deployment -ResourceGroupName $vnetRG -TemplateFile ./vnet/vnet.json -TemplateParameterFile ./vnet/vnet.parameters.json

}

function deploy-ase {
  param(
    $aseRG,
    $deploymentRegion
  )

  New-AzureRmResourceGroup -Name $aseRG -location $deploymentRegion

  New-AzureRmResourceGroupDeployment -Name ase-deployment -ResourceGroupName $vnetRG -TemplateFile ./ase/ase-template.json -TemplateParameterFile ./ase/ase.parameters.json

}

check-subscription $subscriptionName

deploy-vnet $vnetRG $deploymentRegion

deploy-ase $aseRG $deploymentRegion
