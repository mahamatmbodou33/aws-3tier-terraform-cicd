bucket         = "three-tier-app-terraform-state-12345"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"

    dynamodb_table = "terraform-locks"
    encrypt        = true