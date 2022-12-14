variable "aws_access_key" {
  description = "aws access key"
  type        = string
}

variable "aws_secret_key" {
  description = "aws secret key"
  type        = string
}

variable "aws_public_key" {
  description = "aws public key"
  type        = string
}

variable "db_password" {
  description = "mysql password"
  type        = string
}

variable "db_user" {
  description = "mysql user"
  type        = string
}

variable "db_name" {
  description = "mysql dbname"
  type        = string
}

variable "ecr_image" {
  description = "ecr image"
  type        = string
}