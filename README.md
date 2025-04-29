```bash
aws s3 mb s3://wisteria30-langfuse --region ap-northeast-1
```

1. variables.tfを修正
2. terraform init
3. terraform apply

```bash
source .env
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
docker compose build
docker compose push
```