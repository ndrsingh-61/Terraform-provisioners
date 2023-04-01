variable "ami" {
  description = "linux machine"
  default     = "ami-06e6b44dd2af20ed0"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_pairs_name" {
  default = "mumbai-airflow"
}

variable "access_key" {
  description = "access key for aws account"
  sensitive   = true
}

variable "secret_key" {
  description = "secret access key for aws account"
  type        = string
  sensitive   = true
}

variable "subnet" {
  default = "subnet-080e756c8d39f519e"
}



