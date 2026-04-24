# Infrastructure Review Criteria

Covers Terraform, AWS CDK, Serverless Framework, Pulumi, and similar IaC tools.

## Terraform
- `terraform plan` not run — changes applied without reviewing the plan
- Resources being replaced (destroy + create) when update-in-place is expected — check `lifecycle` blocks
- Missing `prevent_destroy` on critical resources (databases, S3 buckets with data)
- State file management — is state stored remotely with locking?
- Hard-coded values that should be variables or data sources
- Missing `depends_on` where implicit dependency isn't captured
- Provider version not pinned — `~>` is fine, `>=` is risky
- Sensitive values not marked as `sensitive = true` — will appear in plan output

## Security
- IAM policies too permissive — `Action: "*"` or `Resource: "*"` without justification
- Security groups with `0.0.0.0/0` ingress on non-public ports
- Encryption at rest not enabled on new storage resources (S3, RDS, EBS)
- Public access enabled on resources that should be private
- KMS key policies that grant broad access
- Missing VPC configuration — resources deployed to default VPC
- Secrets in Terraform variables or `tfvars` files — use a secrets manager

## Networking
- Subnet CIDR ranges overlapping or too small for expected growth
- NAT Gateway added/removed — affects outbound internet access for private subnets
- Route table changes that could break connectivity
- DNS record changes — TTL appropriate for the change?

## Cost
- Instance types oversized for workload (jumping to large when medium suffices)
- Missing auto-scaling configuration on new compute resources
- Storage volumes without lifecycle policies — unbounded growth
- NAT Gateway data processing costs — consider VPC endpoints for AWS service traffic
- Unused resources not removed (old security groups, ENIs, EIPs)

## Serverless Framework / CDK
- Lambda memory and timeout not configured — defaults may not be appropriate
- Missing dead letter queue (DLQ) for async invocations
- API Gateway authoriser changes affecting endpoint security
- Event source mappings without error handling configuration
- Lambda layers changed — all functions using the layer will be redeployed

## General IaC
- Tags missing on new resources — affects cost tracking and governance
- Outputs changed that other stacks/modules depend on
- Module version bumps without reviewing changelog for breaking changes
- Environment-specific values hard-coded instead of parameterised
