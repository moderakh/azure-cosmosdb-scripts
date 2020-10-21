# azure-cosmosdb-scripts
This repo contains helpful scripts which are useful when developing against Azure Cosmos DB Service.

# Delete all databases in dev cosmos db account or emulator:

`az_delete_cosmosdb_databases.sh` can be used to delete all databases in a dev cosmos db account or emaultor.

## Requirements:
1. bash
2. azure-cli (https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)


## How to Run:

### Delete databases on emulator:

```bash
bash ~/bin/az_delete_cosmosdb_databases.sh
```

This assumes emulator is accessable on "https://10.37.129.3:8081". 10.37.129.3 is the default IP when emulator runs inside Parallels VM on MacOS. If you have emulator accessible on a different IP, replace the IP in the script.

### Delete databases in Azure Cosmos DB cloud:


