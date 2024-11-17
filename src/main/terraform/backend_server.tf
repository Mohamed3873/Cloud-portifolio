# Create firewall rule to allow HTTP and HTTPS traffic to backend server
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

  target_tags = ["backend-server"] # Apply this rule to the backend instance
}

# Define the backend VM with Cloud SQL Auth Proxy configuration
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

  lifecycle {
    prevent_destroy = true
  }

  # Assign the service account to the VM
  service_account {
    email = "test-495@awesome-destiny-436710-j1.iam.gserviceaccount.com"
    scopes = ["cloud-platform"]
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

  # Define the source of allowed traffic (using source_tags)
  source_tags = ["backend-server"]

  target_tags = ["backend-server"] # Apply to backend server
}
