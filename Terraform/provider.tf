provider "aws" {
  region = "ap-south-1"

  default_tags {
    tags = {
      Project     = "nodejs-sample-app"
      Environment = "production"
    }
  }

}
