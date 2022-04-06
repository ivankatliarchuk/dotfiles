#!/bin/bash

[[ -n "${DEBUG:-}" ]] && set -x

# Install plugins with krew
# https://krew.sigs.k8s.io/

kubectl krew install neat
kubectl krew install deprecations
