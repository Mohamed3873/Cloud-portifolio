terraform {
  required_version = ">= 1.3.7"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0"
    }
  }
}


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
        value = "129.241.236.83"
      }

      authorized_networks {
        name  = "my-vm-network"
        value = "34.140.243.29"
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

