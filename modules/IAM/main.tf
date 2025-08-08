# modules/IAM/main.tf

resource "aws_iam_role" "code_deploy_role" {
  name               = "ec2-code-deploy-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Attach policies for EC2 instances to interact with CodeDeploy, ECR, and other services
resource "aws_iam_role_policy_attachment" "code_deploy_policy" {
  role       = aws_iam_role.code_deploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy"
}

resource "aws_iam_role_policy_attachment" "s3_read_policy" {
  role       = aws_iam_role.code_deploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}
resource "aws_iam_role_policy_attachment" "ecr_read_policy" {
  role       = aws_iam_role.code_deploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}




# Create IAM Instance Profile
resource "aws_iam_instance_profile" "instance_profile" {
  name = "ec2-code-deploy-instance-profile"
  role = aws_iam_role.code_deploy_role.name
}
output "instance_profile" {
  value = aws_iam_instance_profile.instance_profile
}
