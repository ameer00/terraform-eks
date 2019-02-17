#!/bin/bash

# Set speed, bold and color variables
SPEED=40 
bold=$(tput bold) 
normal=$(tput sgr0) 
color='\e[1;32m' # green 
nc='\e[0m'

# Get user input
echo "${bold}Please enter information below...${normal}" 
if [ -z "$AWS_ACCESS_KEY_ID" ] ; then
    read -p "Enter AWS Access Key ID : " AWS_ACCESS_KEY_ID
    export AWS_ACCESS_KEY_ID 
fi 
if [ -z "$AWS_SECRET_ACCESS_KEY" ] ; then
    read -p "Enter AWS Secret Access Key : " AWS_SECRET_ACCESS_KEY
    export AWS_SECRET_ACCESS_KEY 
fi 
read -p "Enter AWS Region [us-west-2] : " TF_VAR_aws_region 
read -p "EKS - Enter number of nodes [4] : " TF_VAR_num_nodes 
read -p "EKS - Enter EC2 Instance Type [m4.xlarge]: " TF_VAR_inst_type 
read -p "EKS - Cluster Name [eks-1] : " TF_VAR_cluster_name

TF_VAR_aws_region=${TF_VAR_aws_region:-'us-west-2'} 
TF_VAR_num_nodes=${TF_VAR_num_nodes:-4} 
TF_VAR_inst_type=${TF_VAR_inst_type:-'m4.xlarge'} 
TF_VAR_cluster_name=${TF_VAR_cluster_name:-'eks-1'}
export TF_VAR_aws_region

# Create bin path
if ! ls $HOME/bin &> /dev/null ; then
    echo "${bold}Creating local ~/bin folder...${normal}"
    cd $HOME
    mkdir -p bin
    export PATH=$PATH:$HOME/bin/:$HOME/.local/bin/ 
else
    echo "${bold}Local bin folder already exists.${normal}" 
fi 
echo "********************************************************************************"

# Download Istio latest 
cd $HOME 
export ISTIO_VERSION=1.1.0-snapshot.6 
if ! ls $HOME/istio-$ISTIO_VERSION &> /dev/null ; 
then
    echo "${bold}Downloading Istio...${normal}"
    curl -L https://git.io/getLatestIstio | ISTIO_VERSION=$ISTIO_VERSION sh -
    cd istio-$ISTIO_VERSION
    export PATH=$PATH:$HOME/istio-$ISTIO_VERSION/bin
    cp $HOME/istio-$ISTIO_VERSION/bin/istioctl $HOME/bin/.
    cd $HOME 
else
    echo "${bold}Istio version $ISTIO_VERSION already present.${normal}" 
fi 
echo "********************************************************************************"

# Install kubectx/kubens
if kubectx &> /dev/null ; then
    echo "${bold}kubectx/kubens already installed.${normal}" 
else
    echo "${bold}Installing kubectx for easy cluster context switching...${normal}"
    sudo git clone https://github.com/ahmetb/kubectx $HOME/kubectx
    sudo ln -s $HOME/kubectx/kubectx $HOME/bin/kubectx
    sudo ln -s $HOME/kubectx/kubens $HOME/bin/kubens 
fi 
echo "********************************************************************************"

# Install kubectl aliases
if ls $HOME/kubectl-aliases/ &> /dev/null ; then
    echo "${bold}kubectl-aliases already installed.${normal}" 
else
    echo "${bold}Installing kubectl_aliases...${normal}"
    cd $HOME
    git clone https://github.com/ahmetb/kubectl-aliases.git
    echo "[ -f ~/kubectl-aliases/.kubectl_aliases ] && source ~/kubectl-aliases/.kubectl_aliases" >> $HOME/.bashrc
    source ~/.bashrc 
fi 
echo "********************************************************************************"

# Install Helm
if helm &> /dev/null ; then
    echo "${bold}Helm already installed.${normal}" 
else
    echo "${bold}Installing helm...${normal}"
    curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get > get_helm.sh
    chmod 700 get_helm.sh
    ./get_helm.sh &> /dev/null
    cp /usr/local/bin/helm $HOME/bin/ 
fi 
echo "********************************************************************************"

# Install terraform
if terraform version &> /dev/null ; then
    echo "${bold}Terraform already installed.${normal}" 
else
    echo "${bold}Installing terraform...${normal}"
    cd $HOME
    mkdir terraform11
    cd terraform11
    sudo apt-get install unzip
    wget https://releases.hashicorp.com/terraform/0.11.11/terraform_0.11.11_linux_amd64.zip
    unzip terraform_0.11.11_linux_amd64.zip
    mv terraform $HOME/bin/.
    cd $HOME
    rm -rf terraform11 
fi 
echo "********************************************************************************"

# Install latest kubectl 
KUBECTL_VER=$(kubectl version --client=true -o json | jq .clientVersion.gitVersion)
if ! KUBECTL_VER="\"v.13.3\"" ; then
    echo "${bold}Installing kubectl...${normal}"
    curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl 
    chmod +x kubectl 
    sudo mv kubectl /google/google-cloud-sdk/bin/. 
else
    echo "${bold}Kubectl already installed.${normal}"
fi
echo "********************************************************************************"

# Install Heptio Authenticator
if heptio-authenticator-aws &> /dev/null ; then
    echo "${bold}Heptio Authenticator already installed.${normal}" 
else
    echo "${bold}Installing Heptio Authenticator...${normal}"
    wget https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v0.3.0/heptio-authenticator-aws_0.3.0_linux_amd64
    chmod +x heptio-authenticator-aws_0.3.0_linux_amd64
    sudo mv heptio-authenticator-aws_0.3.0_linux_amd64 $HOME/bin/heptio-authenticator-aws 
fi 
echo "********************************************************************************"

# Install krompt
if ! cat $HOME/.bashrc | grep K-PROMPT &> /dev/null ; then
    cd $HOME
    cat $HOME/terraform-eks/cluster/krompt.txt >> $HOME/.bashrc
    source $HOME/.bashrc 
fi 

# Install aws CLI
if ! az --version &> /dev/null ; then
    echo "${bold}Installing az cli...${normal}"
    pip3 install awscli --upgrade --user 
fi 

# Install EKS Cluster
echo "${bold}Start terraform script...${normal}" 
cd $HOME 
cd $HOME/csp/eks/terraform-eks/cluster/ 
terraform init
terraform plan -out out.plan
terraform apply out.plan 
echo "********************************************************************************"

# Create kubeconfig
echo "${bold}Creating kubeconfig...${normal}" 
terraform output kubeconfig > kubeconfig.yaml 
if ls $HOME/.kube/config &> /dev/null ; then
    KUBECONFIG=~/.kube/config:./kubeconfig.yaml kubectl config view --flatten > mergedkub && mv mergedkub ~/.kube/config
    rm mergedkub
else
    mkdir -p ~/.kube && cat kubeconfig.yaml > ~/.kube/config 
fi
kubectx eks-1=aws 
echo "********************************************************************************"

# Create configmap aws auth
echo "${bold}Creating config map aws auth and adding nodes...${normal}" 
terraform output config-map-aws-auth > config-map-aws-auth.yaml 
kubectl apply -f config-map-aws-auth.yaml 
echo "********************************************************************************"

# Wait for Nodes
echo "${bold}Waiting for Nodes to be Ready...${normal}" 
node_status=$(kubectl get nodes | grep Ready | awk 'BEGIN { ORS="" }; { print $2}') 
until [ $node_status = "ReadyReadyReadyReady" ]; do
    node_status=$(kubectl get nodes | grep Ready | awk 'BEGIN { ORS="" }; { print $2}')
    echo "Waiting for Nodes to be Ready..."
    sleep 10 
done 
echo "${bold}Nodes are Ready.${normal}" 
echo "********************************************************************************"

# Install Istio
echo "${bold}Installing Istio version $ISTIO_VERSION...${normal}" 
cd $HOME/istio-$ISTIO_VERSION

echo "${bold}Creating tiller service account and init...${normal}" 
kubectl create -f install/kubernetes/helm/helm-service-account.yaml 
helm init --service-account tiller

echo "${bold}Waiting for tiller...${normal}" 
until timeout 10 helm version; do sleep 10; done

echo "${bold}Updating Helm dependencies for Istio version $ISTIO_VERSION...${normal}" 
helm repo add istio.io "https://gcsweb.istio.io/gcs/istio-prerelease/daily-build/release-1.1-latest-daily/charts/" 
helm dep update install/kubernetes/helm/istio

echo "${bold}Installing istio-init chart to bootstrap Istio CRDs...${normal}" 
helm install install/kubernetes/helm/istio-init --name istio-init --namespace istio-system

echo "${bold}Ensure all CRDs were committed...${normal}" 
CRDS=$(kubectl get crds | grep 'istio.io\|certmanager.k8s.io' | wc -l) 
until [ $CRDS = "56" ]; do
    echo "Committing CRDS..."
    sleep 10
    CRDS=$(kubectl get crds | grep 'istio.io\|certmanager.k8s.io' | wc -l) 
done
echo "${bold}$CRDS CRDs committed.${normal}"

echo "${bold}Install helm chart for Istio version $ISTIO_VERSION...${normal}" 
cd $HOME/istio-$ISTIO_VERSION
helm install install/kubernetes/helm/istio --name istio --namespace istio-system --set tracing.enabled=true --set grafana.enabled=true --set servicegraph.enabled=true --kube-context eks-1 
echo "********************************************************************************"