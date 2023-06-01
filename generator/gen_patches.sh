#!/usr/bin/env bash

# Get cluster env and type
read -e -p "Cluster environment: " -i "${CLUSTER_ENV}" CLUSTER_ENV
read -e -p "Cluster type: " -i "${CLUSTER_TYPE}" CLUSTER_TYPE

export CLUSTER_ENV CLUSTER_TYPE

# Build ArgoCD from manifests
kustomize build ../applications/argocd | \
  yq '(select(.metadata.name == "in-cluster" and .metadata.labels."argocd.argoproj.io/secret-type" == "cluster")) |= (with(.metadata.labels; .env = strenv(CLUSTER_ENV) | .type = strenv(CLUSTER_TYPE)))' | \
  yq --null-input '{"cluster": {"inlineManifests": [{"name": "argocd","contents":load_str("/dev/stdin")}]}}' > patches/argocd.yaml

omnictl cluster template sync --file cluster_template.yaml
