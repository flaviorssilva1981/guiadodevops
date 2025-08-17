terraform {
  backend "s3" {
    bucket         = "fs-backend-terraforms"
    key            = "eks-cluster/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    
    # Optional: Enable versioning for state files
    # versioning = true
    
    # Optional: Enable server-side encryption
    # sse_encryption = "AES256"
  }
}
