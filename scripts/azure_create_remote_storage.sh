#!/usr/bin/env bash
# create the remote-storage setup for terraform to use.
# uses Standard_ZRS replication to replicate the storage data between three availability zone(s) within our region 'uksouth'

resource_group_name="test-project-resources"
location="uksouth"
name="testproject"
az_keyvault_name="${name}-${region}"
date=$(date '+%Y-%m-%d-%H:%M:%S')

## storage account vars ##
storage_account_sku="Standard_ZRS"
storage_account_name="${name}"
storage_container_name="${name}"

## end storage account vars ##

az storage account create --name "${storage_account_name}" --resource-group "${resource_group_name}" -l "${location}" --sku "${storage_account_sku}" --encryption-services blob
az storage container create --name "${storage_container_name}" --account-name "${storage_account_name}"
