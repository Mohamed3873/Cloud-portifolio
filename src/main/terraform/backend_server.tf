#Firewall rule to allow HTTP and HTTPS traffic to backend server
resource "google_compute_firewall" "allow_http_https" {
  name    = "allow-http-https"
  network = "default" # Use the default network

  # Allow HTTP and HTTPS traffic from the backend server's tag
  allow {
    protocol = "tcp"
    ports    = ["80", "443" , "8080"]
  }

  # Allow traffic from any external IP
  source_ranges = ["0.0.0.0/0"]

  target_tags = ["backend-server"]
}

resource "google_compute_address" "backend_static_ip" {
  name   = "backend-static-ip"
  region = "europe-west1"
}

metadata = {
  DB_USER     = var.db_user
  DB_PASSWORD = var.db_password
  DB_HOST     = var.db_host
  DB_PORT     = var.db_port
  DB_NAME     = var.db_name
}

resource "google_compute_instance" "backend_server" {
  name         = "backend-server"
  machine_type = "e2-micro" # Small, cost-effective instance type
  zone         = "europe-west1-b"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11" # Example image
    }
  }


  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.backend_static_ip.address
    }
  }

  # Assign the service account to the VM
  service_account {
    email = "test-495@awesome-destiny-436710-j1.iam.gserviceaccount.com"
    scopes = ["cloud-platform"]
  }

  # Add network tags to apply firewall rule
  tags = ["backend-server"]

  metadata_startup_script = file("${path.module}/backendscript.txt")


}

# Additional firewall rule to allow Cloud SQL Proxy traffic (default allowed)
resource "google_compute_firewall" "allow_sql_proxy" {
  name    = "allow-sql-proxy"
  network = "default" # Use the default network

  allow {
    protocol = "tcp"
    ports    = ["3306"] # MySQL port for the Cloud SQL Proxy
  }

  # Define the source of allowed traffic (using source_tags)
  source_tags = ["backend-server"]

  target_tags = ["backend-server"] # Apply to backend server
}
