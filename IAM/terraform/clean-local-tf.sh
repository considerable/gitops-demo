#!/bin/bash

# Clean up Terraform state files and plan files
rm -f .terraform.lock.hcl
rm -f terraform.tfstate
rm -f terraform.tfstate.backup
rm -f tfplan

# Optional: Remove any other temporary or unnecessary files
# rm -f *.log
# rm -f *.tmp

echo "Cleanup complete."
