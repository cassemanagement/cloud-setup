orgName="cassemanagement"
env="dev"

resourceGroupName="RG_CaseManagement"
location="uksouth"

cosmosDbName="$orgName-entities-$env"
entityDbName="entitydb"
entityGraphName="entitygraph"
partitionKeyPath="/name"

uiAppName="$orgName-ui-$env"
uiAppPlanName="${uiAppName}Plan"
# accepted values: B1, B2, B3, D1, F1, FREE, I1, I2, I3, P1V2, P1V3, P2V2, P2V3, P3V2, P3V3, PC2, PC3, PC4, S1, S2, S3, SHARED
uiAppPlanSize="P1V2"
dockerImageUri="jcassem/cassemanagement:latest"

# Resource Group
if az group exists --name $resourceGroupName
then
  echo $resourceGroupName already exists
else
  az group create \
    --name $resourceGroupName \
    --location $location
fi


# Cosmos DB
while $cosmosDbName != "" && az cosmosdb check-name-exists --name $cosmosDbName
do
echo "'${cosmosDbName}' is taken. Provide a new name (or blank to skip):"
read cosmosDbName
done

if [[ -z "$cosmosDbName" ]]
then
az cosmosdb create \
  --name $cosmosDbName \
  --resource-group $resourceGroupName \
  --capabilities EnableGremlin \
  --default-consistency-level Session \
  --locations regionName=$location \
  failoverPriority=0 isZoneRedundant=False

az cosmosdb gremlin graph create \
  --account-name $cosmosDbName \
  --resource-group $resourceGroupName \
  --database-name $entityDbName \
  --name $entityGraphName \
  --partition-key-path $partitionKeyPath
fi


# Case Management UI (to be moved to UI repo)
# az appservice plan create \
#   --name $uiAppPlanName \
#   --resource-group $resourceGroupName \
#   --location $location \
#   --is-linux \
#   --sku $uiAppPlanSize

# az webapp create \
#   --name $uiAppName \
#   --resource-group $resourceGroupName \
#   --plan $uiAppPlanName \
#   --deployment-container-image-name $dockerImageUri