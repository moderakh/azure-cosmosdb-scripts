#!/bin/bash
# author: Mohammad Derakhshani <moderakh>
# version: 0.9
# NOTE: this will delete all the databases and containers in your cosmos db account
# if you don't provide any option it will target Cosmos Emualtor running on Parallels on Mac accessable on 10.37.129.3:8081
# usage when running against emulator:
#   bash az_delete_cosmosdb_databases.sh
# usage when running against prod acocunt
#   bash az_delete_cosmosdb_databases.sh -g YOUR_RESOURCE_GROUP -n YOUR_COSMOSDB_ACCOUNT_NAME -s YOUR_SUB_NAME
set -e

if [ -z "$1" ]; then
  export CURL_CA_BUNDLE=""
  opts="--url-connection https://10.37.129.3:8081 --key C2y6yDjf5/R+ob0N8A7Cgv30VRDJIWEHLM+4QDU5DE2nQ9nDuVTqobD4b8mGGyPMbIZnqyMsEcaGQy67XIw/Jw=="
else

  while (( "$#" )); do
    case "$1" in
      -g|--resourceGroup)
        resource_group="$2"
        shift 2
        ;;
      -n|--accountName)
        accountName="$2"
        shift 2
        ;;
      -s|--subscription)
        subscription="$2"
        shift 2
        ;;
      -*|--*=) # unsupported flags
        echo "Error: Unsupported flag $1" >&2
        exit 1
        ;;
      *) # preserve positional arguments
        PARAMS="$PARAMS $1"
        shift
        ;;
    esac
  done

  public_ip=`curl ifconfig.me` > /dev/null
  opts="-n $accountName -g $resource_group"
  if [ -n "$subscription" ]; then
    az account set --subscription "$subscription"
  fi
fi

db_cnt=`az cosmosdb database list $opts -o table 2>/dev/null | tail -n +3 | wc -l | sed -e 's/^[[:space:]]*//'`

echo "Found $db_cnt databases."

if [ "$db_cnt" -eq 0 ]; then
  echo "Finished!"
  exit 0
fi

 
echo "Deleting $db_cnt databases..."
az cosmosdb database list $opts -o table 2>/dev/null | tail -n +3 | cut -d' ' -f1 | xargs -I '{}' az cosmosdb database delete $opts -d '{}' --yes 2>/dev/null 

if [ $? -ne 0 ]
then
  echo "Failed to delete the databases!"
  #az cosmosdb database list $opts 
else
  echo "Done!"
fi 

