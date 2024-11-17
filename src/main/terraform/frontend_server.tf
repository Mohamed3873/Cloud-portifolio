# Firewall rule to allow HTTP traffic to the frontend server
resource "google_compute_firewall" "allow_frontend_http" {
  name    = "allow-frontend-http"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80" , "8080"]
  }

  source_ranges = ["0.0.0.0/0"]  # Allow traffic from any external IP
  target_tags   = ["frontend-server"]  # Apply this rule to the frontend instance
}

resource "google_compute_instance" "frontend_server" {
  name         = "frontend-server"
  machine_type = "e2-micro"
  zone         = "europe-west1-b"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  service_account {
    email = "test-495@awesome-destiny-436710-j1.iam.gserviceaccount.com"
    scopes = ["cloud-platform"]
  }

  tags = ["frontend-server"]

  metadata_startup_script = <<-EOT
    #!/bin/bash
    # Update package list and install Apache
    sudo apt update
    sudo apt install -y apache2

    # Create a simple HTML page as the frontend
    echo "<html><body><h1>Welcome to the Frontend!</h1><p>Connected to Backend: http://<BACKEND_IP>:8080</p></body></html>" > /var/www/html/index.html

    # Ensure Apache is running
    sudo systemctl start apache2
    sudo systemctl enable apache2
  EOT
}


