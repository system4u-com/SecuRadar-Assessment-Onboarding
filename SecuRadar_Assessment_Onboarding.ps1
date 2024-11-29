# Load configuration variables from properties file
$configuration = ConvertFrom-StringData (Get-Content ./properties.conf -raw)

# Check, if all variables are filled in the configuration file.
try {
  foreach ($key in $configuration.Keys) {
    if ('' -eq $configuration.$key) {
      throw "Variable $($key) is empty. All variables in configuration file are mandatory!"
    }
  }
}
catch {
  write-Error $_ -ErrorAction Stop
}

# Setup required variables before running the script
$tenantId = $configuration.'tenantId'
$subscriptionId = $configuration.'subscriptionId'
$location = $configuration.'location'
$customerShortcut = ($configuration.'customerShortcut').ToLower()
$logAnalyticsWorkspaceSku = "pergb2018"

# Connect to Azure in the customer's tenant
Write-Host "Checking Az module presence, this can take few minutes..."
if (-not (Get-Module Az -ListAvailable)) {
  Write-Host "Installing Az Module for current user"
  Install-Module -Name Az -Repository PSGallery -Force -Scope CurrentUser
}
Write-Host "Connecting to Az account..."
Connect-AzAccount -TenantId $tenantId -Subscription $subscriptionId

# Enable Microsoft.SecurityInsights resource provider
Write-Host "Registering Resource provider - Microsoft.SecurityInsights, Microsoft.OperationsManagement, Microsoft.Insights"
Register-AzResourceProvider -ProviderNamespace Microsoft.SecurityInsights
Register-AzResourceProvider -ProviderNamespace Microsoft.OperationsManagement
Register-AzResourceProvider -ProviderNamespace microsoft.insights
  
# Connect subscription to Azure Lighthouse
Write-Host "Connecting to Lighthouse..."
New-AzSubscriptionDeployment -Name "System4u-SecuRadar" -Location $Location -TemplateFile './templates/Lighthouse/template-subscription.json' -TemplateParameterFile './templates/Lighthouse/template-subscription-assessment.parameters.json' -Verbose

# Create new resource group
Write-Host "Creating resource group..."
$resourceGroup = New-AzResourceGroup -Name "rg-prod-securadar-$($customerShortcut)" -Location $Location

# Create log analytics workspace
Write-Host "Creating Log Analytics workspace..."
$workspace = New-AzOperationalInsightsWorkspace -ResourceGroupName $resourceGroup.ResourceGroupName -Name "law-prod-securadar-$($customerShortcut)" -Location $Location -Sku $logAnalyticsWorkspaceSku

# Run Sentinel in the Analytics workspace
Write-Host "Creating Sentinel on top of the Log Analytics workspace..."
New-AzSentinelOnboardingState -Name "default" -ResourceGroupName $resourceGroup.ResourceGroupName -WorkspaceName $workspace.Name

# Enable UEBA and Anomalies in sentinel
Write-Host "Enabling UEBA and Anomalies in Sentinel"
Update-AzSentinelSetting -ResourceGroupName $resourceGroup.ResourceGroupName -WorkspaceName $workspace.Name -SettingsName "EntityAnalytics" -Enabled $true
Update-AzSentinelSetting -ResourceGroupName $resourceGroup.ResourceGroupName -WorkspaceName $workspace.Name -SettingsName "Anomalies" -Enabled $true


# Print data for deployment evidence in System4u
Write-Host "===== DATA FOR SYSTEM4U =====" -BackgroundColor Yellow -ForegroundColor Black
Write-Host "Tenant ID: $($tenantId)" -ForegroundColor Yellow
Write-Host "Subscription ID: $($subscriptionId)" -ForegroundColor Yellow
Write-Host "Resource Group Name: $($resourceGroup.ResourceGroupName)" -ForegroundColor Yellow
Write-Host "Workspace ID: $($workspace.CustomerId)" -ForegroundColor Yellow
Write-Host "Workspace Name: $($workspace.Name)" -ForegroundColor Yellow
Write-Host "===============================" -BackgroundColor Yellow -ForegroundColor Black
Disconnect-AzAccount
