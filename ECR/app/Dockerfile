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

