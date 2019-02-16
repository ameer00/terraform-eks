#!/bin/bash

echo "${bold}Waiting for Nodes to be Ready...${normal}"
node_status=$(kubectl get nodes | grep Ready | awk 'BEGIN { ORS="" }; { print $2}')
until [ $node_status = "ReadyReadyReadyReady1" ]; do
    node_status=$(kubectl get nodes | grep Ready | awk 'BEGIN { ORS="" }; { print $2}')
    echo "Waiting for Nodes to be Ready..."
    sleep 10
done
echo "${bold}Nodes are Ready.${normal}"
echo "********************************************************************************"

echo Good to go

echo "${bold}Ensure all CRDs were committed...${normal}"
CRDS=$(kubectl get crds | grep 'istio.io\|certmanager.k8s.io' | wc -l)
until [ $CRDS = "56" ]; do
    sleep 10
    CRDS=$(kubectl get crds | grep 'istio.io\|certmanager.k8s.io' | wc -l)
done
echo $CRDS




export USER=$(gcloud config list account --format "value(core.account)")
export PROJECT_ID=$(gcloud config get-value project)
kubectl create clusterrolebinding user-cluster-admin --clusterrole cluster-admin --user $USER
gcloud projects add-iam-policy-binding $PROJECT_ID --member user:$USER \
--role roles/owner \
--role roles/clusterregistry.admin \
--role roles/iam.serviceAccountAdmin \
--role roles/iam.serviceAccountKeyAdmin \
--role roles/resourcemanager.projectIamAdmin


