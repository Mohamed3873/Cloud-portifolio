variable "db_password" {
  description = "The db password"
  type        = string
  sensitive   = true
}

variable "gcp_credentials" {
  type        = string
  description = "The GCP credentials in Base64 encoding"
}
