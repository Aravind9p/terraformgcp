resource "google_compute_instance" "terraform-instance" {
    name            = var.name
    machine_type    = var.machine_type

    boot_disk {
      initialize_params {
          image = var.image
      }
    }

  network_interface {
        subnetwork = google_compute_subnetwork.vpc-subnetwork.id
        access_config {

        }
    }
}

resource "google_compute_firewall" "firewall" {
  name    = "firewall"
  network = google_compute_network.vpc-network.id

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}  

resource "google_compute_network" "vpc-network" {
    name                    = "vpc-network"
    auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "vpc-subnetwork" {
  name          = "vpc-subnetwork"
  ip_cidr_range = "10.2.0.0/16"
  region        = "asia-south1"
  network       = google_compute_network.vpc-network.id
  }

resource "google_compute_router" "router" {
    name        = "router"
    network     = google_compute_network.vpc-network.id

    bgp {
      asn       = 64514
    }
}

resource "google_compute_router_nat" "natgateway" {
    name                                = "natgateway"
    router                              = google_compute_router.router.name
    region                              = data.google_client_config.current.region
    nat_ip_allocate_option              = "AUTO_ONLY"
    source_subnetwork_ip_ranges_to_nat  = "ALL_SUBNETWORKS_ALL_IP_RANGES"

    log_config {
      enable    = true
      filter    = "ERRORS_ONLY"
    }
}