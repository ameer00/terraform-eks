#!/bin/bash

# Set speed, bold and color variables
SPEED=40
bold=$(tput bold)
normal=$(tput sgr0)
color='\e[1;32m' # green
nc='\e[0m'

# Get user input
echo "${bold}Please enter information below...${normal}"
read -p "Enter AWS Access Key ID                  : " AWS_ACCESS_KEY
read -p "Enter AWS Secret Access Key              : " AWS_SECRET_KEY
read -p "Enter AWS Region [us-east-1]             : " TF_VAR_aws_region
read -p "EKS - Enter number of nodes [4]          : " TF_VAR_num_nodes
read -p "EKS - Enter EC2 Instance Type [m4.xlarge]: " TF_VAR_inst_type
read -p "EKS - Cluster Name [eks-1]               : " TF_VAR_cluster-name

TF_VAR_aws_region=${TF_VAR_aws_region:-'us-east-1'}
TF_VAR_num_nodes=${TF_VAR_num_nodes:-4}
TF_VAR_inst_type=${TF_VAR_inst_type:-'m4.xlarge'}
TF_VAR_cluster-name=${TF_VAR_cluster-name:-'eks-1'}

# Create bin path
echo "${bold}Creating local ~/bin folder...${normal}"
cd $HOME
mkdir bin
PATH=$PATH:$HOME/bin/

# Install kubectx/kubens
echo "${bold}Installing kubectx for easy cluster context switching...${normal}"
sudo git clone https://github.com/ahmetb/kubectx $HOME/kubectx
sudo ln -s $HOME/kubectx/kubectx $HOME/bin/kubectx
sudo ln -s $HOME/kubectx/kubens $HOME/bin/kubens
echo "********************************************************************************"

# Install kubectl aliases
echo "${bold}Installing kubectl_aliases...${normal}"
cd $HOME
git clone https://github.com/ahmetb/kubectl-aliases.git
echo "[ -f ~/kubectl-aliases/.kubectl_aliases ] && source ~/kubectl-aliases/.kubectl_aliases" >> $HOME/.bashrc
source ~/.bashrc
echo "********************************************************************************"

# Install Helm
echo "${bold}Installing helm...${normal}"
curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get > get_helm.sh
chmod 700 get_helm.sh
./get_helm.sh &> /dev/null
cp /usr/local/bin/helm $HOME/bin/
echo "********************************************************************************"

# Install terraform
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
echo "********************************************************************************"

# Install latest kubectl
echo "${bold}Installing kubectl...${normal}"
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x kubectl
sudo mv kubectl /google/google-cloud-sdk/bin/.

# Install Heptio Authenticator
echo "${bold}Installing Heptio Authenticator...${normal}"
wget https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v0.3.0/heptio-authenticator-aws_0.3.0_linux_amd64
chmod +x heptio-authenticator-aws_0.3.0_linux_amd64
sudo mv heptio-authenticator-aws_0.3.0_linux_amd64 $HOME/bin/heptio-authenticator-aws

# Install EKS Cluster
echo "${bold}Start terraform script...${normal}"
cd $HOME
git clone https://github.com/ameer00/terraform-eks.git -b v1 
cd $HOME/terraform-eks/cluster/
terraform init
terraform apply -auto-approve




