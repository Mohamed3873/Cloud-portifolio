#Firewall rule to allow HTTP traffic to the frontend server
resource "google_compute_firewall" "allow_frontend_http" {
  name    = "allow-frontend-http"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80", "8080"]
  }

  source_ranges = ["0.0.0.0/0"]      # Allow traffic from any external IP
  target_tags   = ["frontend-server"]
}

resource "google_compute_address" "frontend_static_ip" {
  name   = "frontend-static-ip"
  region = "europe-west1"
}

# Frontend server instance configuration
resource "google_compute_instance" "frontend_server" {
  name         = "frontend-server"
  machine_type = "e2-micro"
  zone         = "europe-west1-b"

  # Boot disk configuration
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }



  # Network configuration
  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.frontend_static_ip.address
    }
  }

  # Service account with required scopes
  service_account {
    email  = "test-495@awesome-destiny-436710-j1.iam.gserviceaccount.com"
    scopes = ["cloud-platform"]
  }

  # Tags for firewall rule application
  tags = ["frontend-server"]

  metadata_startup_script = file("${path.module}/metascript.txt")


}
