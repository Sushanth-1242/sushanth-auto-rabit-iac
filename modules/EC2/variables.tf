variable "ami_id" {
  description = "The AMI ID for the EC2 instance"
  type        = string
}

# Define the instance type (e.g., t2.micro, t3.medium, etc.)
variable "instance_type" {
  description = "The EC2 instance type"
  type        = string
  default     = "t2.micro"
}

# Define the SSH key pair name
variable "key_name" {
  description = "The SSH key pair to use for the instance"
  type        = string
}

# Define the subnet ID for the EC2 instance
variable "subnet_id" {
  description = "The subnet ID for the EC2 instance"
  type        = string
}

variable "instance_name" {
  description = "The AMI ID for the EC2 instance"
  type        = string
}
variable "security_group_ids" {
  description = "The security group IDs for the EC2 instance"
  type        = list(string)  # Correct type should be a list of strings
}
variable "ebs_size" {
  description = "Size of the EBS volume in GB"
  default     = 20
}