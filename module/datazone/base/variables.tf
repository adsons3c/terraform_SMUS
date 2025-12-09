variable "domain_name" {
  description = "Name of the DataZone domain"
  type        = string
}

variable "sagemaker_subnets" {
  description = "A list of subnets within the sagemaker VPC"
  type        = list(string)
}

variable "sagemaker_vpc_id" {
  description = "The VPC ID of the sagemaker VPC"
  type        = string
}

variable "sso_users" {
  description = "SSO users to add to the domain"
  type        = list(string)
}

variable "domain_units" {
  description = "Name of the DataZone domain"
  type        = list(string)
}

variable "root_domain_owners" {
  description = "Root domain owners"
  type        = list(string)
}

variable "parent_units" {
  description = "Mapeamento de domínios para suas unidades parent"
  type        = map(string)
}

variable "child_units_level_2" {
  description = "Mapeamento de grupos para suas listas de domínios"
  type        = map(list(string))
}

variable "child_units" {
  type        = map(list(string))
  description = "Mapa com subdominios para cada Domain Unit raiz"
}