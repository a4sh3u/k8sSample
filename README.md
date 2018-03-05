# Hosting a simple Java Application on AWS in a K8 Cluster

Assumptions :
- There is a AWS IAM account with the following privileges (AmazonEC2FullAccess, AmazonRoute53FullAccess, AmazonS3FullAccess, IAMFullAccess, AmazonVPCFullAccess)
- awcli is installed on your machine and set to use the above said IAM account. If not, use the below commands (For Ubuntu)
    `pip install awscli --upgrade --user`
    `aws configure`
- There is already a base domain name registered like `etc.com`
- You have a repository to store docker images. Assuming, your created two repositories `etc/helloworld` & `etc/nginx`, we will proceed.

## Create the docker images and push them to their repositories
    docker build -t etc/helloworld:latest java_app; docker push etc/helloworld:latest
    docker build -t etc/nginx:latest nginx; docker push etc/nginx:latest

## Create a route53 domain for your cluster
- Use the script `create_subdomain.sh` to do this step. (the values are hardcoded - so change them according to as needed)

## Install kubectl & kops
- Run the below commands to install kubectl and kops
    `curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl`
    `chmod +x ./kubectl; sudo mv ./kubectl /usr/local/bin/kubectl`
    `wget https://github.com/kubernetes/kops/releases/download/1.8.0/kops-linux-amd64`
    `chmod +x kops-linux-amd64; sudo mv kops-linux-amd64 /usr/local/bin/kops`

## Create an S3 bucket to store your clusters state
- Run the below commands to create and store the S3 bucket information to a variable
    `aws s3 mb s3://clusters.zen.etc.com; export KOPS_STATE_STORE=s3://clusters.zen.etc.com`

## Build your cluster configuration & Start the cluster
    kops create cluster --zones=eu-central-1 zen.etc.com
    kops update cluster zen.etc.com --yes

## Wait for a few minutes to get the servers booted up & then validate them
    kops validate cluster
- If the above command succeeds, then proceed to the next steps. You should be able to see one Master Server and two Nodes running.

## Create the configuration and secret for the application deployment
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout nginx/nginx.key -out nginx/nginx.crt -subj "/CN=nginxsvc/O=nginxsvc"
    kubectl create secret tls nginxsecret --key nginx/nginx.key --cert nginx/nginx.crt
    kubectl create configmap nginxconfigmap --from-file=nginx/default.conf

## Deploy the Application and the associated services
    kubectl apply -f deploy.yml

## The following command would give you the URL of the helloworld Application and it can be opened on the browser as it is
    echo "http://$(kubectl get services -o wide | grep nginxsvc | awk '{print $4}')"
