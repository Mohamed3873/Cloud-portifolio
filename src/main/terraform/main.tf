# Configure the Google Cloud provider
provider "google" {
  project = "awesome-destiny-436710-j1"
  region  = "europe-west1"
}

# Define the MySQL instance
resource "google_sql_database_instance" "my_mysql_instance" {
  name             = "cloud-sql"
  database_version = "MYSQL_8_0"
  region           = "europe-west1"

  settings {
    tier = "db-f1-micro"

    ip_configuration {
      ipv4_enabled = true

      authorized_networks {
        name  = "my-office-network"
        value = "129.241.236.219"
      }
    }
  }
}

# Define a MySQL user
resource "google_sql_user" "my_mysql_user" {
  instance = google_sql_database_instance.my_mysql_instance.name
  name     = "cloud"
  password = var.db_password
  host     = "%"  # Allows connections from any host
}

# Create a database in the MySQL instance
resource "google_sql_database" "my_database" {
  name     = "terraform_database"
  instance = google_sql_database_instance.my_mysql_instance.name
}

