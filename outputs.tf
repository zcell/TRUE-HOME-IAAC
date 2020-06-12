
output "yandex_ubuntu" {
  value = data.yandex_compute_image.ubuntu18lts.description
}

output "database_disk" {
  value = yandex_compute_instance.database[0].boot_disk[0].disk_id
}