#!/usr/bin/env python3
# renders a terraform backend into a backend.tf file for use with microsoft azure.
# author: Gary Louis Stewart: Gary.Stewart@outlook.com

import os
from re import template
from jinja2 import Template
import yaml
from yaml.loader import SafeLoader


variable_file = input(
    "Please enter the name of the variable file you wish to use: \n")

path = os.getcwd()
file_path = "{0}".format(path + "/" + "backend.tf")
vars_file = "{0}".format(path + "/" + "vars" + "/" + variable_file + ".yaml")


def read_yaml_values(yamlfile=str, value=str):
    with open(yamlfile) as f:
        data = yaml.load(f, Loader=SafeLoader)

    yaml_value = data[value]
    return yaml_value


def render_terraform_backend(templatePath=str, resourceGroup=str, storageAccount=str, containerName=str, keyName=str):
    try:
        with open(templatePath) as file_:
            template = Template(file_.read())
            output = template.render(resource_group_name=resourceGroup,
                                     storage_account_name=storageAccount,
                                     container_name=containerName,
                                     key=keyName)

        with open(file_path, "w") as f:
            f.write(output)
    except FileNotFoundError:
        return


template_path = read_yaml_values(vars_file, "template_path")
resource_group = read_yaml_values(vars_file, "resource_group")
storage_account = read_yaml_values(vars_file, "storage_account")
container_name = read_yaml_values(vars_file, "container_name")
key = read_yaml_values(vars_file, "key")


if __name__ == "__main__":
    render_terraform_backend(
        template_path, resource_group, storage_account, container_name, key)
