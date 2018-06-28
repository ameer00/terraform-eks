# Setting up AWS EKS

See https://www.terraform.io/docs/providers/aws/guides/eks-getting-started.html for full guide


## Download kubectl
```
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x kubectl
sudo mv kubectl /usr/local/bin
```
Confirm that `kubectl` is at least version 1.10 or higher.  Client version must be higher than the Server version.
```
kubectl version
```
_Output_
```
Client Version: version.Info{Major:"1", Minor:"11", GitVersion:"v1.11.0", GitCommit:"91e7b4fd31fcd3d5f436da26c980becec37ceefe", GitTreeState:"clean", BuildDate:"2018-06-27T20:17:28Z", GoVersion:"go1.10.2", Compiler:"gc", Platform:"linux/amd64"}
Server Version: version.Info{Major:"1", Minor:"10", GitVersion:"v1.10.3", GitCommit:"2bba0127d85d5a46ab4b778548be28623b32d0b0", GitTreeState:"clean", BuildDate:"2018-05-28T20:13:43Z", GoVersion:"go1.9.3", Compiler:"gc", Platform:"linux/amd64"}
```

## Download the aws-iam-authenticator
```
wget https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v0.3.0/heptio-authenticator-aws_0.3.0_linux_amd64
chmod +x heptio-authenticator-aws_0.3.0_linux_amd64
sudo mv heptio-authenticator-aws_0.3.0_linux_amd64 /usr/local/bin/heptio-authenticator-aws
```
This is used to authenticate to the EKS cluster when running `kubectl` commands.

## Modify providers.tf

Choose your region. EKS is not available in every region, use the Region Table to check whether your region is supported: https://aws.amazon.com/about-aws/global-infrastructure/regional-product-services/

Make changes in providers.tf accordingly (region, optionally profile)

## Terraform apply
```
terrafomr init
terraform apply
```

## Configure kubectl
```
terraform output kubeconfig > kubeconfig.yaml
kubectl config --kubeconfig kubeconfig.yaml
```

## Configure config-map-auth-aws
```
terraform output config-map-aws-auth > config-map-aws-auth.yaml
kubectl apply -f config-map-aws-auth.yaml
```

## See nodes coming up
```
kubectl get nodes
```

## Destroy
Make sure all the resources created by Kubernetes are removed (LoadBalancers, Security groups), and issue:
```
terraform destroy
```
