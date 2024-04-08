variable "vpc-id" {
  type = string
}

variable "vacgom-container-image" {
  type = string
}

variable "vacgom-cluster-name" {
  type = string
}

variable "vacgom-capacity-provider-id" {
  type = list(string)
}

variable "vacgom-alb-id" {
  type = string
}



