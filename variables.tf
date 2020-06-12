variable "network_name" {
  type = string
  default = "main-network"
}

variable "enable_nat" {
  type = bool
  default = true
}

variable "database_boot_disk_id" {
  type = string
  default = "fhmc4ob0fsjm0dc1vuq7"
}