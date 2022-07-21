terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.0.0"
    }
  }
}
provider "aws" {
  region = "us-east-1"
}
variable "bucket_name" {
  type = string
}
variable "object_name" {
  type = string
}
resource "aws_s3_bucket_object" "obj1" {
  bucket  = var.bucket_name
  key     = var.object_name
  content = "${var.object_name} content"
}
