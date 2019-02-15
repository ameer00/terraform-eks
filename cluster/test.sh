#!/bin/bash

node_status=$(kubectl get nodes | grep Ready | awk 'BEGIN { ORS="" }; { print $2}')
until [ $node_status = "ReadyReadyReadyReady" ]; do
    node_status=$(kubectl get nodes | grep Ready | awk 'BEGIN { ORS="" }; { print $2}')
    echo "Waiting for Nodes to be Ready..."
    sleep 10
done

echo Good to go

echo "${bold}Ensure all CRDs were committed...${normal}"
CRDS=$(kubectl get crds | grep 'istio.io\|certmanager.k8s.io' | wc -l)
until [ $CRDS = "56" ]; do
    sleep 10
    CRDS=$(kubectl get crds | grep 'istio.io\|certmanager.k8s.io' | wc -l)
done
echo $CRDS


