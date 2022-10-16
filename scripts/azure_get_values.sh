#!/usr/bin/env bash
# retrieve secrets from the azure-keyvault instance
# change the region and keyvault name depending on what you have setup on azure, for use with terraform
# author: Gary Louis Stewart, gary.stewart@outlook.com

region="UkSouth"
az_keyvault_name="test-keyvault-${region}"
date=$(date '+%Y-%m-%d-%H:%M:%S')

function get_keyvault_value() {
    # get a value from azure key-vault
    local msg="$1"
    shift
    local arr=("$@")

    for i in "${arr[@]}";
        do
            local secret_name=$i
            local secret_query=$(az keyvault secret show --name "${secret_name}" --vault-name "${az_keyvault_name}" --query value | tr -d '"\')
            local new_secret_name=$(echo $i | tr '-' '_')
            echo "writing secret $new_secret_name to: .azure-creds.sh"
            echo -e export $new_secret_name="$secret_query" >> .azure-creds.sh
        done
}

keyvault_secrets=(
    "ARM-CLIENT-ID"
    "ARM-CLIENT-SECRET"
    "ARM-SUBSCRIPTION-ID"
    "ARM-TENANT-ID"
)

get_keyvault_value "setting up terraform secrets for local use" "${keyvault_secrets[@]}"
