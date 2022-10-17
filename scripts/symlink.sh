#!/usr/bin/env bash
# generates a symbolic link back to our jinja2 template file
# Author: Gary Louis Stewart: Gary-Stewart@outlook.com

function gen_symlink() {
    ln -s $1 $2
}

gen_symlink $1 $2
