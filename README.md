# Infra for Devs made Simple: from Kind to IDP
Kubernetes in Docker (Kind) is the Only Infrastructure Knowledge Developers Need

## Overview

A brief description of your project, outlining its purpose and functionality.

## Prerequisites

- List of prerequisites for development or deployment.

## Setup

1. **Local Development**
   - Instructions for setting up the environment locally.

2. **Deployment**
   - Steps for deploying the application in various environments.

## Architecture Overview

A high-level description of the system architecture.

![](k8s-kind.png)

## Deployment Scenarios

### 1) It works on my PC

```mermaid
graph TD
    subgraph Workstation [PC Workstation]
        subgraph DevContainer
            subgraph KindCluster
                HelloWorldPod[Hello World Pod]
                PostgreSQLPod[PostgreSQL Pod]
            end
        end
        Browser[Browser]
        Docker[Docker Image]
    end
    Browser --> HelloWorldPod
    Docker --> DevContainer
```

This diagram represents:

- **Workstation**: The local development environment.
- **DevContainer**: Contains the development environment within Docker.
- **KindCluster**: A Kubernetes cluster for local testing.
- **HelloWorldPod** & **PostgreSQLPod**: Example application and database pods.
- **Browser**: Local testing of the application.

### 2) It works on my EC2 instance

```mermaid
graph LR
    subgraph AWS[AWS Cloud]
        subgraph ECR[ECR Registry]
            DockerImage[Docker Image]
        end
        subgraph EC2[EC2 Instance]
            PublicIP[Public IP]
            subgraph DevContainer
                subgraph KindCluster
                    HelloWorldPod[Hello World Pod]
                    PostgreSQLPod[PostgreSQL Pod]
                end
            end
        end
        PublicIP --> HelloWorldPod
    end
    subgraph Workstation [PC Workstation]
        Browser[Browser]
    end
    DockerImage --> DevContainer
    Browser --> PublicIP
```

This setup shows:

- **AWS**: Hosts the EC2 instance where your application runs.
- **ECR**: For storing Docker images.
- **EC2**: Runs your containers with public access via **PublicIP**.

### 3) Standalone container in AWS-managed Fargate services

```mermaid
graph LR
    subgraph AWS[AWS Cloud]
        subgraph ECR[ECR Registry]
            DockerImage[Docker Image]
        end
        subgraph Fargate[Fargate]
            subgraph ServiceEndpoint
                PublicIP[Public IP]
            end
            subgraph DevContainer
                subgraph KindCluster
                    HelloWorldPod[Hello World Pod]
                    PostgreSQLPod[PostgreSQL Pod]
                end
            end
        end
        PublicIP --> HelloWorldPod
    end

    subgraph Workstation [PC Workstation]
        Browser[Browser]
    end

    DockerImage --> DevContainer
    Browser --> PublicIP
```

Here, **Fargate** provides a serverless compute engine for containers:

- **ServiceEndpoint**: Represents how external traffic is directed to Fargate tasks.

### 4) DevOps-automated AWS-managed K8s service EKS

```mermaid
graph LR
       subgraph AWS[AWS Cloud]
           subgraph ECR[ECR Registry]
               DockerImage[Docker Image]
           end
           subgraph EKS[EKS Cluster]
               subgraph NginxIngress[Nginx Ingress Controller]
                   Ingress[Ingress]
               end
               subgraph WorkerNode [EKS Worker Node]
                   HelloWorldPod[Hello World Pod]
                   PostgreSQLPod[PostgreSQL Pod]
               end
           end
           DockerImage --> WorkerNode
           Ingress --> HelloWorldPod
       end

       subgraph Workstation [PC Workstation]
           Browser[Browser]
       end

       Browser --> Ingress
```

- **EKS**: Managed Kubernetes service where:
  - **Nginx Ingress**: Manages access to Kubernetes services.

### 5) Platform-orchestrated AWS-managed EKS (simplified)

This section outlines more advanced Platform orchestrator for configuration, enhancing the automation and consistency across development environments:

```mermaid
graph LR
    subgraph AWS[AWS Cloud]
        subgraph ECR[ECR Registry]
            DockerImage[Docker Image]
        end
        subgraph EKS[EKS Cluster]
            subgraph IngressController[Ingress Controller]
                Ingress[Ingress]
            end
            subgraph WorkerNode [EKS Worker Node]
                HelloWorldPod[Hello World Pod]
                PostgreSQLPod[PostgreSQL Pod]
            end
        end
    end

    subgraph Integration_and_Delivery_Plane["Integration and Delivery Plane"]
        Score["Score <br>(platform-agnostic yaml)"]
        CI_Pipeline["CI Pipeline <br>(GitHub Actions)"]
        Platform_Orchestrator_Node{"Platform Orchestrator <br>(Humanitec/Kratix/Kusion)"}
        CD_Pipeline["CD Pipeline <br>(Argo CD)"]
    end

    Score --> Platform_Orchestrator_Node
    CI_Pipeline --> DockerImage
    DockerImage --> Platform_Orchestrator_Node
    Platform_Orchestrator_Node --> CD_Pipeline
    CD_Pipeline --> EKS
    subgraph Workstation [PC Workstation]
        Developer[Developer]
        Browser[Browser]
    end
    Developer --> Score
    Developer --> CI_Pipeline
    Browser --> Ingress
    Ingress --> HelloWorldPod
```

**Explanation:**

- **Score**: Developers define their application's requirements using Score's platform-agnostic YAML configuration. This file describes what resources and services the application needs without specifying how they should be implemented on each platform.

- **CI Pipeline**: **GitHub Actions** or similar CI tools are used to build and test the application, pushing the Docker images to **Amazon ECR**.

- **Platform Orchestrator**: Tools like **Humanitec**, **Kratix**, or **Kusion** interpret the Score configuration. These orchestrators understand how to translate Score's abstract requirements into concrete cloud-native resources across different environments or platforms.

- **CD Pipeline**: **Flux** is utilized for continuous deployment, ensuring that the Kubernetes (EKS) environment reflects the state defined by the Score configuration, automatically deploying or updating services as changes are detected in the Git repository or Docker images.

- **Developer**: The process starts with developers writing code and Score configurations, which then triggers the CI/CD pipeline.

- **Browser**: Represents the end-user accessing the application through the **Ingress Controller** in EKS.

This setup leverages Score to abstract away the complexity of environment-specific configurations, allowing for a more streamlined, consistent, and efficient deployment process across various cloud platforms, with a focus on AWS EKS for Kubernetes management.

### 6) Internal Developer Platform (IDP) mini Reference Architecture

Internal Developer Platform (IDP) architecture aims to provide a seamless experience for developers, where:

- **Developers** only need to interact with a simplified **Developer Control Plane**, reducing their cognitive load and allowing them to focus on coding and feature development.

- **Integration and Delivery** processes are automated, ensuring that code changes are efficiently tested, built, and deployed without manual intervention, leveraging tools like Score for configuration.

- **Resources** are dynamically provisioned

IDP abstracts the complexities of infrastructure, providing developers with self-service capabilities to manage their applications. Here's a breakdown of the key abstractions:

```mermaid
flowchart TB
 subgraph IDP_mini_RA_AWS["IDP Reference Architecture - AWS"]
        Developer_Control_Plane["Developer Control Plane"]
        Integration_and_Delivery_Plane["Integration and Delivery Plane"]
        Resource_Plane["Resource Plane"]
        Monitoring_and_Logging_Plane["Monitoring and Logging Plane"]
        Security_Plane["Secrets & Identity Management"]
 end
 subgraph Developer_Control_Plane["Developer Control Plane"]
        Version_Control
        IDE["IDE <br>(Visual Studio Code)"]
        Service_Catalog["Service / API Catalog / Dev Portal <br>(Backstage)"]
 end
 subgraph Version_Control["Version Control <br>(GitHub)"]
        App_Source_Code["Application Source Code <br>(Score Workloads)"]
        Platform_Source_Code["Platform Source Code <br>(Terraform Automations)"]
 end
 subgraph Integration_and_Delivery_Plane["Integration and Delivery Plane"]
        CI_Pipeline["CI Pipeline <br>(GitHub Actions)"]
        Registry["Registry <br>(Amazon ECR)"]
        Platform_Orchestrator_Node{"Platform Orchestrator"}
        CD_Pipeline["CD Pipeline <br>(Flux)"]
 end
 subgraph Resource_Plane["Resource Plane"]
        Compute["Kubernetes (EKS/Kind)"]
        Data["Data (PostgreSQL)"]
        Networking["Networking (VPC)"]
        Services["Services (Amazon SQS)"]
 end
 subgraph Monitoring_and_Logging_Plane["Monitoring and Logging Plane"]
        Observability["Observability <br>(FluentD)"]
 end
 subgraph Security_Plane["Security Plane<br>Secrets & Identity Management"]
        GitHub_Secrets["GitHub Secrets"]
        IAM_Roles["Amazon IAM roles"]
 end

    App_Source_Code --- Commit(("Code <br> Change"))
    Commit --> CI_Pipeline 
  
    CI_Pipeline --> Registry
    Registry --> Platform_Orchestrator_Node
    Platform_Source_Code --> Platform_Orchestrator_Node
    Platform_Orchestrator_Node --> CD_Pipeline

    CD_Pipeline --> Resource_Plane
    Platform_Source_Code --> Monitoring_and_Logging_Plane
    Monitoring_and_Logging_Plane <--> Resource_Plane
    Platform_Source_Code --> Security_Plane
    Security_Plane <--> Integration_and_Delivery_Plane
```

- **Developer Control Plane**: 
  - This is the interface through which developers interact with the platform. It abstracts away the underlying complexity, providing tools, APIs, or a dashboard where developers can define application requirements, manage deployments, and monitor application health without needing deep infrastructure knowledge.

- **Integration and Delivery Plane**:
  - Encompasses the CI/CD pipelines, orchestration tools, and configuration management systems like Score, Flux, or Argo CD. This plane takes the developer's code and configurations, builds, tests, and deploys them onto the resource plane, ensuring continuous integration and delivery.

- **Resource Plane**:
  - Represents the actual infrastructure where applications run, including cloud services (like AWS EKS), virtual machines, storage, and networking. This plane is managed by the platform to provide scalable, secure, and efficient resources as defined by the application requirements.

- **Monitoring and Logging Plane**:
  - Provides tools for collecting, storing, and analyzing logs, metrics, and traces from applications and infrastructure. This abstraction helps developers and operators understand application performance, troubleshoot issues, and ensure compliance with SLAs without managing the underlying monitoring infrastructure.

- **Secrets & Identity Management**:
  - Manages sensitive information like API keys, credentials, and certificates, as well as identities for both humans and services within the platform. This plane ensures secure access control, secrets rotation, and compliance with security policies, abstracting the complexity of security management from the developer.
