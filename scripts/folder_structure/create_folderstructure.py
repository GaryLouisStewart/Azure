#!/usr/env/bin python3
# generates a directory structure, originally developed to generate a terraform module directory.
# Author: Gary Louis Stewart: Gary-Stewart@outlook.com

import argparse
import os
from unittest import result
import yaml
import sys

path = os.getcwd()

parser = argparse.ArgumentParser()
parser.add_argument(
    '-p', help='the name of your project, used to create the root folder')


def touch_files(files: list, path: str) -> None:
    for i in files:
        full_path = path + '/' + i
        if os.path.exists(full_path):
            os.utime(full_path, None)
        else:
            open(full_path, 'a').close()


def create_folder_structure(root_folder_name: str, folder_names: list, file_names: list) -> None:

    root_folder_path = path + '/' + root_folder_name

    if os.path.isdir(root_folder_path) == True:
        print("root directory {0} already exists.".format(
            root_folder_path))

    else:
        print("Creating root folder: {0} on path {1}".format(
            root_folder_name, path))
        os.mkdir(root_folder_path, mode=755)

    for i in folder_names:

        full_path = root_folder_path + '/' + i

        print("Creating folder: {0}".format(full_path))
        os.mkdir(full_path)

        for j in file_names:
            file_path = full_path + '/' + j
            touch_files(file_path)


def read_yaml_file(yamlfile: str, key: str) -> result:

    with open(yamlfile, 'r') as stream:
        output = yaml.safe_load(stream)
        result = print(output['FolderStructure']['{0}'.format(key)])
    return result


def main(arg) -> None:
    option[arg]()


option = {
    '-p': create_folder_structure
}
