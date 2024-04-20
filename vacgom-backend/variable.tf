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

variable "private-subnet-ids" {
  type = list(string)
}

variable "private-cidr-groups" {
  type = list(string)
}

variable "vacgom-db-password" {
  type = string
}

variable "vacgom-domain" {
  type = string
}

variable "vacgom-zone" {
  type = string
}

variable "public-cidr-groups" {
  type = list(string)
}
