// Create VPC
resource "google_compute_network" "vpc2" {
  name                    = "vpc2"
  auto_create_subnetworks = "false"
}

// Create Subnet
resource "google_compute_subnetwork" "subnet2" {
  name          = "subnet2"
  ip_cidr_range = "10.0.10.0/24"
  network       = "vpc2"
  #depends_on    = ["google_compute_network.vpc"]
  region = var.region
}
// VPC firewall configuration
resource "google_compute_firewall" "firewall2" {
  name    = "firewall2"
  network = google_compute_network.vpc2.id

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_router" "my-router2" {
  name    = "my-router2"
  region  = var.region
  network = google_compute_network.vpc2.id

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "myrouternat1" {
  name                               = "myrouternat1"
  router                             = google_compute_router.my-router2.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

resource "google_project_service" "prjsrv" {
  service = "cloudkms.googleapis.com"

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_dependent_services = true
}

resource "google_compute_instance" "tfinstance" {
  name                      = var.instance_name
  machine_type              = var.machine_type
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  scheduling {
    preemptible       = true
    automatic_restart = false
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet2.id
    access_config {

    }
  }
}