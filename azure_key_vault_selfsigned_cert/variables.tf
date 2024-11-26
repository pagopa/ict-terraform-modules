variable "name" {
  type        = string
  description = "Name of the cert"
}

variable "tags" {
  type        = map(string)
  description = "Tag of azure resources"
  default     = {}
}

variable "key_vault_id" {
  type        = string
  description = "ID of the key vault in which to store the cert"
}

variable "subject_cn" {
  type        = string
  description = "CN (common name) of the cert"
}
