# AWS CLI and IAM Guide for DevOps/Cloud Engineers

This repository contains comprehensive documentation and examples for working with AWS CLI and IAM, specifically tailored for DevOps and Cloud engineers managing multiple environments.

## Table of Contents

- [Overview](#overview)
- [AWS CLI Basics](#aws-cli-basics)
  - [Installation and Configuration](#installation-and-configuration)
  - [Using Named Profiles](#using-named-profiles)
- [IAM Fundamentals](#iam-fundamentals)
  - [Users Management](#users-management)
  - [Access Keys](#access-keys)
  - [Password Management](#password-management)
  - [Groups](#groups)
  - [Policies](#policies)
- [IAM Roles](#iam-roles)
  - [Creating Roles](#creating-roles)
  - [Cross-Account Access](#cross-account-access)
  - [Assuming Roles](#assuming-roles)
  - [Role Switching](#role-switching)
- [Multi-Account Management](#multi-account-management)
  - [AWS Organizations](#aws-organizations)
  - [Service Control Policies](#service-control-policies)
- [DevOps Best Practices](#devops-best-practices)
  - [CI/CD Pipelines](#cicd-pipelines)
  - [Environment-Specific Roles](#environment-specific-roles)
  - [User Lifecycle Management](#user-lifecycle-management)
  - [Least Privilege Implementation](#least-privilege-implementation)
- [Troubleshooting](#troubleshooting)
  - [Common Issues](#common-issues)
  - [Policy Validation](#policy-validation)
- [Advanced Topics](#advanced-topics)
  - [Permission Boundaries](#permission-boundaries)
  - [Temporary Credentials](#temporary-credentials)
  - [MFA with AWS CLI](#mfa-with-aws-cli)
  - [IAM with CloudFormation](#iam-with-cloudformation)
- [Security Best Practices](#security-best-practices)
  - [Regular Auditing](#regular-auditing)
  - [Password Policies](#password-policies)
  - [Access Key Rotation](#access-key-rotation)
- [Example Scripts](#example-scripts)
  - [Multi-Environment Setup](#multi-environment-setup)
  - [User Management](#user-management)
  - [Key Rotation](#key-rotation)

## Overview

This guide provides detailed instructions, examples, and best practices for managing AWS resources using AWS CLI and IAM. It covers everything from basic user management to advanced cross-account role configurations and security best practices.

## AWS CLI Basics

### Installation and Configuration

The AWS Command Line Interface (CLI) allows you to interact with AWS services from the command line.

```bash
# Install AWS CLI on macOS/Linux
pip install awscli --upgrade --user

# Install on Windows
# Download from https://awscli.amazonaws.com/AWSCLIV2.msi

# Verify installation
aws --version

# Configure credentials
aws configure
```

### Using Named Profiles

For managing multiple environments (development, staging, production):

```bash
# Set up named profiles
aws configure --profile dev
aws configure --profile staging
aws configure --profile production

# Use a specific profile
aws s3 ls --profile production

# Set default profile for session
export AWS_PROFILE=production  # Linux/macOS
set AWS_PROFILE=production     # Windows
```

## IAM Fundamentals

### Users Management

```bash
# Create a new IAM user
aws iam create-user --user-name john.doe

# List all users
aws iam list-users

# Delete a user
aws iam delete-user --user-name john.doe
```

### Access Keys

```bash
# Create access keys
aws iam create-access-key --user-name john.doe

# List access keys
aws iam list-access-keys --user-name john.doe

# Delete access keys
aws iam delete-access-key --user-name john.doe --access-key-id AKIAIOSFODNN7EXAMPLE
```

### Password Management

```bash
# Create console access with password
aws iam create-login-profile --user-name john.doe --password "InitialPassword123!" --password-reset-required

# Update a password
aws iam update-login-profile --user-name john.doe --password "NewSecurePassword456!" --password-reset-required
```

### Groups

```bash
# Create a group
aws iam create-group --group-name Developers

# Add user to group
aws iam add-user-to-group --user-name john.doe --group-name Developers

# List groups for a user
aws iam list-groups-for-user --user-name john.doe

# Remove user from group
aws iam remove-user-from-group --user-name john.doe --group-name Developers
```

### Policies

```bash
# Create custom policy
aws iam create-policy --policy-name S3ReadOnlyPolicy --policy-document file://s3-read-policy.json

# Attach policy to user
aws iam attach-user-policy --user-name john.doe --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess

# Attach policy to group
aws iam attach-group-policy --group-name Developers --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess

# List attached policies
aws iam list-attached-user-policies --user-name john.doe

# Detach policy
aws iam detach-user-policy --user-name john.doe --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess
```

## IAM Roles

### Creating Roles

```bash
# Create a role for EC2 instances
aws iam create-role --role-name EC2S3ReadOnly --assume-role-policy-document file://ec2-trust-policy.json

# Attach policy to role
aws iam attach-role-policy --role-name EC2S3ReadOnly --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess
```

### Cross-Account Access

```bash
# Create cross-account role
aws iam create-role --role-name CrossAccountDeveloper --assume-role-policy-document file://cross-account-policy.json
```

### Assuming Roles

```bash
# Assume a role and get temporary credentials
aws sts assume-role --role-arn arn:aws:iam::123456789012:role/DevOpsRole --role-session-name DevOpsSession
```

### Role Switching

```bash
# Configure profile that assumes a role in ~/.aws/config
[profile prod-admin]
role_arn = arn:aws:iam::123456789012:role/AdminRole
source_profile = default

# Use the profile
aws s3 ls --profile prod-admin
```

## Multi-Account Management

### AWS Organizations

```bash
# Create an organization
aws organizations create-organization

# Create new account in organization
aws organizations create-account --email account-email@example.com --account-name "Development Account"

# List accounts
aws organizations list-accounts
```

### Service Control Policies

```bash
# Create SCP
aws organizations create-policy --content file://scp-policy.json --name "PreventDeletionSCP" --type SERVICE_CONTROL_POLICY --description "Prevents resource deletion"

# Attach SCP to organizational unit
aws organizations attach-policy --policy-id p-12345678 --target-id ou-1234-5678abcd
```

## DevOps Best Practices

### CI/CD Pipelines

```bash
# Create policy for CI/CD pipelines
aws iam create-policy --policy-name CICDDeployPolicy --policy-document file://cicd-policy.json
```

### Environment-Specific Roles

```bash
# Create environment-specific roles
aws iam create-role --role-name DevEnvironmentDeployer --assume-role-policy-document file://cicd-trust-policy.json
aws iam create-role --role-name ProdEnvironmentDeployer --assume-role-policy-document file://cicd-trust-policy.json
```

### User Lifecycle Management

See [Example Scripts](#example-scripts) section for a script to automate user creation.

### Least Privilege Implementation

```bash
# Audit policies
aws iam get-account-authorization-details > iam-details.json

# Use IAM Access Analyzer
aws accessanalyzer start-policy-generation --policy-generation-details '{"principalArn":"arn:aws:iam::123456789012:role/ExampleRole"}'
```

## Troubleshooting

### Common Issues

```bash
# Check identity
aws sts get-caller-identity

# Validate policy
aws iam simulate-principal-policy --policy-source-arn arn:aws:iam::123456789012:user/john.doe --action-names s3:PutObject

# Set missing region
export AWS_DEFAULT_REGION=us-east-1
```

### Policy Validation

```bash
# Validate policy before applying
aws iam simulate-custom-policy --policy-input-list file://test-policy.json --action-names ec2:StartInstances
```

## Advanced Topics

### Permission Boundaries

```bash
# Create permission boundary
aws iam create-policy --policy-name DevBoundary --policy-document file://dev-boundary.json

# Apply boundary to user
aws iam put-user-permissions-boundary --user-name john.doe --permissions-boundary arn:aws:iam::123456789012:policy/DevBoundary
```

### Temporary Credentials

```bash
# Generate temporary credentials
aws sts get-session-token --duration-seconds 3600
```

### MFA with AWS CLI

```bash
# Assume role with MFA
aws sts assume-role --role-arn arn:aws:iam::123456789012:role/MFAProtectedRole --role-session-name mfa-session --serial-number arn:aws:iam::123456789012:mfa/john.doe --token-code 123456
```

### IAM with CloudFormation

Deploy IAM resources using CloudFormation:

```bash
aws cloudformation create-stack --stack-name iam-resources --template-body file://iam-template.yaml --parameters ParameterKey=DevOpsUserPassword,ParameterValue=InitialPassword123! --capabilities CAPABILITY_NAMED_IAM
```

## Security Best Practices

### Regular Auditing

```bash
# List policies with admin permissions
aws iam list-policies --scope Local --only-attached --query "Policies[?PolicyName.contains(@, 'Admin')]"

# Find users with console access but no MFA
aws iam list-users --query "Users[?PasswordLastUsed!=null]" > users_with_console.json
aws iam list-virtual-mfa-devices > mfa_devices.json
```

### Password Policies

```bash
# Set strong password policy
aws iam update-account-password-policy --minimum-password-length 12 --require-symbols --require-numbers --require-uppercase-characters --require-lowercase-characters --allow-users-to-change-password --max-password-age 90 --password-reuse-prevention 24
```

### Access Key Rotation

See [Example Scripts](#example-scripts) section for a key rotation script.

## Example Scripts

### Multi-Environment Setup

```bash
#!/bin/bash
# Setup script for multi-environment infrastructure

# Create environment-specific roles
aws iam create-role --role-name DevDeployer --assume-role-policy-document file://cicd-trust-policy.json
aws iam create-role --role-name StagingDeployer --assume-role-policy-document file://cicd-trust-policy.json
aws iam create-role --role-name ProdDeployer --assume-role-policy-document file://cicd-trust-policy.json

# Attach base deployer policy to all roles
aws iam attach-role-policy --role-name DevDeployer --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess
aws iam attach-role-policy --role-name StagingDeployer --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess
aws iam attach-role-policy --role-name ProdDeployer --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess

# Add specific policies for production
aws iam create-policy --policy-name ProdDeploymentPolicy --policy-document file://prod-deploy-policy.json
aws iam attach-role-policy --role-name ProdDeployer --policy-arn arn:aws:iam::123456789012:policy/ProdDeploymentPolicy

# Create environment-specific buckets
aws s3api create-bucket --bucket dev-artifacts-123
aws s3api create-bucket --bucket staging-artifacts-123
aws s3api create-bucket --bucket prod-artifacts-123

# Set up deployment user
aws iam create-user --user-name deployment-bot
aws iam put-user-policy --user-name deployment-bot --policy-name AssumeRolePolicy --policy-document file://assume-role-policy.json
aws iam create-access-key --user-name deployment-bot
```

### User Management

```bash
#!/bin/bash
# Usage: ./create_developer.sh john.doe john.doe@example.com

USERNAME=$1
EMAIL=$2

# Create user
aws iam create-user --user-name $USERNAME

# Add to developers group
aws iam add-user-to-group --user-name $USERNAME --group-name Developers

# Create access key
aws iam create-access-key --user-name $USERNAME

# Create console access
PASSWORD=$(openssl rand -base64 12)
aws iam create-login-profile --user-name $USERNAME --password "$PASSWORD" --password-reset-required

echo "User $USERNAME created with temporary password: $PASSWORD"
echo "Email: $EMAIL"
```

### Key Rotation

```bash
#!/bin/bash
# Usage: ./rotate_access_key.sh username

USERNAME=$1

# List current keys
KEYS=$(aws iam list-access-keys --user-name $USERNAME --query 'AccessKeyMetadata[*].AccessKeyId' --output text)
KEY_COUNT=$(echo $KEYS | wc -w)

if [ $KEY_COUNT -ge 2 ]; then
  echo "User already has two access keys. Delete one first."
  exit 1
fi

# Create new key
NEW_KEY=$(aws iam create-access-key --user-name $USERNAME)
NEW_ACCESS_KEY=$(echo $NEW_KEY | jq -r '.AccessKey.AccessKeyId')
NEW_SECRET_KEY=$(echo $NEW_KEY | jq -r '.AccessKey.SecretAccessKey')

echo "New access key created: $NEW_ACCESS_KEY"
echo "Secret: $NEW_SECRET_KEY"
echo "Keep these credentials safe!"
echo "After updating your applications, delete the old key."
```

---

## Contributing

Contributions to this guide are welcome! Please submit a pull request or open an issue to suggest improvements or additions.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
