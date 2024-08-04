# Platform-MPV GitOps Workflow

This repository contains a diagram representing a comprehensive GitOps workflow. The diagram illustrates the integration of various tools and services used in a typical GitOps pipeline, including CI/CD, infrastructure provisioning, configuration management, and deployment.

## Diagram

```mermaid
flowchart TD
  %% Subgraphs for better organization
  subgraph CI_CD_Pipeline [GitOps]
    direction TB
    A[GitHub Actions]
    B[Terraform]
    C[Ansible]
    D[Helm]
    A -->|Pipeline| B
    A -->|Pipeline| C
    A -->|Pipeline| D
    A -->|Build & Push App| E[AWS ECR]
  end
  
  subgraph Infrastructure [Infrastructure]
    direction TB
    F[AWS Cloud]
    G[Kubernetes EKS]
    H[Helm Charts]
    I[Microservice Deployed]
    J[Prometheus]
    K[ELK Stack]
    L[AWS IAM Roles]
    M[AWS Secrets Manager]
    N[Network Policies]
    
    B -->|Infrastructure Provisioning| F
    C -->|Configuration Management| F
    D -->|Kubernetes Deployment| G
    F --> G
    G --> H
    E -->|Pull App| G
    H --> I
    G --> J
    G --> K
    F --> L
    G --> M
    F --> N
  end

  %% Edge connections outside the subgraphs
  CI_CD_Pipeline --> Infrastructure
```

## Components

### CI/CD Pipeline
- **GitHub Actions**: Orchestrates the CI/CD pipeline.
- **Terraform**: Used for infrastructure provisioning.
- **Ansible**: Used for configuration management.
- **Helm**: Used for Kubernetes deployment.
- **AWS ECR**: Stores Docker images.

### Infrastructure
- **AWS Cloud**: Cloud provider.
- **Kubernetes (EKS)**: Kubernetes service on AWS.
- **Helm Charts**: Manages Kubernetes applications.
- **Microservice Deployed**: Final deployment stage.
- **Prometheus**: Monitoring.
- **ELK Stack**: Logging.
- **AWS IAM Roles**: Manages access and permissions.
- **AWS Secrets Manager**: Manages secrets.
- **Network Policies**: Manages network traffic.

## License

This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or distribute this software, either in source code form or as a compiled binary, for any purpose, commercial or non-commercial, and by any means.

For more information, please refer to <http://unlicense.org/>

