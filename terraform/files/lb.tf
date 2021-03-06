resource "yandex_lb_target_group" "reddit" {
  name      = "reddit-target-group"
  region_id = "ru-central1"

  dynamic "target" { 
  for_each = [for vm in yandex_compute_instance.app1: {
      subnet_id = var.subnet_id
      address   = vm.network_interface.0.ip_address
}] 
   content {
    subnet_id = target.value.subnet_id
    address   = target.value.address 
    }    
  }    
}

resource "yandex_lb_network_load_balancer" "my_first_lb1" {
  name = "reddit-lb"

  listener {
    name = "reddit-listener"
    port = 8080
    target_port = 9292
    external_address_spec {
    ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = "${yandex_lb_target_group.reddit.id}" 

    healthcheck {
    name = "http"
    healthy_threshold   = 4
    interval            = 3
    timeout             = 2
    unhealthy_threshold = 5

      http_options {
        port =9292
        path = "/"
      }
    }
  }
}

