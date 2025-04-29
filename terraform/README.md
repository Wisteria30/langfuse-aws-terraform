# Langfuse v3 Terraform Module Sample

This Terraform module provides infrastructure components for deploying Langfuse v3 self-hosted on [Amazon Web Service(AWS)](https://aws.amazon.com/).

[Langfuse](https://langfuse.com/) is an open-source observability and analytics platform designed for LLM applications.

> [!NOTE]
> This module specifically focuses on Langfuse core components deployment. It does not include:
>  - VPC and networking configurations
>  - Infrastructure for LLM applications that will interact with Langfuse
> 
> You can either:
>  - Use this as a module within your existing Terraform codebase
>  - Create your own VPC and network infrastructure separately

## Features

![archtecture.jpg](docs/images/archtecture.jpg)

### Core Components
- **Web Server**: Deployed on AWS App Runner for scalable web application hosting
- **Async Worker**: Implemented using AWS ECS Fargate for efficient background processing

### Data Storage
- **OLTP Database**: Amazon Aurora Serverless v2 (PostgreSQL-compatible) for transactional data
- **Queue/Cache**: Amazon ElastiCache for Redis (Valkey) for high-performance caching
- **Blob Storage**: Amazon S3 for object storage for media files and event logs
- **OLAP Database**: ClickHouse running on AWS ECS Fargate with Amazon EFS for data persistence

### Analytics & Monitoring
- **Analytics Dashboard**: Grafana deployed on AWS ECS Fargate for OLAP query execution and visualization

### Infrastructure
- AWS-native service integration for efficient and cost-effective deployment, I mean, no EC2 instances!
- Scalable and production-ready setup
- Secure configuration with AWS best practices

For more information on Langfuse's architecture, please check [the official documentation](https://langfuse.com/self-hosting#architecture-overview).

## Prerequisites

- AWS Account
- Terraform >= 1.0 (tested version: v1.8.2)
- AWS CLI configured with pushing Docker images to Amazon ECR

## Setup Instructions

1. Create Terraform backend resources for state management
2. Configure required variables in `variables.tf`
3. Deploy using the provided examples or integrate as a module

### Infrastructure Configuration
- `identity_name` - Unique identifier for resources (e.g., "mycompany")
- `vpc_id` - Your VPC ID where Langfuse will be deployed
- `private_subnet_ids` - List of private subnet IDs for components deployment
- `custom_domain_name` - Domain name for Langfuse and Grafana (e.g., tubone-project24.com)
- `custom_domain_id` - Route53 Hosted Zone ID

### Security Configuration
- `web_next_secret` - Session cookie validation key (Generate: `openssl rand -base64 32`)
- `web_salt` - API key hashing salt (Generate: `openssl rand -base64 32`)
- `encryption_key` - 256-bit encryption key (Generate: `openssl rand -hex 32`)

### Database Configuration
- `database_user` - Aurora Serverless v2 database username (Default: "langfuse")
- `database_max_capacity` - Maximum Aurora capacity units (Default: 10)
- `database_min_capacity` - Minimum Aurora capacity units (Default: 0.5)

### Optional Configuration
- `env` - Environment name (Default: "dev")
- `region` - AWS region (Default: "us-east-1")
- `availability_zones` - List of AZs (Default: ["us-east-1a", "us-east-1b", "us-east-1c"])
- `cache_node_type` - ElastiCache instance type (Default: "cache.t2.micro")
- `is_spot_instance` - Use spot instances for workers (Default: false)
- `worker_desire_count` - Number of worker instances (Default: 1)

## Push Docker Images to ECR
After running terraform apply, you need to push the required Docker images to the created ECR repositories.

### [Langfuse web](https://github.com/langfuse/langfuse/pkgs/container/langfuse)

App Runner requires a x_86-64 image, so you need to pull x_86_64 image and push the image to ECR.

```bash
docker pull langfuse/langfuse:3
docker tag langfuse/langfuse:3 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/langfuse
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/langfuse
```

### [Langfuse worker](https://github.com/langfuse/langfuse/pkgs/container/langfuse-worker)
Langfuse worker, use ECS Fargate, you can choose ARM64 image.

So you need to pull ARM64 image and push the image to ECR. (Cost-effective)

```bash
docker pull --platform linux/arm64 langfuse/langfuse-worker:3
docker tag langfuse/langfuse-worker:3 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/langfuse-worker
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/langfuse-worker
```

### [Clickhouse](https://hub.docker.com/_/clickhouse)

Clickhouse, use ECS Fargate, you can choose ARM64 image.

```bash
docker pull clickhouse/clickhouse-server:24
docker tag clickhouse/clickhouse-server:24 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/clickhouse
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/clickhouse
```

#### Optional: Use Clickhouse with S3 Disk

If you want to use Clickhouse with S3 Disk, you need to use a [custom Clickhouse image](https://github.com/tubone24/clickhouse-server-s3disk) with S3 support. (Cost-effective)

```bash
docker pull ghcr.io/tubone24/clickhouse-server-s3disk
docker tag ghcr.io/tubone24/clickhouse-server-s3disk ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/clickhouse
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/clickhouse
```

### [Grafana](https://hub.docker.com/r/grafana/grafana)

TBD(Configurable)

## Examples

Complete deployment examples are available in the `examples` directory.
