# ECS Fargate Deployment with DVWA Container on AWS

This Terraform script automates the deployment of a **Dockerized Vulnerable Web Application (DVWA)** using AWS ECS Fargate. It provisions all the required AWS resources, including a custom VPC, ECS cluster, Fargate task definition, and service. The script configures the application to be publicly accessible via an Internet Gateway, and outputs the public IP assigned to the Fargate task for easy access.

### Features

- **Custom VPC**: A Virtual Private Cloud (VPC) is created with public subnets, Internet Gateway, and appropriate routing for public access.
- **Security Group**: Configured to allow HTTP traffic on port 80.
- **ECS Fargate Cluster**: ECS cluster with a Fargate task running the `vulnerables/web-dvwa` Docker container.
- **Task Definition & Service**: The container is configured with proper task definitions and is deployed as a Fargate service with public IP assignment.
- **Public IP Output**: The script outputs the public IP address of the Fargate service, making it easy to access the web application after deployment.

### Terraform Resources

- **VPC**: A custom VPC with a public subnet, Internet Gateway, and route table association.
- **Security Group**: Allows inbound traffic on port 80 & port 8080 for HTTP access.
- **ECS Cluster**: An ECS cluster is created to run the Fargate service.
- **ECS Fargate Task**: The `vulnerables/web-dvwa` container is deployed as a task on Fargate.
- **Public IP Output**: Retrieves and outputs the public IP of the Fargate task via the associated network interface.

### Prerequisites

- Terraform installed
- AWS credentials configured (via `~/.aws/credentials` or environment variables)
- AWS account with appropriate permissions for VPC, ECS, and IAM

### Usage

1. Clone the repository:
   ```
   bash
   git clone https://github.com/chiangyaw/aws-dvwa-fargate.git
   cd aws-dvwa-fargate
   ```

2. Initialize Terraform:
    ```
    terraform init
    ```

3. Apply the Terraform plan:
    ```
    terraform apply
    ```

4. After the deployment is complete, you'll get the public IP address of the Fargate service as an output:
    ```
    Outputs:
    fargate_service_pip = "xxx.xxx.xxx.xxx"
    ```

5.  Access the DVWA application in your browser using the output public IP:
    ```
    http://xxx.xxx.xxx.xxx
    ```

### Clearup
To remove the deployed infrastructure, run:
    ```
    terraform destroy
    ```
