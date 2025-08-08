#Project Title : Project Title:
Automated Web Application Deployment Using Terraform and AWS CI/CD Stack

##ProjectOverview
This project provides a complete CI/CD pipeline setup to deploy a containerized Flask web application to an Auto Scaling Group of EC2 instances behind an Application Load Balancer on AWS.
The infrastructure is provisioned using Terraform, and the deployment is managed by AWS CodeBuild and CodeDeploy.

## Prerequisites

Before you begin, ensure y the following installed and configured:

1.  AWS CLI: Configured with credentials that have administrative access to your AWS account.
2.  Terraform: Version 1.5.x or later.
3.  Git: For source code management.

## ProjectStructure:

├── README.md
├── app/
│   ├── Dockerfile
│   ├── app.py
│   └── requirements.txt
├── appspec.yml
├── buildspec.yml
├── scripts/
│   ├── install_dependencies.sh
│   ├── start_server.sh
│   ├── stop_server.sh
│   └── validate_service.sh
├── modules/
│   ├── ec2/
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── alb/
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── vpc/
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── asg/
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   └── security_groups/
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
├── main.tf                # Root Terraform file calling individual modules
├── variables.tf           # Variable declarations for root module
├── dev.tfvars             # Variable values for the dev environment
├── backend.tfvars         # Terraform backend settings (S3, DynamoDB)
└── outputs.tf             # Root module output values



app/: Contains the Flask application code and its Dockerfile.
    -   app.py: A simple Flask application that returns a JSON message.
    -   Dockerfile: Dockerfile to build the Flask application image.
    -   requirements.txt: Python dependencies for the Flask application.

-   buildspec.yml: AWS CodeBuild specification file, defining terraform init,plan,apply Docker build, ECR push.

- deployments/scripts/: 
 Shell scripts executed by AWS CodeDeploy on the EC2 instances.
  -   `
install_dependencies.sh  : Install the required dependencies ( docker ) 
start_server.sh   : Runs the new Docker container, mapping host port 80 to container port 5000.
stop_server.sh   : Stops and removes the running Docker containe
validate_service.sh : The script verifies that the "viewport" Docker container is running and healthy by retrying endpoint checks and validating expected response content, showing logs if it fails.


## Deployment Steps (AWS CodePipeline Setup)

This project is designed to be deployed using AWS CodePipeline, orchestrating GitHub, CodeBuild, and CodeDeploy.

.Create AWS CodeBuild Project
Go to AWS CodeBuild in the AWS Console.

Click "Create build project".

Project name: my-webapp-build

Source:
Source provider: Choose your source ( GitHub).
Repository: Select the repository created in step 2.
Branch: main (or your default branch).

Environment:
Managed image: Amazon Linux 2
Runtime(s): Standard
Image: Choose the latest aws/codebuild/amazonlinux2-x86_64-standard:X.0 (e.g., 5.0).
New service role: Let CodeBuild create a new service role. Ensure this role has permissions for:


Buildspec:
Buildspec name: buildspec.yml (default, as it's in the root of your repo).

Artifacts:
Type: Amazon S3
Bucket: Create a new S3 bucket (e.g., my-webapp-codepipeline-artifacts).
Name: my-webapp-build-artifact
Packaging: Zip

Leave other settings as default or configure as needed.

Click "Create build project".


Create AWS CodeDeploy Application and Deployment Group
Go to AWS CodeDeploy in the AWS Console.

Applications:
Click "Create application".
Application name: my-webapp-app
Compute platform: EC2/On-premises
Click "Create application".

## Deployment groups:
Select my-webapp-app and click "Create deployment group".
Deployment group name: my-webapp-deployment-group
Service role: Create a new service role or use an existing one. This role needs permissions to interact with EC2 instances and Auto Scaling Groups. The managed policy arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole is usually sufficient.
Deployment type: In-place
Environment configuration:
Auto Scaling groups: Select the ASG created by Terraform (e.g., my-webapp-asg).
Deployment settings: Choose CodeDeployDefault.AllAtOnce (for simplicity, or OneAtATime for rolling updates).
Load balancer:
Enable load balancing.
Select the ALB created by Terraform (e.g., my-webapp-alb).
Select the target group (e.g., my-webapp-tg).
Leave other settings as default.
Click "Create deployment group".


Create AWS CodePipeline
Go to AWS CodePipeline in the AWS Console.

Click "Create pipeline".

Pipeline settings:
Pipeline name: my-webapp-pipeline
Service role: Let CodePipeline create a new service role.
Artifact store: Use the S3 bucket created for CodeBuild artifacts (e.g., my-webapp-codepipeline-artifacts).

Source stage:
Source provider: Choose your source (e.g., AWS CodeCommit, GitHub).
Repository name: Select your repository (e.g., my-webapp-repo).
Branch name: main.
Change detection options: AWS CodePipeline (recommended for CodeCommit).
Output artifact format: CodePipeline default.

Build stage:
Build provider: AWS CodeBuild
Project name: Select my-webapp-build.
Build type: Single build.
Input artifacts: SourceArtifact.

Deploy stage:
Deploy provider: AWS CodeDeploy
Application name: my-webapp-app
Deployment group: my-webapp-deployment-group
Input artifacts: BuildArtifact (this is the output from the CodeBuild stage).

Review and create the pipeline.

6. Monitor and Verify
Once the pipeline is created, it will automatically start.

Monitor the pipeline execution in the AWS CodePipeline console.

Check the CodeBuild logs for any errors during the build and Terraform apply steps.

Check the CodeDeploy deployment details for the status of the application deployment on the EC2 instances.

Once the pipeline completes successfully, navigate to the ALB DNS name (output from Terraform) in your web browser. You should see the Flask application UI.


##Cleanup

run terraform destroy from the main.tf file 

Manual Process 
To tear down the infrastructure and avoid incurring charges, follow these steps:

Stop CodePipeline: In the CodePipeline console, disable or delete the my-webapp-pipeline.

Delete CodeDeploy Deployment Group and Application: In the CodeDeploy console, delete my-webapp-deployment-group and then my-webapp-app.

Delete CodeBuild Project: In the CodeBuild console, delete my-webapp-build.

Empty and Delete S3 Artifact Bucket: Empty and delete the my-webapp-codepipeline-artifacts S3 bucket.

Delete ECR Repository: In the ECR console, delete the my-webapp repository.

Destroy Terraform Resources


