variable "environment" {
  description = "The Deployment environment"
}

/* variable "public_subnets_cidr" {
  type        = list
  description = "The CIDR block for the public subnet"
}

variable "private_subnets_cidr" {
  type        = list
  description = "The CIDR block for the private subnet"
} */

variable "availability_zones" {
  type        = list
  description = "The az that the resources will be launched"
}
