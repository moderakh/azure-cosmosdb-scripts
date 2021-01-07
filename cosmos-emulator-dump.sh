#!/bin/bash

set -e

EMULATOR_IP=localhost
EMULATOR_PORT=8081
DUMPEP_EMULATOR_CERT_PATH=/tmp/cosmos_emulator.cert
KEYSTORE_PASSWORD="changeit"

emulatorHost=$EMULATOR_IP
emulatorPort=$EMULATOR_PORT
keystorePassword=$KEYSTORE_PASSWORD

if [ ! -d "$JAVA_HOME" ]; then
  echo $JAVA_HOME does not exist
  exit 1 
fi


while (( "$#" )); do
  case "$1" in
    --password)
      keystorePassword="$2"
      #TODO validate that no other arg is set
      shift 2
      ;;
    --host|--emulatorHost)
      emulatorHost="$2"
      #TODO validate that no other arg is set
      shift 2
      ;;
    --port|--emulatorPort)
      emulatorPort="$2"
      #TODO validate that no other arg is set
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


certName="cosmos_emulator_$emulatorHost"

echo "Capturing cosmos emulator cert"
openssl s_client -connect ${emulatorHost}:${emulatorPort} </dev/null 2>/dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > $DUMPEP_EMULATOR_CERT_PATH
echo "Captured and dumped into $DUMPEP_EMULATOR_CERT_PATH"

# delete the cert if already exists
echo "Attemping to delete the cert $certName from keystore if already exists"
sudo $JAVA_HOME/bin/keytool -cacerts -delete -alias "$certName" -storepass $keystorePassword | echo "Cert $certName does not exit"

# import the cert
echo "Importing $certName to Java keystore"
sudo $JAVA_HOME/bin/keytool -cacerts -importcert -alias "$certName" -file $DUMPEP_EMULATOR_CERT_PATH -storepass $keystorePassword -noprompt

