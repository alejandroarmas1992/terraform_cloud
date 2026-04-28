variable "location" {
  type        = string
  description = "Region Azure"
  default     = "eastus"
}

variable "lab_id" {
  description = "Estudiante id"
  type        = string
  default     = "e02"
}

variable "enviroment" {
  description = "Entorno"
  type        = string
  default     = "dev"
}

variable "user_object_id" {
  description = "Object ID del usuario que tendrá Contributor sobre el Resource Group"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key para acceso a la VM"
  type        = string
}