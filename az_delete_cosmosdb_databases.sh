#!/bin/bash
# Mohammad Derakhshani
# requirement: azure cli  https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-macos?view=azure-cli-latest

set -e

if [ -z "$1" ]; then
  export CURL_CA_BUNDLE=""
  opts="--url-connection https://10.37.129.3:8081 --key C2y6yDjf5/R+ob0N8A7Cgv30VRDJIWEHLM+4QDU5DE2nQ9nDuVTqobD4b8mGGyPMbIZnqyMsEcaGQy67XIw/Jw=="
else
  resource_group=moderakh-java-sdk
  subscription="CosmosDB-SDK-Dev"
  accountName="$1"

  public_ip=`curl ifconfig.me` > /dev/null
  opts="-a $accountName -g $resource_group"
  az account set --subscription "$subscription"
fi


#az network nsg rule update  -g cleanupservice --nsg-name rg-cleanupservice-nsg -n Cleanuptool-Allow-100 --add sourceAddressPrefixes $public_ip
#az network nsg rule update --subscription "$subscription" -g cleanupservice --nsg-name rg-cleanupservice-nsg2 -n Cleanuptool-Allow-100 --add sourceAddressPrefixes $public_ip
#az network nsg rule update --subscription "Cosmos DB eFun Prototype" -g cleanupservice --nsg-name rg-cleanupservice-nsg3 -n Cleanuptool-Allow-100 --add sourceAddressPrefixes $public_ip
#az network nsg rule update --subscription "Cosmos DB eFun Prototype" -g cleanupservice --nsg-name rg-cleanupservice-nsg4 -n Cleanuptool-Allow-100 --add sourceAddressPrefixes $public_ip


db_cnt=`az cosmosdb database list $opts -o table 2>/dev/null | tail -n +3 | wc -l | sed -e 's/^[[:space:]]*//'`

echo "Found $db_cnt databases."

if [ "$db_cnt" -eq 0 ]; then
  echo "Finished!"
  exit 0
fi

 
echo "Deleting $db_cnt databases..."
#az cosmosdb database list $opts -o table 2>/dev/null | tail -n +3 | cut -d' ' -f1 
az cosmosdb database list $opts -o table 2>/dev/null | tail -n +3 | cut -d' ' -f1 | xargs -I '{}' az cosmosdb database delete $opts -d '{}' --yes 2>/dev/null 

if [ $? -ne 0 ]
then
  echo "Failed to delete the databases!"
  #az cosmosdb database list $opts 
else
  echo "Done!"
fi 

