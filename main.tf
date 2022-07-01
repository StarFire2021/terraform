# The configuration for the `remote` backend.
terraform {
  backend "remote" {
    organization = "starfire"
    workspaces {
      name = "terraform_cloud"
    }
  }
}
