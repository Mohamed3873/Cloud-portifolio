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
