# Configure the Google Cloud provider
provider "google" {
  credentials = file("C:/Users/Moham/Videos/Maven/service.json")   # Path to your GCP service account key JSON
  project     = "awesome-destiny-436710-j1"                # Replace with your actual GCP project ID
  region      = "europe-west1"                               # Choose your preferred region
}

# Define the MySQL instance
resource "google_sql_database_instance" "my_mysql_instance" {
  name             = "cloud-sql"
  database_version = "MYSQL_8_0"
  region           = "europe-west1"
  settings {
    tier = "db-f1-micro"

    ip_configuration {
      ipv4_enabled = true                                  # Enables public IP, adjust as needed for security
    }
  }
}

# Define the MySQL user password
resource "google_sql_user" "my_mysql_user" {
  instance   = google_sql_database_instance.my_mysql_instance.name
  name       = "cloud"                                     # Username for MySQL
  password   = var.db_password                           # Password (choose a secure one)
  host       = "%"                                          # Allows access from any IP (useful for testing, adjust as needed for production)
}

# Create a database in the MySQL instance
resource "google_sql_database" "my_database" {
  name     = "terraform_database"                                  # Name of your database
  instance = google_sql_database_instance.my_mysql_instance.name
}
