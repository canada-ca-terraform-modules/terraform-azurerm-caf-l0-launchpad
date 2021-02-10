#!/bin/sh

set -e

# https://docs.microsoft.com/en-us/azure/storage/blobs/versioning-enable?tabs=azure-cli

az storage account blob-service-properties update --resource-group "${RESOURCE_GROUP_NAME}" --account-name "${STORAGEACCOUNT_NAME}" --enable-versioning

echo "Versionning was configured for '${STORAGEACCOUNT_NAME}'"