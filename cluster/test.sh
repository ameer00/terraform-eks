# Get user input
echo "${bold}Please enter information below...${normal}"
read -p "Enter AWS Access Key ID                  : " AWS_ACCESS_KEY
read -p "Enter AWS Secret Access Key              : " AWS_SECRET_KEY
read -p "Enter AWS Region [us-east-1]             : " TF_VAR_aws_region
read -p "EKS - Enter number of nodes [4]          : " TF_VAR_num_nodes
read -p "EKS - Enter EC2 Instance Type [m4.xlarge]: " TF_VAR_inst_type
read -p "EKS - Cluster Name [eks-1]               : " TF_VAR_cluster_name

TF_VAR_aws_region=${TF_VAR_aws_region:-'us-east-1'}
TF_VAR_num_nodes=${TF_VAR_num_nodes:-4}
TF_VAR_inst_type=${TF_VAR_inst_type:-'m4.xlarge'}
TF_VAR_cluster_name=${TF_VAR_cluster_name:-'eks-1'}

echo $TF_VAR_aws_region
echo $TF_VAR_num_nodes
echo $TF_VAR_inst_type
echo $TF_VAR_cluster_name
