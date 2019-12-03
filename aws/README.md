### AWS Provisioning
This module helps us to create N number of VMs on aws via terraform.

## Setup

# AWS
Please install aws client on your laptop. 
```
$aws --version
aws-cli/1.16.140 Python/3.7.3 Darwin/19.0.0 botocore/1.12.130
```
Configure aws credentials using "aws config". It normally stores these files under .aws in your home directory. Verify your aws client credentials by running
```
$aws configure
AWS Access Key ID [****************ABCD]: 
AWS Secret Access Key [****************ABCD]: 
Default region name [eu-west-1]: 
Default output format [None]: 
```

# Variables
Modify variables.tf as per your aws environment. Also change number of virtual machines to suit your needs.   
You may update these variables by passing it as terraform command line parameters too.
- location [Aws location]
- vpc_cidr [Aws vpc cidr]
- subnet_cidr [Aws subnet cidr]
- vmsize [Aws VM Size]
- vmsize [Aws VM Size]
- vmcount [VMs Count]

# SSH key pair
Create a new key pair by running below commands. It should be saved under "ssh_keys" folder.
```
$mkdir ssh_keys
$ssh-keygen -t rsa -b 4096 -C "ubuntu@aws.com" -f ./ssh_keys/id_rsa -q -N ""
$ls ssh_keys
id_rsa		id_rsa.pub
```

# Terraform
Install terraform from https://www.terraform.io/downloads.html (version 0.12+)
   ```
   $terraform -version
   Terraform v0.12.0
   
   Your version of Terraform is out of date! The latest version
   is 0.12.16. You can update by downloading from www.terraform.io/downloads.html
   ```

Run command below to initialize terraform based on your *.tf files.
```
$terraform init
Initializing the backend...

Initializing provider plugins...
- Checking for available provider plugins...
- Downloading plugin for provider "null" (hashicorp/null) 2.1.2...
- Downloading plugin for provider "aws" (hashicorp/aws) 2.40.0...
***More verbose logs***
Terraform has been successfully initialized!
***More verbose logs***
```

## Virtual Machines
# Terraform apply
Run terraform apply to create VMs on aws.
```
$terraform apply -var "my_public_ip=`curl ifconfig.me`" 
$terraform apply -var "my_public_ip=`curl ifconfig.me`"  -auto-approve
$terraform apply -var "location=eu-west-1" -var "vpc_cidr=10.0.0.0/16" -var "subnet_cidr=10.0.2.0/24" -var "vmsize=c4.xlarge" -var "vmcount=3" -var "my_public_ip=`curl ifconfig.me`" 
$terraform apply -var "location=eu-west-1" -var "vpc_cidr=10.0.0.0/16" -var "subnet_cidr=10.0.2.0/24" -var "vmsize=c4.xlarge" -var "vmcount=3" -var "my_public_ip=`curl ifconfig.me`" -auto-approve
```
You may keep on appending variables like shown above or you can change variables.tf file as shown above.    
Additionally you add flag '-auto-approve' to execute terraform without manual confirmation   


## Cleanup
# Terraform destroy
```
$terraform destroy -var "my_public_ip=`curl ifconfig.me`" 
$terraform destroy -var "my_public_ip=`curl ifconfig.me`"  -auto-approve
$terraform destroy -var "location=eu-west-1" -var "vpc_cidr=10.0.0.0/16" -var "subnet_cidr=10.0.2.0/24" -var "vmsize=c4.xlarge" -var "vmcount=3" -var "my_public_ip=`curl ifconfig.me`" 
$terraform destroy -var "location=eu-west-1" -var "vpc_cidr=10.0.0.0/16" -var "subnet_cidr=10.0.2.0/24" -var "vmsize=c4.xlarge" -var "vmcount=3" -var "my_public_ip=`curl ifconfig.me`" -auto-approve
```