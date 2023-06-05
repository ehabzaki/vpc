module "dev" {
    source  = "../modules/vpc"
    environment= "dev"
    availability_zones = ["a","b"]
}
