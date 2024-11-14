resource "google_compute_firewall" "allow_http_https" {
  name    = "allow-http-https"
  network = "default"

  # Allow HTTP and HTTPS traffic
  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  # Allow internal traffic and Cloud SQL access
  allow {
    protocol = "icmp"
  }

  target_tags = ["backend-server"] # Apply this rule to the backend instance
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
    }
  }

  # Add network tags to apply firewall rule
  tags = ["backend-server"]

  # Use a startup script to install and start the Cloud SQL Auth Proxy
  metadata_startup_script = <<-EOT
    #!/bin/bash
    # Install backend dependencies
    sudo apt update
    sudo apt install -y curl

    # Install the Cloud SQL Auth Proxy
    curl -o cloud_sql_proxy https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64
    chmod +x cloud_sql_proxy
    sudo mv cloud_sql_proxy /usr/local/bin/

    # Start the Cloud SQL Auth Proxy to connect to your database instance
    cloud_sql_proxy -instances=awesome-destiny-436710-j1:europe-west1:cloud-sql=tcp:3306 &
  EOT
}

# Additional firewall rule to allow Cloud SQL Proxy traffic (default allowed)
resource "google_compute_firewall" "allow_sql_proxy" {
  name    = "allow-sql-proxy"
  network = "default" # Use the default network

  allow {
    protocol = "tcp"
    ports    = ["3306"] # MySQL port for the Cloud SQL Proxy
  }

  target_tags = ["backend-server"] # Apply to backend server
}
