variable "resource_group_name" {
  description = ""
  type        = string
  default     = "rg-cloud-lab-personal"
  #default     = "rg-cloud-lab"
}

variable "prefix" {
  description = "Prefijo para nombrar recursos"
  type        = string
  default     = "aks20"
}

variable "node_count" {
  description = "Número de nodos del pool por defecto"
  type        = number
  default     = 1
}

variable "vm_size" {
  description = "Tamaño de VM de los nodos"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "env" {
  description = "ambiente"
  type        = string
  default     = "dev"
}
