mkdir azure_bots
cd azure_bots

# Call the botbuilder which you can define the properties of the bot
yo botbuilder

# Set up some Resource Variables
cd C:\Users\student\azure_bots\my-chat-bot
$RandomSuffix = (Get-Random -Minimum -1000 -Maximum 9999) | Out-String | % { $_ -replace "`n", "" } | % { $_ -replace "-", "" }
$AccountId = (az account list -o tsv --query [0].id) | Out-String | % { $_ -replace "`n", "" }
Write-Output $AccountId

az account set --subscription $AccountId

$Password = "AtLeastSixteenCharacters0"

$AppId = (az ad app create --display-name "appReg$RandomSuffix" --password $Password --available-to-other-tenants -o tsv --query appId) | Out-String | % { $_ -replace "`n", "" }

$ResourceGroup = (az group list -o tsv --query [0].name) | Out-String | % { $_ -replace "`n", "" }
$Location = (az group list -o tsv --query [0].location) | Out-String | % { $_ -replace "`n", "" }
Write-Output $ResourceGroup
Write-Output $Location

# Greate the deployment group with the defined parameter
az group deployment create --resource-group "$ResourceGroup" --template-file ".\deploymentTemplates\template-with-preexisting-rg.json" --parameters appId="$AppId" appSecret="$Password" botId="caLabBot$RandomSuffix" newWebAppName="webApp$RandomSuffix" newAppServicePlanName="appPlan$RandomSuffix" appServicePlanLocation="$Location" --name "webApp$RandomSuffix"

# Setup the bot
az bot prepare-deploy --code-dir "." --lang Javascript

# Zip your bot folder at this point and rename the zip to package

# Send the the bot code to the deployment
az webapp deployment source config-zip --resource-group "$ResourceGroup" --name "webApp$RandomSuffix" --src .\package.zip