#!/usr/bin/env bash
# setup core azure services needed in order to use terraform with Azure.
# author: Gary Louis Stewart, gary.stewart@outlook.com

date=$(date '+%Y-%m-%d-%H:%M:%S')
log_file="az-login-${date}.log"
output_file="az-arm-details-${date}.txt"
subscription_id=3
region="UkSouth"
terraform_resource_group="test-project-resources"
az_keyvault_name="test-project-${region}"

# login to azure
az login > "${log_file}"

# use jq to extract out the ID of the subscription we want to use.

subscription=$(cat "${log_file}" | jq -r --argjson index $subscription_id '.[$index].id')

# set subscription id
az account set --subscription "$subscription"

# create a service principal with the subscription_id from beforehand
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/${subscription}" > "${output_file}"

# create a new file containing each of the different variables that we can use for access to the azure console with Terrform

ARM_CLIENT_ID=$(cat "${output_file}" | jq .appId)
ARM_CLIENT_SECRET=$(cat "${output_file}" | jq .password)
ARM_SUBSCRIPTION_ID="${subscription}"
ARM_TENANT_ID=$(cat "${output_file}" | jq .tenant)

# create an azure resource group  for us to use with our terraform state

az group create --name "terraform-state" --location "${region}"

# create an azure key-vault to store our secrets

az keyvault create --name "${az_keyvault_name}" --resource-group "${terraform_resource_group}" --location "${region}"


# Add our secrets from above into the key-vault
# Write each one of our keys into the azure keyvault
function writeToAzKeyVault() {
    local msg="$1"
    shift
    local arr=("$@")
    local vault_name="${az_keyvault_name}"
    for i in "${arr[@]}";
        do
            # az keyvault secret set --vault-name "${vault_name}"
            # set the data value to a variable representing the values in the array.
            local secret_data=$(echo $i | awk '{split($0,a,";"); print a[1]}')
            local secret_name=$(echo $i | awk '{split($0,a,";"); print a[2]}')
            az keyvault secret set --vault-name "${vault_name}" --name "${secret_name}" --value "${secret_data}"
        done
}

# cleanup old files that have sensitive values inside them that were needed for this run.
function cleanupSensitiveFiles() {
    local msg="$1"
    shift
    local arr=("$@")

    for i in "${arr[@]}";
        do
            rm $i
        done
}

keyvault_secrets=(
    # Delimit these strings with ';' to provide two values to iterate over when writing the keys the az keyvault.
    # First value is the secret value, second value is the key name that corresponds to that secret.
    "${ARM_CLIENT_ID};ARM-CLIENT-ID"
    "${ARM_CLIENT_SECRET};ARM-CLIENT-SECRET"
    "${ARM_SUBSCRIPTION_ID};ARM-SUBSCRIPTION-ID"
    "${ARM_TENANT_ID};ARM-TENANT-ID"
)

files_to_clean=(
    "${output_file}"
    "${log_file}"
)

# to debug these commands below please remove the '&> /dev/null' redirection from the end of the lines
# done like this to avoid spilling information to the stdoutput stream
writeToAzKeyVault "Writing keys to keyvault..." "${keyvault_secrets[@]}" &> /dev/null
cleanupSensitiveFiles "Cleaning up files...." "${files_to_clean[@]}" &> /dev/null
