variable "region" {
  description = "Region"
  type        = string
  default     = "us-east-1a"
}

variable "cidr_block" {
  description = "Subnet CIDR block"
  type        = string
  default     = "10.0.1.0/24"
}

variable "map_public_ip" {
  description = "Map public IP on launch"
  type        = bool
  default     = true
}

variable "name" {
  description = "Name of resources"
  type        = string
  default     = "first_instance"
}

variable "instance_type" {
  description = "Instance type"
  type        = string
  default     = "t2.micro"
}

variable "desired_capacity" {
  description = "Desired capacity"
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "Maximum capacity"
  type        = number
  default     = 1
}

variable "min_capacity" {
  description = "Minimal capacity"
  type        = number
  default     = 1
}