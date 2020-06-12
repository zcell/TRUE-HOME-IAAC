provider "yandex" {
  cloud_id = "b1g642ugo4k4oa7rqdhn"
  folder_id = "b1g57cjroloibprcl1k4"
  zone = "ru-central1-c"
}

terraform {
  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "internal-true"
    region     = "us-east-1"
    key        = "tf/main.tfstate"

    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

data "yandex_compute_image" "ubuntu18lts" {
  family = "ubuntu-1804-lts"
}

resource "yandex_compute_instance" "balancer" {
  name = "balancer"
  hostname = "balancer"
  platform_id = "standard-v1"
  zone = "ru-central1-a"
  allow_stopping_for_update = true
  count = 1

  boot_disk {
    auto_delete = true
    device_name = "main"
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu18lts.image_id
      size = 3
      type = "network-ssd"
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.main-subnet.id
    nat = var.enable_nat
    ipv4 = true
    ip_address = "10.0.0.5"
    nat_ip_address = local.reserved_ip
  }
  resources {
    core_fraction = 5
    cores = 1
    memory = 2
  }
  metadata = {
    user-data = file("configs/default")
  }
}

resource "yandex_compute_instance" "frontend" {
  name = "frontend"
  hostname = "frontend"
  platform_id = "standard-v1"
  zone = "ru-central1-a"
  count = 1

  boot_disk {
    auto_delete = true
    device_name = "main"
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu18lts.image_id
      size = 5
      type = "network-ssd"
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.main-subnet.id
    nat = var.enable_nat
    ipv4 = true
    ip_address = "10.0.0.10"
  }
  resources {
    core_fraction = 5
    cores = 1
    memory = 2
  }
  metadata = {
    user-data = file("configs/default")
  }
}


resource "yandex_compute_instance" "backend" {
  name = "backend"
  hostname = "backend"
  platform_id = "standard-v1"
  zone = "ru-central1-a"
  count = 1

  boot_disk {
    auto_delete = true
    device_name = "main"
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu18lts.image_id
      size = 5
      type = "network-ssd"
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.main-subnet.id
    nat = var.enable_nat
    ipv4 = true
    ip_address = "10.0.0.20"
  }
  resources {
    core_fraction = 5
    cores = 1
    memory = 2
  }
  metadata = {
    user-data = file("configs/default")
  }
}

resource "yandex_compute_instance" "database" {
  name = "database"
  hostname = "database"
  platform_id = "standard-v1"
  zone = "ru-central1-a"
  count = 1

  resources {
    core_fraction = 5
    cores = 1
    memory = 2
  }

  boot_disk {
    disk_id = var.database_boot_disk_id
    auto_delete = false
//    device_name = "main"
//    initialize_params {
//      image_id = data.yandex_compute_image.ubuntu18lts.image_id
//      size = 10
//      type = "network-ssd"
//    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.main-subnet.id
    nat = var.enable_nat
    ipv4 = true
    ip_address = "10.0.0.50"
  }

  metadata = {
    user-data = file("configs/default")
  }
}

resource "yandex_vpc_network" "default" {
  name = var.network_name
  labels = {
    network = var.network_name
  }
}

resource "yandex_vpc_subnet" "main-subnet" {
  zone = "ru-central1-a"
  network_id = yandex_vpc_network.default.id
  v4_cidr_blocks = ["10.0.0.0/16"]
}

