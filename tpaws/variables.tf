variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "instance_name" {
  type    = string
  default = "nginx-server"
}

variable "bucket_name" {
  type    = string
  default = "my-bucket-guillaume-1234567"
}

variable "http_port" {
  type    = number
  default = 80
}