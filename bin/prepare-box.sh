#!/bin/bash
#!/bin/bash

set -x

box_name=macos
version=10.15.1-catalina

vagrant package --output ${box_name}.box
# vagrant cloud auth login
vagrant cloud publish cloudkats/${box_name} "${version}-$(date +%Y.%m.%d)" virtualbox ${box_name}.box --release
