#!/bin/bash

set -e

if [ "$(whoami)" != "vagrant" ]; then
        echo "Script must be run as user: username"
        exit 255
fi
