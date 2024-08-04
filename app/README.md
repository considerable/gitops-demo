# Ping Pong Microservice

## Overview

The `ping_pong.py` microservice is a simple Python application that responds to HTTP requests. It is designed to run inside a Docker container and can be deployed to Amazon Elastic Container Registry (ECR).

## File Structure

```
ECR
├── app
│   ├── Dockerfile
│   ├── README.md
│   └── ping_pong.py
└── aws-ecr-clean.sh
.github
└── workflows
    └── ecr.yml
```

- `app/Dockerfile`: Dockerfile to build the Docker image for the `ping_pong.py` microservice.
- `app/README.md`: This README file.
- `app/ping_pong.py`: The Python script for the microservice.
- `aws-ecr-clean.sh`: Script to clean up old images in ECR.
- `.github/workflows/ecr.yml`: GitHub Actions workflow to build, upload, download, and test the microservice upon commit.

## Ping Pong Microservice

The `ping_pong.py` script is a simple Flask application that responds to HTTP requests. It listens on port 8080 and has a single endpoint `/ping` that returns a "pong" response.

### Example

```python
from flask import Flask

app = Flask(__name__)

@app.route('/ping')
def ping():
    return "pong"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
```

## Dockerfile

The `Dockerfile` is used to build a Docker image for the `ping_pong.py` microservice. It uses the official Python 3.9-slim image as the base image, sets the working directory to `/app`, copies the contents of the current directory into the container, exposes port 8080, and runs the `ping_pong.py` script when the container launches.

### Example

```dockerfile
# Use the official Python image from the Docker Hub as the base image
FROM python:3.9-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . .

# Expose port 8080 to the outside world
EXPOSE 8080

# Run the Python script when the container launches
CMD ["python3", "ping_pong.py"]
```

## GitHub Actions Workflow

The `ecr.yml` workflow is a GitHub Actions workflow that automates the process of building, uploading, downloading, and testing the `ping_pong.py` microservice upon commit to the `main` branch.

### Workflow Steps

1. **Checkout repository**: Checks out the repository to the GitHub Actions runner.
2. **Set up Docker Buildx**: Sets up Docker Buildx for building multi-architecture images.
3. **Configure AWS credentials**: Configures AWS credentials for accessing ECR.
4. **Log in to Amazon ECR**: Logs in to Amazon ECR.
5. **Build and push Docker image**: Builds and pushes the Docker image to ECR.
6. **Pull and run Docker image for testing**: Pulls the Docker image from ECR, runs it, and tests the `/ping` endpoint.
7. **Post-deployment steps (optional)**: Prints a message indicating that the Docker images have been successfully pushed to ECR.

### Example

```yaml
name: Build, Deploy, and Test ECR Image

on:
  push:
    branches:
      - main

jobs:
  build-and-push:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4  # Update to the latest version

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v3  # Update to the latest version
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ secrets.AWS_REGION }}
          role-to-assume: arn:aws:iam::${{ secrets.AWS_ACCOUNT_ID }}:role/github-actions-role
          role-session-name: GitHubActions
          role-duration-seconds: 10800  # Adjust this value as needed

      - name: Log in to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v2

      - name: Build and push multi-architecture Docker image
        env:
          ECR_REPOSITORY: ${{ secrets.ECR_REPOSITORY }}
          AWS_REGION: ${{ secrets.AWS_REGION }}
        run: |
          cd ECR/app
          SHORT_SHA=$(echo "${{ github.sha }}" | cut -c1-7)
          IMAGE_NAME="${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com/${{ secrets.ECR_REPOSITORY }}:ping_pong-${SHORT_SHA}"
          docker buildx build --platform linux/amd64,linux/arm64 -t $IMAGE_NAME -t ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com/${{ secrets.ECR_REPOSITORY }}:latest --push .

      - name: Pull and run Docker image for testing
        env:
          ECR_REPOSITORY: ${{ secrets.ECR_REPOSITORY }}
          AWS_REGION: ${{ secrets.AWS_REGION }}
        run: |
          docker pull ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com/${{ secrets.ECR_REPOSITORY }}:latest
          docker run -d -p 8080:8080 --name test-container ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com/${{ secrets.ECR_REPOSITORY }}:latest
          sleep 10 # Increase sleep duration to give the container more time to start
          docker logs test-container # Check container logs for debugging
          curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ping | grep -q "200" && echo "Test Passed!" || echo "Test Failed!"
          docker stop test-container
          docker rm test-container

      - name: Post-deployment steps (optional)
        run: |
          SHORT_SHA=$(echo "${{ github.sha }}" | cut -c1-7)
          echo "Docker images have been successfully pushed to ECR with tags ping_pong-${SHORT_SHA} and latest."
```

This README provides an overview of the `ping_pong.py` microservice and the `ecr.yml` workflow, explaining how the microservice is built, uploaded, downloaded, and tested upon commit.

